require 'rails_helper'

RSpec.describe 'Renting an aircraft' do
  let(:day) { Date.parse('2023-06-01') }
  subject(:planning_day) { Planning::PlanningDay.new(day) }

  context 'given a pilot with SPL license' do
    let(:spl_license) { Planning::License.new(type: :spl) }
    let(:pilot) { Planning::Pilot.new }

    before do
      pilot.add_license(spl_license)
    end

    context 'given available glider' do
      let(:aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-1234') }

      it 'is possible to reserve glider for future date' do
        planning_day.reserve(aircraft, pilot)

        expect(planning_day.active_reservations.size).to eq 1
      end

      context 'given a glider is already reserved for a date' do
        let(:other_pilot) do
          Planning::Pilot.new.tap { |pilot| pilot.add_license(Planning::License.new(type: :spl)) }
        end

        before do
          planning_day.reserve(aircraft, other_pilot)
        end

        it 'is not possible to reserve a glider' do
          expect { planning_day.reserve(aircraft, pilot) }.to raise_error Planning::PlanningDay::AlreadyReserved
        end
      end

      context 'given pilot has already reserved other aircraft' do
        let(:other_aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-2345') }

        before { planning_day.reserve(other_aircraft, pilot) }

        it 'is not possible to reserve another aircraft' do
          expect { planning_day.reserve(aircraft, pilot)}.to raise_error Planning::PlanningDay::OtherAircraftAlreadyReserved
        end

        it 'reservation can be canceled' do
          reservation = planning_day.active_reservations.first
          planning_day.cancel(reservation)

          expect(planning_day.active_reservations).to be_empty
        end

        it 'cannot cancel reservation from other planning day' do
          other_planning_day = Planning::PlanningDay.new(Date.parse('2023-06-02'))
          other_reservation = other_planning_day.reserve(aircraft, pilot)

          expect { planning_day.cancel(other_reservation) }.to raise_error Planning::PlanningDay::NoSuchReservation
        end
      end
    end
  end

  context 'given a pilot without active license' do
    let(:pilot) { Planning::Pilot.new }
    let(:aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-1234') }

    it "can't reserve an aircraft" do
      expect { planning_day.reserve(aircraft, pilot) }.to raise_error Planning::PlanningDay::InsufficientLicense
    end
  end
end
