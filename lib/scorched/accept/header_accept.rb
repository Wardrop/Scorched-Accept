# encoding: US-ASCII
require 'parslet'

module Scorched
  module Accept
    DEFAULT_QVALUE = 1

    class HeaderAccept
      include Enumerable

      def initialize(raw_str)
        @raw_str = raw_str
      end

      # Returns true if the given media type is acceptable.
      def acceptable?(media_type)
        !matches(media_type).empty?
      end

      # Ranks the supplied media type based on its appropriatness. Scores range from 0 (the most appropriate), to
      # _n_-1, where _n_ is the number of media types defined in the accept header of the request. `nil` is returned if
      # the media type is unacceptable.
      def rank(media_type)
        match = matches(media_type).first
        match && match.last
      end

      # Of the media types given, returns the most appropriate. If none are appropriate, returns nil. If all media types
      # are of equal appropriatness, or multiple media types are equal best, the media type that was listed highest in
      # argument list is returned.
      def best_of(*media_types)
        media_types.min_by { |m| rank(m) }
      end

      # Returns a hash with each media range as the key, and the rest of the attributes as the value.
      # Possible attributes are: :parameters, :q, and :extensions.
      def to_h
        @to_h ||= ordered_values.map { |v|
          v = v.dup
          media_type = v.delete(:media_type)
          [media_type, v]
        }.to_h
      end

      def values
        @values ||= HeaderAcceptTransform.new.apply(HeaderAcceptParser.new.parse(@raw_str))
      end

      # Orders media ranges based on q-value, specificity, and the order they are defined
      def ordered_values
        @ordered_values ||= values.sort_by { |m| [m[:q] || DEFAULT_QVALUE, specificity(m)] }.reverse
      end

      # Enumerabilitisationing
      def each(*args, &block)
        ordered_values.each(*args, &block)
      end

      # Returns the number of media range definitions in the accept header of the request.
      def length
        values.length
      end

    protected

      def matches(media_type)
        matched = {}
        ordered_values.each_with_index do |v,i|
          matched[v] = i if Regexp.new(v[:media_type].split('/').map { |v| v == '*' ? '.+' : v }.join('/')) =~ media_type
        end
        matched
      end

      # Returns a number representing how specific the media range definition is. Higher numbers represent a more
      # specific media range definition.
      def specificity(m)
        if m[:media_type] == '*/*' then 0
        elsif m[:media_type] =~ %r{/\*$} then 1
        else 2 + (m[:parameters] ? m[:parameters].count : 0)
        end
      end
    end

    class HeaderAcceptParser < Parslet::Parser
      root(:accept)
      rule(:accept) { (accept_element >> (ows >> str(",") >> accept_element).repeat) >> ows }
      rule(:accept_element) { ows >> (media_range >> (ows >> accept_params).maybe).as(:accept_element) }
      rule(:media_range) { (str("*/*") | (token >> str('/') >> str('*').as(:subtype)) | (token >> str("/") >> token.as(:subtype))).as(:media_type) >> (ows >> str(";") >> ows >> parameter).repeat.as(:parameters) }
      rule(:accept_params) { str(";") >> ows >> str("q=") >> qvalue.as(:q) >> extension.repeat.as(:extensions) }
      rule(:extension) { ows >> str(";") >> ows >> token.as(:key) >> (str("=") >> (token | quoted_string).as(:value)).maybe }
      rule(:parameter) { str("q").absent? >> token.as(:key) >> str("=") >> (token | quoted_string).as(:value) }
      rule(:token) { tchar.repeat(1).as(:token) }
      rule(:qvalue) { (str("0") >> (str(".") >> digit.repeat(0,3)).maybe | str("1") >> (str(".") >> str("0").repeat(0,3)).maybe).as(:qvalue) }
      rule(:quoted_string) { str('"') >> (qdtext | quoted_pair).repeat.as(:quoted_string) >> str('"') }
      rule(:qdtext) { (match["\t !#-\\[\\]-~"] | obs_text).as(:qdtext) }
      rule(:obs_text) { match["\x80-\xFF"] }
      rule(:quoted_pair) { (str("\\") >> (match["\t "] | vchar | obs_text)).as(:quoted_pair) }
      rule(:tchar) { match["!#$%&'*+\\-.^_`|~"] | digit | alpha }
      rule(:vchar) { match["\x20-\x7E"] }
      rule(:ows) { match["\t "].repeat }
      rule(:alpha) { match["a-zA-Z"] }
      rule(:digit) { match["0-9"] }
    end

    class HeaderAcceptTransform < Parslet::Transform
      rule(accept_element: subtree(:x)) do
        x[:media_type] = (x[:media_type].respond_to? :values) ? x[:media_type].values.join("/") : x[:media_type].to_s
        x[:parameters] = x[:parameters].reduce(&:merge) if x[:parameters].respond_to? :reduce
        x[:extensions] = x[:extensions].reduce(&:merge) if x[:extensions].respond_to? :reduce
        x.delete_if { |k,v| v.nil? }
      end
      rule(media_type: subtree(:x)) { x.values.join('/') }
      rule(key: simple(:k), value: simple(:v)) { {k.to_sym => v} }
      rule(token: simple(:t)) { t.to_s }
      rule(quoted_string: sequence(:x)) { x.join }
      rule(qvalue: simple(:x)) { x.to_f }
      rule(qdtext: simple(:x)) { x.to_s }
      rule(quoted_pair: simple(:x)) { x.to_s[1] }
      rule(ows: simple(:x)) { " " }
    end
  end
end
