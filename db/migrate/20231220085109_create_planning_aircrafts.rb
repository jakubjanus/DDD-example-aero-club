class CreatePlanningAircrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_aircrafts do |t|
      t.string :type, null: false
      t.string :registration_number, null: false, index: true
      t.references :for_reservation, null: false, foreign_key: { to_table: :planning_reservations }

      t.timestamps
    end
  end
end
