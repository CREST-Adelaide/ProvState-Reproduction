module SessionHelper
	extend ActiveSupport::Concern
	extend ActiveModel::Naming
	def initialise_oracle
		group_id = session[:group]
		user = User.find_by(id: session[:user_id])  
		priv_key = user.private_key

	    $group_name = $contract.call.get_group_name(group_id)

	    $oracle_address = $contract.call.get_oracle_contract(group_id)
	    $oracle_address = "0x" + $oracle_address

	    oracle_abi = File.read(File.join(Rails.root, 'abis', 'Oracle.json'))
	    $oracle_contract = Ethereum::Contract.create(name: "Oracle", client: $client, address: $oracle_address, abi: oracle_abi)
	    $oracle_contract.key = Eth::Key.new priv: priv_key

	    $oracle_name = $oracle_contract.call.get_name

	    $total_oracle_states = $oracle_contract.call.state_count
	    $oracle_states = Array.new

	    @oracle_iterator = 0

	    while @oracle_iterator < $total_oracle_states do
	      $oracle_states.push($oracle_contract.call.states(@oracle_iterator))
	      @oracle_iterator += 1
	    end



	    $total_transitions = $oracle_contract.call.transition_count
	    $oracle_transitions = Array.new
	    
	    @oracle_iterator = 0

	    while @oracle_iterator < $total_transitions do
	      id = @oracle_iterator
	      state1 = $oracle_contract.call.transitions(@oracle_iterator)[0]
	      state2 = $oracle_contract.call.transitions(@oracle_iterator)[1]
	      roleid = $oracle_contract.call.transitions(@oracle_iterator)[2]

	      role = $oracle_contract.call.roles(roleid)

	      hash = { :id => id, :state1 => state1, :state2 => state2, :role => role}
	      $oracle_transitions.push(hash)
	      @oracle_iterator += 1
	    end
	end

	def update_transition_array
		$total_transitions = $oracle_contract.call.transition_count
	    $oracle_transitions = Array.new
	    
	    @oracle_iterator = 0

	    while @oracle_iterator < $total_transitions do
	      id = @oracle_iterator
	      state1 = $oracle_contract.call.transitions(@oracle_iterator)[0]
	      state2 = $oracle_contract.call.transitions(@oracle_iterator)[1]
	      roleid = $oracle_contract.call.transitions(@oracle_iterator)[2]

	      role = $oracle_contract.call.roles(roleid)

	      hash = { :id => id, :state1 => state1, :state2 => state2, :role => role}
	      $oracle_transitions.push(hash)
	      @oracle_iterator += 1
	    end
	end

	def initialise_state
		group_id = session[:group]
		user = User.find_by(id: session[:user_id])  
		uaddr = user.address

		priv_key = user.private_key

	    $state_address = $contract.call.get_state_contract(group_id)
	    $state_address = "0x" + $state_address

	    state_abi = File.read(File.join(Rails.root, 'abis', 'State.json'))
	    $state_contract = Ethereum::Contract.create(name: "State", client: $client, address: $state_address, abi: state_abi)
	    $state_contract.key = Eth::Key.new priv: priv_key

	    $state_name = $state_contract.call.get_name
    	$state_owner = "0x" + $state_contract.call.get_owner

    	@state_iterator = 0
	    $num = $state_contract.call.user_count

	    while @state_iterator < $num do
	      if $state_contract.call.users(@state_iterator)[1] == uaddr
	      	$role_id = $state_contract.call.users(@state_iterator)[2]
	      	$my_role = $state_contract.call.roles(@state_iterator)
	      	break
	      end
	      @state_iterator += 1
	    end


	    $state_initial = $state_contract.call.initial_state
	    $state_final = $state_contract.call.final_state
	    $asset_count = $state_contract.call.asset_count


	    @state_iterator = 0
	    $asset_array = Array.new

	    while @state_iterator < $asset_count do
	      nm = $state_contract.call.get_asset_name(@state_iterator)
	      os = $state_contract.call.get_operating_system(@state_iterator)
	      sn = $state_contract.call.get_software_name(@state_iterator)
	      s = $state_contract.call.get_current_state(@state_iterator)
	      dev = $state_contract.call.get_asset_device(@state_iterator)
	      hash = { :name => nm, :operating_system => os, :software_name => sn, :id => @state_iterator, :state => s, :device => dev}
	      $asset_array.push(hash)
	      @state_iterator += 1
	    end

	end

	def update_asset_array
		@state_iterator = 0
	    $asset_array = Array.new
	    $asset_count = $state_contract.call.asset_count
	    while @state_iterator < $asset_count do
	      nm = $state_contract.call.get_asset_name(@state_iterator)
	      os = $state_contract.call.get_operating_system(@state_iterator)
	      sn = $state_contract.call.get_software_name(@state_iterator)
	      s = $state_contract.call.get_current_state(@state_iterator)
	      dev = $state_contract.call.get_asset_device(@state_iterator)
	      hash = { :name => nm, :operating_system => os, :software_name => sn, :id => @state_iterator, :state => s, :device => dev}
	      $asset_array.push(hash)
	      @state_iterator += 1
	    end
	end


	def initialise_manager
		# Create client
		$client = Ethereum::HttpClient.new(ENV["NETWORK_URL"])
		$client.gas_limit = 6_128_200

		# Create contract wrapper
    	abi = File.read(File.join(Rails.root, 'abis', 'Manager.json'))
    	$contract = Ethereum::Contract.create(name: "Manager", client: $client, address: ENV["MANAGER_ADDRESS"], abi: abi)

		# Setup user account for interacting with the contract
		user = User.find_by(id: session[:user_id])  
		priv_key = user.private_key
		$contract.key = Eth::Key.new priv: priv_key
    	# $manager_name = $contract.call.get_name
    end

    def new_connection

		if self.class.name == "Device"
			notifications_array = []
			begin

				Net::SSH.start(self.host, self.username, password: self.password, timeout: 3) do |ssh|
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

					self.software_ids.each do |soft|
						puts 'test: ' + soft.to_s
						comm = Software.find(soft)
						output2 = ssh.exec!(comm.install_command)
						puts output2
						notifications_array.push(comm.name + " has been installed to this device.")
					end

					notifications_array.each do |notif|
						ssh.exec!("DISPLAY=:0 notify-send '"+notif+"'")
					end

				end

			rescue Net::SSH::ConnectionTimeout => e
				errors.add(:base, "Could not connect to device with provided details. Connection timed out. Check the device is on and the details are correct.")
				throw(:abort)
			end
		end
	end
end