# frozen_string_literal: true

module Planning
  module Application
    class ReservationService
      def initialize(planning_day_repository:)
        @planning_day_repository = planning_day_repository
      end

      def make_reservation(params)
        day = Date.parse(params[:date])
        planning_day = @planning_day_repository.find_for_day(day) || ::Planning::PlanningDay.new(day)
        aircraft = ::Planning::Aircraft.new(
          type: params[:aircraft][:type].to_sym,
          registration_number: params[:aircraft][:registration_number]
        )
        pilot = ::Planning::Pilot.new(
          licenses: params[:pilot][:licenses].map { ::Planning::License.create(_1) }
        )
        reservation = planning_day.reserve(aircraft, pilot)
        @planning_day_repository.store(planning_day)

        reservation
      end
    end
  end
end