require 'rails_helper'

RSpec.describe Planning::Application::ReservationService do
  subject(:reservation_service) { described_class.new(planning_day_repository: repository) }

  let(:repository) { Planning::Repositories::PlanningDayRepositories::InMemory.new }

  describe 'making reservation' do
    let(:params) do
      {
        date: '2023-12-01',
        pilot: { licenses: ['spl'] },
        aircraft: { type: 'glider', registration_number: 'SP-2222' }
      }
    end

    it 'stores new planning day with reservation in repository' do
      reservation_service.make_reservation(params)
      planning_day = repository.find_for_day(Date.parse('2023-12-01'))

      expect(planning_day).not_to be_nil
      expect(planning_day.active_reservations.size).to eq 1
    end

    describe 'params validation' do
      it 'fails if date is missing' do
        expect do
          reservation_service.make_reservation(params.without(:date))
        end.to raise_error Planning::Application::ReservationService::ValidationError
      end
    end

    context 'when there already is other reservation for the day' do
      before do
        reservation_service.make_reservation(
          {
            date: '2023-12-01',
            pilot: { licenses: ['spl'] },
            aircraft: { type: 'glider', registration_number: 'SP-3333' }
          }
        )
      end

      it 'adds another reservation for planning day' do
        reservation_service.make_reservation(params)
        planning_day = repository.find_for_day(Date.parse('2023-12-01'))

        expect(planning_day.active_reservations.size).to eq 2
      end
    end
  end
end
