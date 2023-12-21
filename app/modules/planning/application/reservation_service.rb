# frozen_string_literal: true

module Planning
  module Application
    class ReservationService
      class ValidationError < StandardError
        def initialize(errors)
          super("Validation failed with errors: #{errors.to_h}")
        end
      end

      def initialize(planning_day_repository:)
        @planning_day_repository = planning_day_repository
      end

      def make_reservation(params)
        validate_reservation_params!(params)

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

      private

      def validate_reservation_params!(params)
        validation = ReservationParams.new.call(params)
        return if validation.success?

        raise ValidationError.new(validation.errors)
      end

      class ReservationParams < Dry::Validation::Contract
        params do
          required(:date).filled(:string)

          required(:aircraft).hash do
            required(:type).filled(:string)
            required(:registration_number).filled(:string)
          end

          required(:pilot).hash do
            required(:licenses).array(:str?)
            optional(:pilot_id).filled(:string)
          end
        end
      end
    end
  end
end