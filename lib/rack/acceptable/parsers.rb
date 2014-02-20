require 'treetop'

module Rack
  class Acceptable
    module Parsers
      Dir.glob(File.join(__dir__, 'parsers/*.treetop')).each do |f|
        class_eval Treetop::Compiler::GrammarCompiler.new.ruby_source_from_string(File.read(f))
      end
      
      class SyntaxNode < Treetop::Runtime::SyntaxNode
        def to_value
          a = (elements || []).select { |e| e.respond_to? :to_value }.map(&:to_value).compact
          if a.empty?
            nil
          elsif a.length == 1
            a[0]
          else
            a
          end
        end
        
        # Wraps element in array if not already
        def array_wrap(value)
          (Array === value ? value : [value]).compact
        end
      end
    
      def self.parse(parser_name, str)
        parser = const_get(parser_name).new
        result = parser.parse(str)
        unless result
          raise RuntimeError, "Parsing failed at offset #{parser.index}. The reason was: #{parser.failure_reason}"
        end
        result.to_value 
      end
    end
  end
end
