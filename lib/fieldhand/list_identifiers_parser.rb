require 'fieldhand/datestamp'
require 'fieldhand/error'
require 'fieldhand/header'
require 'ox'

module Fieldhand
  # A SAX parser for ListIdentifiers responses.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#ListIdentifiers
  class ListIdentifiersParser < ::Ox::Sax
    attr_reader :items, :stack
    attr_accessor :item, :response_date, :resumption_token, :error_code

    def initialize
      @items = []
      @stack = []
      @response_date = Time.now
    end

    def current_element
      stack.last
    end

    def start_element(name)
      stack.push(name)

      case name
      when :header
        self.item = Header.new(response_date)
      end
    end

    def attr(name, str)
      case name
      when :status
        item.status = str
      when :code
        self.error_code = str if current_element == :error
      end
    end

    def end_element(name)
      stack.pop

      case name
      when :header
        items << item
      end
    end

    def text(str)
      return if str.empty?

      case current_element
      when :error
        Error.convert(error_code, str)
      when :responseDate
        self.response_date = Datestamp.parse(str)
      when :identifier
        item.identifier = str
      when :datestamp
        item.datestamp = Datestamp.parse(str)
      when :setSpec
        item.sets << str
      when :resumptionToken
        self.resumption_token = str
      end
    end
  end
end
