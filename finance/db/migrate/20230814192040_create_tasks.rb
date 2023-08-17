class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :description, null: false
      t.string :status, null: false
      t.uuid :public_id, null: false
      t.uuid :account_public_id, null: false
      t.integer :fee, null: false
      t.integer :price, null: false
      t.datetime :finished_at

      t.timestamps
    end
  end
end
