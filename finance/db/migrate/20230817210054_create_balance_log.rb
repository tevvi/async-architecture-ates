class CreateBalanceLog < ActiveRecord::Migration[7.0]
  def change
    create_table :balance_logs do |t|
      t.string :account_public_id, null: false
      t.integer :billing_cycle_id, null: false
      t.string :log_type, null: false
      t.string :description, null: false
      t.integer :credit, null: false, default: 0, unsigned: true
      t.integer :debit, null: false, default: 0, unsigned: true
      t.jsonb :metadata, null: false, default: '{}'

      t.timestamps
    end
  end
end
