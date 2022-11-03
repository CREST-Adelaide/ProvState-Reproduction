class AddOperatingSystemToDevices < ActiveRecord::Migration[6.0]
  def change
  	add_column :devices, :operating_system, :string
  end
end
