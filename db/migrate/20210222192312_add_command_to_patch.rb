class AddCommandToPatch < ActiveRecord::Migration[6.0]
  def change
  	add_column :patches, :operating_system, :string
  	add_column :patches, :install_command, :string
  	add_column :patches, :software_name, :string
  end
end
