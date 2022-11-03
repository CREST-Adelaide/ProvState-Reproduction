class CreateSoftware < ActiveRecord::Migration[6.0]
  def change
    create_table :softwares do |t|
    	t.belongs_to :device
    	t.string :name
    	t.text :description
    	t.string :operating_system
    	t.string :install_command

    end
  end
end
