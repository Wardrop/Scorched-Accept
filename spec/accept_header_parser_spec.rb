#require_relative './spec_helper.rb'
require_relative "../lib/scorched/accept/accept_header"
require "maxitest/autorun"

module Scorched
  module Accept
    describe AcceptHeaderParser do
      it "parses correctly" do
        tree = AcceptHeaderParser.new.parse(' text/plain; name=bob ; age=19; q=0.10; dog="r\o\o\\f\" bark"; cat=meow, */*, video/*')
        AcceptHeaderTransform.new.apply(tree).must_equal([
          {media_type: "text/plain", parameters: {name: "bob", age: "19"}, q: 0.1, extensions: {dog: %q{roof" bark}, cat: "meow"}},
          {media_type: "*/*"},
          {media_type: "video/*"}
        ])

        lambda { AcceptHeaderParser.new.parse('text/plain; name = bob') }.must_raise Parslet::ParseFailed
      end

      it "deals with a single media range correctly" do
        AcceptHeaderTransform.new.apply(AcceptHeaderParser.new.parse('*/*')).must_equal [{:media_type=>"*/*"}]
      end
    end
  end
end
