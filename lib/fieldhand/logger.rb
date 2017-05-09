require 'logger'
require 'rbconfig'

module Fieldhand
  # A default null logger for discarding log messages.
  module Logger
    module_function

    # Return a new `Logger` that logs to the null device on this platform.
    def null
      ::Logger.new(null_device)
    end

    # Determine the null device on this platform, a backport of more recent Rubies' File::NULL
    # See https://github.com/marcandre/backports/blob/v3.8.0/lib/backports/1.9.3/file/null.rb
    def null_device
      platform = ::RUBY_PLATFORM
      platform = ::RbConfig::CONFIG['host_os'] if platform == 'java'

      case platform
      when /mswin|mingw/i then 'NUL'
      when /amiga/i then 'NIL:'
      when /openvms/i then 'NL:'
      else
        '/dev/null'
      end
    end
  end
end
