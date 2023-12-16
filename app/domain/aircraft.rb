# frozen_string_literal: true

class Aircraft
  def initialize(type:, registration_number:)
    @type = type
    @registration_number = registration_number
  end

  attr_reader :registration_number

  def eql?(other)
    registration_number == other.registration_number
  end
end
