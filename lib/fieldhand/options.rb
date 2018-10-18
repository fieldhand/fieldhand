require 'fieldhand/logger'

module Fieldhand
  # A wrapper around Repository and Paginator options for backward-compatibility.
  #
  # In short, this handles passing a Logger directly or passing it and a timeout as a hash.
  # Note this attempts to preserve the previous behaviour of passing nil/falsey values as a
  # logger even though this will cause errors if someone tries to use it that way.
  class Options
    attr_reader :logger_or_options

    # Return a new, normalized set of options based on the given value.
    #
    # This supports both a `Logger`-compatible object to use for logging directly and a hash of options:
    #
    # * :logger - A `Logger`-compatible class for logging the activity of the library, defaults to a platform-specific
    #             null logger
    # * :timeout - A `Numeric` number of seconds to wait for any HTTP requests, defaults to 60 seconds
    # * :bearer_token - A `String` bearer token to use when sending any HTTP requests, defaults to nil
    # * :headers - A `Hash` containing custom HTTP headers, defaults to {}.
    def initialize(logger_or_options = {})
      @logger_or_options = logger_or_options
    end

    # Return the current timeout in seconds.
    def timeout
      options.fetch(:timeout, 60)
    end

    # Return the current logger.
    def logger
      options.fetch(:logger) { Logger.null }
    end

    # Return the current bearer token.
    def bearer_token
      options[:bearer_token]
    end

    # Build custom headers
    def headers
      headers = options.fetch(:headers, {})
      headers['Authorization'] = "Bearer #{bearer_token}" if bearer_token

      headers
    end

    private

    def options
      return logger_or_options if logger_or_options.is_a?(Hash)

      { :logger => logger_or_options }
    end
  end
end
