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
      let(:aircraft) { Aircraft.new(type: :glider, registration_number: 'SP-1234') }

      it 'is possible to reserve glider for future date' do
        planning_day.reserve(aircraft, pilot)

        expect(planning_day.reservations.size).to eq 1
      end

      context 'given a glider is already reserved for a date' do
        let(:other_pilot) do
          Pilot.new.tap { |pilot| pilot.add_license(License.new(type: :spl)) }
        end

        before do
          planning_day.reserve(aircraft, other_pilot)
        end

        it 'is not possible to reserve a glider' do
          expect { planning_day.reserve(aircraft, pilot) }.to raise_error PlanningDay::AlreadyReserved
        end
      end
    end
  end
end
