module Scorched
  module Accept
    class Rack
      def initialize(app, env_prefix = 'scorched')
        @app = app
        @env_prefix = env_prefix
      end

      def call(env)
        env["#{@env_prefix}.accept"] = {accept: AcceptHeader.new(env["HTTP_ACCEPT"])}
        @app.call(env)
      end
    end
  end
end
