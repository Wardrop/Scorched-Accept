#require_relative './spec_helper.rb'
require_relative "../lib/scorched/accept/header_accept"
require "maxitest/autorun"

module Scorched
  module Accept
    describe HeaderAcceptParser do
      it "parses correctly" do
        tree = HeaderAcceptParser.new.parse(' text/plain; name=bob ; age=19; q=0.10; dog="r\o\o\\f\" bark"; cat=meow, */*, video/*')
        HeaderAcceptTransform.new.apply(tree).must_equal([
          {media_type: "text/plain", parameters: {name: "bob", age: "19"}, q: 0.1, extensions: {dog: %q{roof" bark}, cat: "meow"}},
          {media_type: "*/*"},
          {media_type: "video/*"}
        ])

        lambda { HeaderAcceptParser.new.parse('text/plain; name = bob') }.must_raise Parslet::ParseFailed
      end
    end
  end
end
