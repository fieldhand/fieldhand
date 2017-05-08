require 'fieldhand/datestamp'
require 'fieldhand/error'
require 'fieldhand/record'
require 'ox'

module Fieldhand
  # A SAX parser for ListRecords responses that skips parsing metadata.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListRecords
  class ListRecordsParser < ::Ox::Sax
    attr_reader :items, :stack
    attr_accessor :item, :element, :metadata, :about, :response_date, :resumption_token, :error_code

    def initialize
      @items = []
      @element = nil
      @stack = []
      @response_date = Time.now
    end

    def current_element
      stack.last
    end

    def inside_metadata?
      stack[0] == :'OAI-PMH' && stack[2, 2] == [:record, :metadata]
    end

    def inside_about?
      stack[0] == :'OAI-PMH' && stack[2, 2] == [:record, :about]
    end

    def start_element(name)
      if inside_metadata?
        metadata << "<#{name}"
      elsif inside_about?
        about << "<#{name}"
      end

      self.element = name

      case name
      when :record
        self.item = Record.new(response_date)
      when :metadata
        self.metadata = ''
      when :about
        self.about = ''
      end
    end

    def attr(name, str)
      if inside_metadata?
        metadata << %( #{name}="#{str}")
      elsif inside_about?
        about << %( #{name}="#{str}")
      elsif name == :status
        item.header.status = str
      elsif name == :code && element == :error
        self.error_code = str
      end
    end

    def attrs_done
      if inside_metadata?
        metadata << '>'
      elsif inside_about?
        about << '>'
      end

      stack.push(element)
      self.element = nil
    end

    def end_element(name)
      stack.pop

      if inside_metadata?
        metadata << "</#{name}>"
      elsif inside_about?
        about << "</#{name}>"
      end

      case name
      when :record
        items << item
      when :metadata
        item.metadata = metadata
      when :about
        item.about << about
      end
    end

    def text(str)
      return if str.empty?

      if inside_metadata?
        metadata << str
      elsif inside_about?
        about << str
      else
        case current_element
        when :error
          Error.convert(error_code, str)
        when :responseDate
          self.response_date = Datestamp.parse(str)
        when :identifier
          item.header.identifier = str
        when :datestamp
          item.header.datestamp = Datestamp.parse(str)
        when :setSpec
          item.header.sets << str
        when :resumptionToken
          self.resumption_token = str
        end
      end
    end
  end
end
