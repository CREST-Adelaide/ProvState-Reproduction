class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.string :name
      t.bigint :group_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :host
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
