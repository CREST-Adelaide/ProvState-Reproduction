class DevicesController < ApplicationController
	include SessionHelper
	extend ActiveModel::Naming
	require 'net/ssh'

	def index
		@devices = Device.all.where(group_id: session[:group])


 	end

 	def add_device
 		@device = Device.new
 	end

 	def create
 		errors = ActiveModel::Errors.new(self)
 		@device = Device.create(params.require(:device).permit(:name, :host, :username, :password, :operating_system, :start_time, :end_time))
 		@device.group_id = session[:group]
 		@device.save
 		notifications_array = []

			begin
				Net::SSH.start(@device.host, @device.username, password: @device.password, timeout: 3) do |ssh|
					output = ""
					timeout 5 do
						output = ssh.exec!("sudo apt-get")
					end

					if output.include? "apt-get is a command line interface"
						notifications_array.push('Device successfully added to system')

					else
						errors.add(:base, "Supplied user must not have root access and be on the list of sudoers.")
						throw(:abort)
					end

					notifications_array.each do |notif|
						ssh.exec!("DISPLAY=:0 notify-send '"+notif+"'")
					end

				end

			rescue Net::SSH::ConnectionTimeout => e
				errors.add(:base, "Could not connect to device with provided details. Connection timed out. Check the device is on and the details are correct.")
				throw(:abort)
			end
  	 	redirect_to '/devices'
 	end

 	def show
 		update_asset_array
 		@device = Device.find(params[:id])
 		@softwares = Software.all.where(device_id: params[:id])

 		group_id = session[:group]
	    @group_name = $contract.call.get_group_name(group_id)



	    i = 0
	    j = 0
	    @dev_asset_array = Array.new
	    @applied_assets= Array.new
	    applied_asset_count = 0;
	    $asset_count = $state_contract.call.asset_count
	    puts $asset_count

	    while (i < $asset_count)
	    	
	    	if $asset_array[i][:device] == @device.name
	    		@applied_assets.push($asset_array[i])
	    	end
	    	while (j < @softwares.length)
	    		if $asset_array[i][:software_name] == @softwares[j].name && $asset_array[i][:device] != @device.name	#loop through asset array to see if any assets belong to a software that is installed on the device
	    			@dev_asset_array.push($asset_array[i])

	    			j += 1
	    		else
	    			j += 1
	    		end
	    	end
	    	i += 1
	    	j = 0
	    end

 	end

 	def add_software
 		@software = Software.new
 	end

 	def apply_patch
 		@device = Device.find(params[:id])
 		@softwares = Software.all.where(device_id: params[:id])


	    pid = params[:patch_id].to_i

	    $state_contract.transact_and_wait.copy_patch(pid)
	    copied_asset_id = $state_contract.call.asset_count
	    $state_contract.transact_and_wait.apply_device(copied_asset_id - 1, @device.name)

	    update_asset_array

	    redirect_to device_path(params[:id])
 	end

 	def transition
 		@device = Device.find(params[:id])
 		sname = $state_contract.call.get_asset_name(params[:aid].to_i)

    	sha_calc = Digest::SHA256.hexdigest sname
    	$state_contract.transact_and_wait.transition(params[:aid].to_i, params[:state], $role_id.to_i, sha_calc)

    	current_state = $state_contract.call.get_current_state(params[:aid].to_i)

    	if current_state == $state_final

    		notifications_array = []
			begin

				Net::SSH.start(@device.host, @device.username, password: @device.password, timeout: 3) do |ssh|
					output = ""
					timeout 5 do
						output = ssh.exec!("sudo apt-get")
					end

					output2 = ssh.exec!("sudo apt-get --assume-yes install audacity")
					puts output2
					notifications_array.push("Audacity has been updated")

					notifications_array.each do |notif|
						ssh.exec!("DISPLAY=:0 notify-send '"+notif+"'")
					end

				end

			rescue Net::SSH::ConnectionTimeout => e
				errors.add(:base, "Could not connect to device with provided details. Connection timed out. Check the device is on and the details are correct.")
				throw(:abort)
			end
 		redirect_to device_path(params[:id])
 		end
 	end
end
