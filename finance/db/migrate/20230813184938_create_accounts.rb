class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :email,              null: false
      t.uuid :public_id, null: false
      t.string :role, null: false
      t.integer :balance, null: false, default: 0

      t.timestamps
    end
  end
end
