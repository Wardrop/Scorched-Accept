require_relative './spec_helper.rb'
require_relative "../lib/scorched/accept"

module Scorched
  module Accept
    describe "Rack" do

      it "adds an AcceptHeader instance to Rack env" do
        internal_env = nil
        rt = ::Rack::Test::Session.new(::Rack::Builder.new do
          internal_env = nil
          use Scorched::Accept::Rack
          run proc { |env| internal_env = env; [200, {}, 'ok'] }
        end)
        rt.get('/')
        internal_env['scorched.accept'][:accept].must_be_instance_of Scorched::Accept::AcceptHeader
      end
    end
  end
end
