# frozen_string_literal: true

module Planning
  module Repositories
    module PlanningDayRepositories
      class Database
        def find_for_day(day)
          db_record = PlanningDayRecord.find_by(day: day)
          return nil unless db_record

          PlanningDay.new(db_record.day, reservations: db_record.reservation_records.map(&:to_entity))
        end

        def store(planning_day)
          PlanningDayRecord.transaction do
            record = PlanningDayRecord.find_by(day: planning_day.day)

            record.present? ? update_record(planning_day, record) : create_record(planning_day)
          end
        end

        private

        def create_record(planning_day)
          planning_day_record = PlanningDayRecord.create!(day: planning_day.day)

          planning_day.send(:reservations).each do |reservation|
            reservation_record = ReservationRecord.from_entity(reservation)
            reservation_record.planning_day_record = planning_day_record
            reservation_record.save!
          end
        end

        def update_record(planning_day, planning_day_record)
          reservation_records = planning_day.send(:reservations).map do |reservation|
            reservation_record = planning_day_record.reservation_records
                                                    .find { _1.reservation_number == reservation.reservation_number }
            if reservation_record
              reservation_record.assign_from_entity(reservation)
              reservation_record.pilot_record.save!
              reservation_record.aircraft_record.save!
            end

            reservation_record ||= ReservationRecord.from_entity(reservation)

            reservation_record
          end

          planning_day_record.reservation_records = reservation_records
          planning_day_record.save!
        end

        class PlanningDayRecord < ApplicationRecord
          self.table_name = 'planning_planning_days'

          has_many :reservation_records,
                   class_name: 'Planning::Repositories::PlanningDayRepositories::Database::ReservationRecord',
                   foreign_key: 'for_planning_day_id'

        end

        class ReservationRecord < ApplicationRecord
          self.table_name = 'planning_reservations'

          belongs_to :planning_day_record,
                     class_name: 'Planning::Repositories::PlanningDayRepositories::Database::PlanningDayRecord',
                     foreign_key: 'for_planning_day_id'
          has_one :pilot_record,
                  class_name: 'Planning::Repositories::PlanningDayRepositories::Database::PilotRecord',
                  foreign_key: 'for_reservation_id'
          has_one :aircraft_record,
                  class_name: 'Planning::Repositories::PlanningDayRepositories::Database::AircraftRecord',
                  foreign_key: 'for_reservation_id'

          class << self
            def from_entity(reservation)
              new(
                reservation_number: reservation.reservation_number,
                canceled: reservation.canceled?,
                pilot_record: PilotRecord.from_entity(reservation.pilot),
                aircraft_record: AircraftRecord.from_entity(reservation.aircraft)
              )
            end
          end

          def assign_from_entity(reservation)
            assign_attributes(
              reservation_number: reservation.reservation_number,
              canceled: reservation.canceled?
            )
            pilot_record.assign_from_entity(reservation.pilot)
            aircraft_record.assign_from_entity(reservation.aircraft)
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
                     class_name: 'Planning::Repositories::PlanningDayRepositories::Database::ReservationRecord',
                     foreign_key: 'for_reservation_id'

          class << self
            def from_entity(pilot)
              new(
                licenses: pilot.instance_variable_get('@licenses').map { { 'type' => _1.type } },
                pilot_id: pilot.id
              )
            end
          end

          def assign_from_entity(pilot)
            assign_attributes(
              licenses: pilot.instance_variable_get('@licenses').map { { 'type' => _1.type } },
              pilot_id: pilot.id
            )
          end
        end

        class AircraftRecord < ApplicationRecord
          self.table_name = 'planning_aircrafts'
          self.inheritance_column = '_inheritance_disabled'

          belongs_to :reservation_record,
                     class_name: 'Planning::Repositories::PlanningDayRepositories::Database::ReservationRecord',
                     foreign_key: 'for_reservation_id'

          class << self
            def from_entity(aircraft)
              new(
                type: aircraft.type,
                registration_number: aircraft.registration_number
              )
            end
          end

          def assign_from_entity(aircraft)
            assign_attributes(
              type: aircraft.type,
              registration_number: aircraft.registration_number
            )
          end
        end
      end
    end
  end
end
