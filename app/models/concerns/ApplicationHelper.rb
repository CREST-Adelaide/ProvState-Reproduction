module ApplicationHelper
	extend ActiveSupport::Concern
	def initialise_oracle
		group_id = session[:group]
	    $group_name = $contract.call.get_group_name(group_id)

	    oracle_address = $contract.call.get_oracle_contract(group_id)
	    oracle_address = "0x" + oracle_address

	    oracle_abi = File.read(File.join(Rails.root, 'abis', 'Oracle.json'))
	    $oracle_contract = Ethereum::Contract.create(name: "Oracle", client: $client, address: oracle_address, abi: oracle_abi)
	    $oracle_contract.key = Eth::Key.new priv: 'baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc'

	    $oracle_name = $oracle_contract.call.get_name
	end

	def initialise_state
		group_id = session[:group]
	    state_address = $contract.call.get_state_contract(group_id)
	    state_address = "0x" + state_address

	    state_abi = File.read(File.join(Rails.root, 'abis', 'State.json'))
	    $state_contract = Ethereum::Contract.create(name: "State", client: $client, address: state_address, abi: state_abi)
	    $state_contract.key = Eth::Key.new priv: 'baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc'

	    $state_name = $state_contract.call.get_name
    	$state_owner = "0x" + $state_contract.call.get_owner
	end

	def initialise_manager
		$client = Ethereum::HttpClient.new('https://kovan.infura.io/v3/78470388123047a2bf23b0b73389d7c9')
    	abi = File.read(File.join(Rails.root, 'abis', 'Manager.json'))
    	$contract = Ethereum::Contract.create(name: "Manager", client: $client, address: ENV["MANAGER_ADDRESS"], abi: abi)
    	$contract.key = Eth::Key.new priv: 'baa68b3b6db96e8748467d05a2cdbdd8b97db1538a0cd8c91ea4bfb0576c2ffc'
    end
end