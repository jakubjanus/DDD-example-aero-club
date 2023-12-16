# frozen_string_literal: true

class PlanningDay
  def initialize(day)
    @day = day
    @reservations = []
  end

  def reserve(aircraft, pilot)
    @reservations.push(Reservation.new(aircraft: aircraft, pilot: pilot))
  end

  attr_reader :reservations
end
