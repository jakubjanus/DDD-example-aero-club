# frozen_string_literal: true

module Api
  module Planning
    class ReservationsController < ApiController
      def index
        reservations = ::Planning::PlanningDayRepository::ReservationRecord.all

        render json: { reservations: reservations.map(&:as_json) }
      end

      def create
        reservation = reservation_service.make_reservation(reservation_params)

        render json: { reservation_number: reservation.reservation_number }
      rescue ::Planning::PlanningDay::DomainError => e
        render json: { error_type: e.class, error_message: e.message }, status: 422
      end

      private

      def reservation_params
        params
          .require(:reservation)
          .permit(:date, pilot: [{licenses: []}, :pilot_id], aircraft: [:type, :registration_number]).to_h
      end

      def reservation_service
        ::Planning::Application::ReservationService.new(planning_day_repository: planning_day_repository)
      end

      def planning_day_repository
        ::Planning::PlanningDayRepository.new
      end

    end
  end
end