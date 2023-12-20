require 'rails_helper'

RSpec.describe 'Renting an aircraft' do
  subject(:planning_day) { Planning::PlanningDay.new(day) }

  let(:day) { Date.parse('2023-06-01') }
  let(:airplane) { Planning::Aircraft.new(type: :airplane, registration_number: 'SP-ABC') }
  let(:glider) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-1234') }
  let(:pilot) { Planning::Pilot.new }

  context 'given a pilot with SPL license' do
    let(:spl_license) { Planning::License.create(:spl) }

    before do
      pilot.add_license(spl_license)
    end

    context 'given available glider' do
      it 'is possible to reserve glider for future date' do
        planning_day.reserve(glider, pilot)

        expect(planning_day.active_reservations.size).to eq 1
      end

      context 'given a glider is already reserved for a date' do
        let(:other_pilot) do
          Planning::Pilot.new.tap { |pilot| pilot.add_license(Planning::License.create(:spl)) }
        end

        before do
          planning_day.reserve(glider, other_pilot)
        end

        it 'is not possible to reserve a glider' do
          expect { planning_day.reserve(glider, pilot) }.to raise_error Planning::PlanningDay::AlreadyReserved
        end
      end

      context 'given pilot has already reserved other aircraft' do
        let(:other_aircraft) { Planning::Aircraft.new(type: :glider, registration_number: 'SP-2345') }

        before { planning_day.reserve(other_aircraft, pilot) }

        it 'is not possible to reserve another aircraft' do
          expect { planning_day.reserve(glider, pilot)}.to raise_error Planning::PlanningDay::OtherAircraftAlreadyReserved
        end

        it 'reservation can be canceled' do
          reservation = planning_day.active_reservations.first
          planning_day.cancel(reservation)

          expect(planning_day.active_reservations).to be_empty
        end

        it 'cannot cancel reservation from other planning day' do
          other_planning_day = Planning::PlanningDay.new(Date.parse('2023-06-02'))
          other_reservation = other_planning_day.reserve(glider, pilot)

          expect { planning_day.cancel(other_reservation) }.to raise_error Planning::PlanningDay::NoSuchReservation
        end

        it 'it is possible to cancel and reserve other aircraft' do
          reservation = planning_day.active_reservations.first
          planning_day.cancel(reservation)
          planning_day.reserve(other_aircraft, pilot)

          expect(planning_day.active_reservations.size).to eq 1
          expect(planning_day.active_reservations.first.aircraft).to eq other_aircraft
        end
      end
    end

    it 'cannot reserve airplane (due to insufficient license)' do
      expect { planning_day.reserve(airplane, pilot) }.to raise_error Planning::PlanningDay::InsufficientLicense
    end
  end

  context 'given a pilot without active license' do
    it "can't reserve an aircraft" do
      expect { planning_day.reserve(glider, pilot) }.to raise_error Planning::PlanningDay::InsufficientLicense
    end
  end

  context 'given a pilot with active PPL license' do
    let(:ppl_license) { Planning::License.create(:ppl) }

    before do
      pilot.add_license(ppl_license)
    end

    it 'can reserve airplane' do
      planning_day.reserve(airplane, pilot)

      expect(planning_day.active_reservations.size).to eq 1
    end

    it 'cannot reserve glider' do
      expect { planning_day.reserve(glider, pilot) }.to raise_error Planning::PlanningDay::InsufficientLicense
    end
  end
end
