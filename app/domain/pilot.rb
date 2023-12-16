# frozen_string_literal: true

require 'securerandom'

class Pilot
  def initialize(pilot_id: SecureRandom.uuid)
    @id = pilot_id
    @licenses = []
  end

  def add_license(license)
    @licenses.push(license)
  end
end
