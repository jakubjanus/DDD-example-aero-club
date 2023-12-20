class CreatePlanningPilots < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_pilots, primary_key: 'pilot_id', id: :string do |t|
      t.json :licenses, null: false
      t.references :for_reservation, null: false, foreign_key: { to_table: :planning_reservations }

      t.timestamps
    end
  end
end
