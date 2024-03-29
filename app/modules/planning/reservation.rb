# frozen_string_literal: true

require 'securerandom'

module Planning
  class Reservation
    def initialize(aircraft:, pilot:, reservation_number: SecureRandom.alphanumeric, canceled: false)
      @aircraft = aircraft
      @pilot = pilot
      @reservation_number = reservation_number
      @canceled = canceled
    end

    def eql?(other)
      reservation_number == other.reservation_number
    end
    alias :== eql?

    def cancel
      @canceled = true
    end

    def active?
      !canceled?
    end

    def canceled?
      @canceled
    end

    attr_reader :aircraft, :pilot, :reservation_number
  end
end
