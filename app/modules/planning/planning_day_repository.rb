# frozen_string_literal: true

module Planning
  class PlanningDayRepository
    def find_for_day(day)
      db_record = PlanningDayRecord.find_by(day: day)
      return nil unless db_record

      PlanningDay.new(db_record.day, reservations: db_record.reservation_records.map(&:to_entity))
    end

    def store(planning_day)
      PlanningDayRecord.transaction do
        planning_day_record = PlanningDayRecord.create!(day: planning_day.day)

        planning_day.send(:reservations).each do |reservation|
          reservation_record = ReservationRecord.from_entity(reservation)
          reservation_record.planning_day_record = planning_day_record
          reservation_record.save!

          PilotRecord.from_entity(reservation.pilot).tap { _1.reservation_record = reservation_record }.save!
          AircraftRecord.from_entity(reservation.aircraft).tap { _1.reservation_record = reservation_record }.save!
        end
      end
    end

    class PlanningDayRecord < ApplicationRecord
      self.table_name = 'planning_planning_days'

      has_many :reservation_records,
               class_name: 'Planning::PlanningDayRepository::ReservationRecord',
               foreign_key: 'for_planning_day_id'

    end

    class ReservationRecord < ApplicationRecord
      self.table_name = 'planning_reservations'

      belongs_to :planning_day_record,
                 class_name: 'Planning::PlanningDayRepository::PlanningDayRecord',
                 foreign_key: 'for_planning_day_id'
      has_one :pilot_record,
              class_name: 'Planning::PlanningDayRepository::PilotRecord',
              foreign_key: 'for_reservation_id'
      has_one :aircraft_record,
              class_name: 'Planning::PlanningDayRepository::AircraftRecord',
              foreign_key: 'for_reservation_id'

      class << self
        def from_entity(reservation)
          new(
            reservation_number: reservation.reservation_number,
            canceled: reservation.canceled?
          )
        end
      end

      def to_entity
        Reservation.new(
          pilot: Pilot.new(
            pilot_id: pilot_record.pilot_id,
            licenses: pilot_record.licenses.map { License.create(_1['type']) }
          ),
          aircraft: Aircraft.new(
            type: aircraft_record.type.to_sym,
            registration_number: aircraft_record.registration_number
          ),
          reservation_number: reservation_number,
          canceled: canceled
        )
      end
    end

    class PilotRecord < ApplicationRecord
      self.table_name = 'planning_pilots'

      belongs_to :reservation_record,
                 class_name: 'Planning::PlanningDayRepository::ReservationRecord',
                 foreign_key: 'for_reservation_id'

      class << self
        def from_entity(pilot)
          new(
            licenses: pilot.instance_variable_get('@licenses').map { { 'type' => _1.type } },
            pilot_id: pilot.id
          )
        end
      end
    end

    class AircraftRecord < ApplicationRecord
      self.table_name = 'planning_aircrafts'
      self.inheritance_column = '_inheritance_disabled'

      belongs_to :reservation_record,
                 class_name: 'Planning::PlanningDayRepository::ReservationRecord',
                 foreign_key: 'for_reservation_id'

      class << self
        def from_entity(aircraft)
          new(
            type: aircraft.type,
            registration_number: aircraft.registration_number
          )
        end
      end
    end
  end
end