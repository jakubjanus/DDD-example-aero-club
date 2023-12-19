# frozen_string_literal: true

require 'securerandom'

module Planning
  class Pilot
    def initialize(pilot_id: SecureRandom.uuid, licenses: [])
      @id = pilot_id
      @licenses = licenses
    end

    attr_reader :id

    def add_license(license)
      @licenses.push(license)
    end

    def can_fly?(aircraft)
      @licenses.any? { |license| license.sufficient_for?(aircraft) }
    end

    def eql?(other)
      id == other.id
    end
  end
end
