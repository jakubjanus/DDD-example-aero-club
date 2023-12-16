require 'rails_helper'

RSpec.describe 'Renting an aircraft' do
  let(:day) { Date.parse('2023-06-01') }
  subject(:planning_day) { PlanningDay.new(day) }

  context 'given a pilot with SPL licence' do
    let(:spl_license) { License.new(type: :spl) }
    let(:pilot) { Pilot.new }

    before do
      pilot.add_license(spl_license)
    end

    context 'given available glider' do
      let(:aircraft) { Aircraft.new(type: :glider) }

      it 'is possible to reserve glider for future date' do
        planning_day.reserve(aircraft, pilot)

        expect(planning_day.reservations.size).to eq 1
      end

      context 'given a glider is already reserved for a date' do
        it 'is not possible to reserve a glider' do

        end
      end
    end

    context 'given glider which is unavailable' do
      it 'is not possible to reserve glider' do

      end
    end
  end
end
