class CreatePlanningReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_reservations do |t|
      t.string :reservation_number, index: true
      t.boolean :canceled, default: false
      t.references :for_planning_day, null: false, foreign_key: { to_table: :planning_planning_days }

      t.timestamps
    end
  end
end
