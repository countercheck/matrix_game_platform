class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :name, null: false, limit: 100
      t.text :description, null: false
      t.integer :max_participants, null: false
      t.integer :min_participants, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :games, :name, unique: true
    add_check_constraint :games, 'max_participants > 0', name: 'max_participants_positive'
    add_check_constraint :games, 'min_participants > 0', name: 'min_participants_positive'
    add_check_constraint :games, 'max_participants >= min_participants', 
                         name: 'max_gte_min_participants'
  end
end
