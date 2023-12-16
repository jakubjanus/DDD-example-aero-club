# frozen_string_literal: true

class PlanningDay
  AlreadyReserved = Class.new(StandardError)

  def initialize(day)
    @day = day
    @reservations = []
  end

  def reserve(aircraft, pilot)
    raise AlreadyReserved if reservations.map(&:aircraft).include?(aircraft)

    @reservations.push(Reservation.new(aircraft: aircraft, pilot: pilot))
  end

  attr_reader :reservations
end
