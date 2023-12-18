# frozen_string_literal: true

class PlanningDay
  AlreadyReserved = Class.new(StandardError)
  OtherAircraftAlreadyReserved = Class.new(StandardError)
  InsufficientLicense = Class.new(StandardError)

  def initialize(day)
    @day = day
    @reservations = []
  end

  def reserve(aircraft, pilot)
    raise AlreadyReserved if reservations.map(&:aircraft).include?(aircraft)
    raise OtherAircraftAlreadyReserved if reservations.map(&:pilot).include?(pilot)
    raise InsufficientLicense unless pilot.can_fly?(aircraft)

    @reservations.push(Reservation.new(aircraft: aircraft, pilot: pilot))
  end

  attr_reader :reservations
end
