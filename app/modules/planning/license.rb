# frozen_string_literal: true

module Planning
  class License
    def initialize(type:)
      @type = type
    end

    def sufficient_for?(aircraft)
      return aircraft.type == :glider if @type == :spl
      return aircraft.type == :airplane if @type == :ppl

      false
    end
  end
end
