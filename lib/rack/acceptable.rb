module Rack
  class Acceptable
    class RuntimeError < RuntimeError
    end
    
    @env_key = 'rack-acceptable'
    class << self
      attr_accessor :env_key
    
      def new(app, &block)
        env_key = self.env_key
        (middleware = Object.new).define_singleton_method(:call) do |env|
          env[env_key] = API.new(env)
          app.call(env)
        end
        middleware
      end
    end
  end
end

require_relative './acceptable/parsers'
require_relative './acceptable/accept'

# puts Parsers.parse(Parsers::AcceptParser,  "meow / cat ; name = bob; age = 19; q = 0.5 ; ok = yes ; nah = no , application / json ; dog=roof; q = 0.1; mouse = squeak   ")