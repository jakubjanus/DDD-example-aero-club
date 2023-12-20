require 'rails_helper'

RSpec.describe 'Renting an aircraft' do
  subject(:repository) { Planning::PlanningDayRepository.new }

  let(:day) { Date.parse('2023-12-01') }
  let(:aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-1234') }
  let(:pilot) { Planning::Pilot.new(licenses: [Planning::License.create(:spl)]) }
  let(:reservation) { Planning::Reservation.new(aircraft: aircraft, pilot: pilot) }

  it 'stores and reads empty PlanningDay' do
    empty_planning_day = Planning::PlanningDay.new(day)

    repository.store(empty_planning_day)
    repo_instance = repository.find_for_day(day)

    expect(repo_instance).not_to be_nil
    expect(repo_instance.day).to eq day
    expect(repo_instance.active_reservations).to eq []
  end

  it 'stores PlanningDay with some reservations' do
    planning_day = Planning::PlanningDay.new(day, reservations: [reservation])

    repository.store(planning_day)
    repo_instance = repository.find_for_day(day)

    expect(repo_instance).not_to be_nil
    expect(repo_instance.day).to eq day
    expect(repo_instance.active_reservations).to eq [reservation]

    # reservation
    expect(repo_instance.active_reservations.first.aircraft).to eq aircraft
    expect(repo_instance.active_reservations.first.pilot).to eq pilot
    expect(repo_instance.active_reservations.first.canceled?).to eq false

    # pilot
    expect(repo_instance.active_reservations.first.pilot.id).to eq pilot.id
    expect(repo_instance.active_reservations.first.pilot.instance_variable_get('@licenses')).to eq pilot.instance_variable_get('@licenses')

    # aircraft
    expect(repo_instance.active_reservations.first.aircraft.type).to eq aircraft.type
    expect(repo_instance.active_reservations.first.aircraft.registration_number).to eq aircraft.registration_number
  end

  context 'when PlanningDay is already stored in the repo' do
    let(:planning_day) { Planning::PlanningDay.new(day, reservations: [reservation]) }
    let(:other_aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-2345') }
    let(:other_pilot) { Planning::Pilot.new(licenses: [Planning::License.create(:spl)]) }

    before { repository.store(planning_day) }

    it 'stores all changes in the repo' do
      ppl_license = Planning::License.create(:ppl)
      pilot.add_license(ppl_license)
      planning_day.reserve(other_aircraft, other_pilot)

      repository.store(planning_day)
      repo_instance = repository.find_for_day(day)

      expect(repo_instance.active_reservations.first.pilot.instance_variable_get('@licenses')).to include ppl_license
      expect(repo_instance.active_reservations.size).to eq 2
    end
  end
end
