module Rack
  class Acceptable
    class Accept
      def initialize(raw_str)
        @raw_str = raw_str
      end
      
      # Returns true if the given media type is acceptable.
      def acceptable?(media_type)
        
      end
      
      # Scores the supplied media type based on its appropriatness. Scores range from 0 (the most appropriate), to 
      # _n_-1, where _n_ is the number of media types defined in the accept header of the request. `nil` is returned if
      # the media type is unacceptable.
      def score(media_type)
        
      end
      
      # Of the media types given, returns the most appropriate. If none are appropriate, returns nil. If all media types
      # are of equal appropriatness, or multiple media types are equal best, the media type that was listed highest in
      # argument list is returned.
      def best_of(*media_types)
        
      end
      
      def to_h
        @to_h ||= ordered_values.map { |v|
          v = v.dup
          media_type = v.delete(:media_type)
          [media_type, v]
        }.to_h
      end
      
      def values
        @values ||= Parsers.parse(:AcceptParser, @raw_str)
      end
      
      # Orders the media types included in the accept header based on their qvalue, preserving their natural order where
      # qvalue's are identical.
      def ordered_values
        @ordered_values ||= values.sort_by { |a,b|   }
      end
      
      # Returns the number of media type definitions in the accept header of the request.
      def length
        values.length
      end
    end
  end
end