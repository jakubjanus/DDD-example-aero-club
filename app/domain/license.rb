# frozen_string_literal: true

class License
  def initialize(type:)
    @type = type
  end

  def sufficient_for?(aircraft)
    return aircraft.type == :glider if @type == :spl

    false
  end
end
