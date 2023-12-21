# frozen_string_literal: true

module Api
  module Planning
    class ReservationsController < ApiController
      def index
        reservations = ::Planning::PlanningDayRepository::ReservationRecord.all

        render json: { reservations: reservations.map(&:as_json) }
      end

      def create
        repository = ::Planning::PlanningDayRepository.new
        day = Date.parse(reservation_params['date'])
        planning_day = repository.find_for_day(day) || ::Planning::PlanningDay.new(day)
        aircraft = ::Planning::Aircraft.new(
          type: reservation_params['aircraft']['type'].to_sym,
          registration_number: reservation_params['aircraft']['registration_number']
        )
        pilot = ::Planning::Pilot.new(
          licenses: reservation_params['pilot']['licenses'].map { ::Planning::License.create(_1) }
        )
        reservation = planning_day.reserve(aircraft, pilot)
        repository.store(planning_day)

        render json: { reservation_number: reservation.reservation_number }
      rescue ::Planning::PlanningDay::DomainError => e
        render json: { error_type: e.class, error_message: e.message }, status: 422
      end

      private

      def reservation_params
        params[:reservation].as_json
      end

    end
  end
end