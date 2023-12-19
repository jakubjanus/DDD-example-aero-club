# frozen_string_literal: true

module Planning
  class License
    class << self
      def create(type)
        if type == :spl
          Spl.new
        elsif type == :ppl
          Ppl.new
        else
          raise "Unknown type: #{type}"
        end
      end
    end

    def sufficient_for?(_aircraft)
      raise 'Not implemented'
    end

    class Spl < License
      def sufficient_for?(aircraft)
        aircraft.type == :glider
      end
    end

    class Ppl < License
      def sufficient_for?(aircraft)
        aircraft.type == :airplane
      end
    end
  end
end
