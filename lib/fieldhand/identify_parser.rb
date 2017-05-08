require 'fieldhand/datestamp'
require 'fieldhand/error'
require 'fieldhand/identify'
require 'ox'
require 'uri'

module Fieldhand
  # A SAX parser for Identify responses that skips parsing description elements.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Identify
  class IdentifyParser < ::Ox::Sax
    attr_reader :items, :stack
    attr_accessor :item, :element, :description, :response_date, :resumption_token, :error_code

    def initialize
      @items = []
      @element = nil
      @stack = []
      @response_date = Time.now
    end

    def current_element
      stack.last
    end

    def inside_description?
      stack[0, 3] == [:'OAI-PMH', :Identify, :description]
    end

    def start_element(name)
      description << "<#{name}" if inside_description?

      self.element = name

      case name
      when :Identify
        self.item = Identify.new(response_date)
      when :description
        self.description = ''
      end
    end

    def attr(name, str)
      if inside_description?
        description << %( #{name}="#{str}")
      elsif element == :error && name == :code
        self.error_code = str
      end
    end

    def attrs_done
      description << '>' if inside_description?

      stack.push(element)
      self.element = nil
    end

    def end_element(name)
      stack.pop

      description << "</#{name}>" if inside_description?

      case name
      when :Identify
        items << item
      when :description
        item.descriptions << description
      end
    end

    def text(str)
      return if str.empty?

      if inside_description?
        description << str
      else
        case current_element
        when :error
          Error.convert(error_code, str)
        when :responseDate
          self.response_date = Datestamp.parse(str)
        when :repositoryName
          item.name = str
        when :baseURL
          item.base_url = URI(str)
        when :protocolVersion
          item.protocol_version = str
        when :adminEmail
          item.admin_emails << str
        when :earliestDatestamp
          item.earliest_datestamp = Datestamp.parse(str)
        when :deletedRecord
          item.deleted_record = str
        when :granularity
          item.granularity = str
        when :compression
          item.compression << str
        when :resumptionToken
          self.resumption_token = str
        end
      end
    end
  end
end
