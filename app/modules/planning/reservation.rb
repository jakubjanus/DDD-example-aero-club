# frozen_string_literal: true

module Planning
  class Reservation
    def initialize(aircraft:, pilot:)
      @aircraft = aircraft
      @pilot = pilot
    end

    attr_reader :aircraft, :pilot
  end
end
