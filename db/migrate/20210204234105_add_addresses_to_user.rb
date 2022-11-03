class AddAddressesToUser < ActiveRecord::Migration[6.0]
  def change
  	add_column :users, :private_key, :string
  end
end
