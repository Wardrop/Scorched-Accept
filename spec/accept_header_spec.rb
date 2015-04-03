require_relative './spec_helper.rb'

module Scorched
  module Accept
    describe "AcceptHeader" do
      let_all :long_header do
        '*/*, text/html;level=3,video/webm;codecs=vp8;videoonly=1, text/*, video/*;q=0.4, application/json, text/plain'
      end

      let_all :short_header do
        'text/*;encoding=utf-8;q=1;speed=high, video/mpeg'
      end

      # How the `long_header` should be once parsed and ordered.
      let_all :long_header_ordered do
        %w{
          video/webm
          text/html
          application/json
          text/plain
          text/*
          */*
          video/*
        }
      end

      let :accept_header do
        AcceptHeader.new(long_header)
      end

      it "orders media ranges based on qvalue, specificity, and the order they are defined" do
        accept_header.ordered_values.map { |v| v[:media_type] }.must_equal long_header_ordered
      end

      it "determines whether a media type is acceptable or not" do
        accept_header.acceptable?('text/html').must_equal true
        accept_header.acceptable?('large/dog').must_equal true
        AcceptHeader.new(short_header).acceptable?('video/mp4').must_equal false
      end

      it "ranks a media type against list of acceptable media types" do
        accept_header.rank('text/x-markdown').must_equal long_header_ordered.index('text/*')
        accept_header.rank('video/mpeg').must_equal long_header_ordered.index('*/*')
        AcceptHeader.new(short_header).rank('video/mp4').must_equal nil
      end

      it "selects the most appropriate media type out of an array" do
        accept_header.best_of('text/plain', 'text/html').must_equal 'text/html'
        accept_header.best_of('video/mpeg', 'text/x-markdown', 'cat/meow').must_equal 'text/x-markdown'
        AcceptHeader.new(short_header).rank('video/mp4').must_equal nil

        # Uses the order of arguments if the provided arguments are equally acceptable.
        accept_header.best_of('dog/roof', 'cat/meow').must_equal 'dog/roof'
      end

      it "can return a hash" do
        AcceptHeader.new(short_header).to_h.must_equal(
          'video/mpeg' => {},
          'text/*' => {parameters: {encoding: 'utf-8'}, q: 1, extensions: {speed: 'high'}}
        )
      end

      it "is enumerable" do
        AcceptHeader.include?(Enumerable).must_equal true
        accept_header.map { |v| v[:media_type] }[-2].must_equal long_header_ordered[-2]
      end

      it "tells you how many media ranges were parsed" do
        accept_header.length.must_equal long_header_ordered.length
      end

      it "gracefully handles not being given an accept header string" do
        AcceptHeader.new.length.must_equal 1
        AcceptHeader.new(nil).length.must_equal 1
        AcceptHeader.new(' ').length.must_equal 1
      end
    end
  end
end
