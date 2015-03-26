module Scorched
  module Accept
    class Rack
      def initialize(app, env_prefix = 'scorched.accept.')
        @app = app
        @env_prefix = env_prefix
      end

      def call(env)
        env["#{@env_prefix}.accept"] = HeaderAccept.new(env["HTTP_ACCEPT"])
        @app.call(env)
      end
    end
  end
end
