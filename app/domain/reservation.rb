# frozen_string_literal: true

class Reservation
  def initialize(aircraft:, pilot:)
    @aircraft = aircraft
    @pilot = pilot
  end

  attr_reader :aircraft, :pilot
end
