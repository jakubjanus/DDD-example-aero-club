require 'rails_helper'

RSpec.describe 'Renting an aircraft' do
  subject(:repository) { Planning::PlanningDayRepository.new }

  let(:day) { Date.parse('2023-12-01') }

  it 'stores and reads empty PlanningDay' do
    empty_planning_day = Planning::PlanningDay.new(day)

    repository.store(empty_planning_day)
    repo_instance = repository.find_for_day(day)

    expect(repo_instance).not_to be_nil
    expect(repo_instance.day).to eq day
    expect(repo_instance.active_reservations).to eq []
  end

  it 'stores PlanningDay with some reservations' do
    aircraft = Planning::Aircraft.new(type: :glider, registration_number: 'SP-1234')
    pilot = Planning::Pilot.new(licenses: [Planning::License.create(:spl)])
    reservation = Planning::Reservation.new(aircraft: aircraft, pilot: pilot)
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
end
