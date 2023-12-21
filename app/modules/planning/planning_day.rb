# frozen_string_literal: true

module Planning
  class PlanningDay
    DomainError = Class.new(StandardError)
    AlreadyReserved = Class.new(DomainError)
    OtherAircraftAlreadyReserved = Class.new(DomainError)
    InsufficientLicense = Class.new(DomainError)
    NoSuchReservation = Class.new(DomainError)

    def initialize(day, reservations: [])
      @day = day
      @reservations = reservations
    end

    def reserve(aircraft, pilot)
      raise AlreadyReserved if active_reservations.map(&:aircraft).include?(aircraft)
      raise OtherAircraftAlreadyReserved if active_reservations.map(&:pilot).include?(pilot)
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

    attr_reader :day

    private

    attr_reader :reservations
  end
end
