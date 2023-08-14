class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :email,              null: false, default: ""
      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end
