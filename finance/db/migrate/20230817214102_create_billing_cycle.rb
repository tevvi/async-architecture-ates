class CreateBillingCycle < ActiveRecord::Migration[7.0]
  def change
    create_table :billing_cycles do |t|
      t.string :account_public_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.timestamps
    end
  end
end
