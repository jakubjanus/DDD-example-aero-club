# frozen_string_literal: true

module Planning
  class License
    class << self
      def create(type)
        if type.to_sym == :spl
          Spl.new
        elsif type.to_sym == :ppl
          Ppl.new
        else
          raise "Unknown type: #{type}"
        end
      end
    end

    def sufficient_for?(_aircraft)
      raise 'Not implemented'
    end

    def type
      raise 'Not implemented'
    end

    def eql?(other)
      type == other.type
    end
    alias :== eql?

    class Spl < License
      def sufficient_for?(aircraft)
        aircraft.type == :glider
      end

      def type
        :spl
      end
    end

    class Ppl < License
      def sufficient_for?(aircraft)
        aircraft.type == :airplane
      end

      def type
        :ppl
      end
    end
  end
end
