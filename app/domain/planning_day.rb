# frozen_string_literal: true

class PlanningDay
  def initialize(day)
    @day = day
  end

  def reserve(aircraft, pilot)
    true
  end

  def reservations
    []
  end
end
