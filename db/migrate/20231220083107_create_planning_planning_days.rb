class CreatePlanningPlanningDays < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_planning_days do |t|
      t.date :day, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
