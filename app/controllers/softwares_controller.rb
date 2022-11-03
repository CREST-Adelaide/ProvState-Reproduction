class SoftwaresController < ApplicationController
	def add_software
		@software = Software.new
		@id = params[:id]
	end

	def create
		@software = Software.create(params.permit(:name, :description, :operating_system, :install_command))
		@software.device_id = params[:id]
		@software.save

		@device = Device.find_by(id: params[:id])  
		notifications_array = []
			begin

				Net::SSH.start(@device.host, @device.username, password: @device.password, timeout: 3) do |ssh|
					output = ""
					timeout 5 do
						output = ssh.exec!("sudo apt-get")
					end

					output2 = ssh.exec!(@software.install_command)
					puts output2
					notifications_array.push(@software.name + " has been installed to this device.")

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

	def view_patches
		group_id = session[:group]
	    @group_name = @contract.call.get_group_name(group_id)

	    state_address = @contract.call.get_state_contract(group_id)
	    state_address = "0x" + state_address

	    state_abi = File.read(File.join(Rails.root, 'abis', 'State.json'))
	    @state_contract = Ethereum::Contract.create(name: "State", client: @client, address: state_address, abi: state_abi)
	    @state_contract.key = Eth::Key.new priv: 'baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc'



	    @state_name = @state_contract.call.get_name
	    @state_owner = "0x" + @state_contract.call.get_owner
	    @state_initial = @state_contract.call.initial
	    @current_state = @state_contract.call.get_current_state(0)
	    @asset_count = @state_contract.call.asset_count



	    oracle_address = @contract.call.get_oracle_contract(group_id)
	    oracle_address = "0x" + oracle_address

	    oracle_abi = File.read(File.join(Rails.root, 'abis', 'Oracle.json'))
	    @oracle_contract = Ethereum::Contract.create(name: "Oracle", client: @client, address: oracle_address, abi: oracle_abi)
	    @oracle_contract.key = Eth::Key.new priv: 'baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc'

	    @total_transitions = @oracle_contract.call.transition_count
	    @oracle_transitions = Array.new(@total_transitions)

	    $i = 0
	    $num = @total_transitions

	    while $i < $num do
	      @oracle_transitions[$i] = @oracle_contract.call.get_transition($i)
	      $i += 1
	    end





	    $i = 0
	    $num = @asset_count
	    @asset_array = Array.new(@asset_count)
	    while $i < $num do
	      os = @state_contract.call.get_operating_system($i)
	      sn = @state_contract.call.get_software_name($i)
	      s = @state_contract.call.get_current_state($i)
	      hash = { :operating_system => os, :software_name => sn, :id => $i, :state => s }
	      @asset_array[$i] = hash
	      $i += 1
	    end
	end
end
