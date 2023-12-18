# frozen_string_literal: true

module Planning
  class PlanningDay
    AlreadyReserved = Class.new(StandardError)
    OtherAircraftAlreadyReserved = Class.new(StandardError)
    InsufficientLicense = Class.new(StandardError)
    NoSuchReservation = Class.new(StandardError)

    def initialize(day)
      @day = day
      @reservations = []
    end

    def reserve(aircraft, pilot)
      raise AlreadyReserved if reservations.map(&:aircraft).include?(aircraft)
      raise OtherAircraftAlreadyReserved if reservations.map(&:pilot).include?(pilot)
      raise InsufficientLicense unless pilot.can_fly?(aircraft)

      reservation = Reservation.new(aircraft: aircraft, pilot: pilot)
      @reservations.push(reservation)
      reservation
    end

    def cancel(reservation_to_cancel)
      reservation = reservations.find { |r| r == reservation_to_cancel }
      raise NoSuchReservation unless reservation

      reservation.cancel
    end

    def active_reservations
      reservations.select(&:active?)
    end

    private

    attr_reader :reservations
  end
end
