require 'fieldhand/datestamp'
require 'fieldhand/set'
require 'ox'

module Fieldhand
  # A SAX parser for ListSets responses that skips parsing set descriptions.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListSets
  class ListSetsParser < ::Ox::Sax
    attr_reader :items, :stack
    attr_accessor :item, :element, :description, :response_date, :resumption_token

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
      stack.include?(:setDescription)
    end

    def start_element(name)
      description << "<#{name}" if inside_description?

      self.element = name

      case name
      when :set
        self.item = Set.new(response_date)
      when :setDescription
        self.description = ''
      end
    end

    def attr(name, str)
      return unless inside_description?

      description << %( #{name}="#{str}")
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
      when :set
        items << item
      when :setDescription
        item.descriptions << description
      end
    end

    def text(str)
      if inside_description?
        description << str
      else
        case current_element
        when :responseDate
          self.response_date = Datestamp.parse(str)
        when :setSpec
          item.spec = str
        when :setName
          item.name = str
        when :resumptionToken
          self.resumption_token = str
        end
      end
    end
  end
end
