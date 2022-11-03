require 'ethereum'
require 'eth'

$contractAddr = ""

$provStateConfig = JSON.parse(File.read(File.join(".", "ProvStateConfig.json")))

# If the configuration does not have manager address, deploy a new manager contract
if $provStateConfig.has_key?("manager_address")
    puts("Found manager_address, skip contract deployment...")
    $contractAddr = $provStateConfig["manager_address"]
else
    puts("Deploying manager contract...")
    $networkURL = $provStateConfig["network_url"]
    $managerDeplKey = $provStateConfig["manager_depl_key"]

    # Initialise ethereum client and connect to the targeted blockchain network
    $client = Ethereum::HttpClient.new($networkURL)
    $client.gas_limit = 6_128_200

    # Load the ABI json
    $abiPath = File.join(".", "abis", "Manager.json")
    $abi = File.read($abiPath)

    # Load the bytecodes
    $codePath = File.join(".", "abis", "Manager.code")
    $code = File.read($codePath);

    # Create and deploy a manager contract
    $contract = Ethereum::Contract.create(name: "Manager", client: $client, abi: $abi, code: $code)
    $contract.key = Eth::Key.new priv: $managerDeplKey
    $contract.deploy_and_wait

    # Get the address of the newly deployed contract
    $contractAddr = $contract.address
end

# Generate the configuration file used to by Ruby app
$provStateConfig["manager_address"] = $contractAddr
File.write(File.join(".", "ProvStateConfigGenerated.json"), JSON.generate($provStateConfig))
puts("Generated ProvStateConfigGenerated.json")