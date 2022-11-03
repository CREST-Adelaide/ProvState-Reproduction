require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Project8
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    provStateConfig = JSON.parse(File.read(File.join(Rails.root, "ProvStateConfigGenerated.json")))
    puts(provStateConfig)

    ENV["MANAGER_ADDRESS"] = provStateConfig["manager_address"]
    #ENV["CONTRACT_SOURCE"] = "#{Dir.pwd}/contracts/Manager.sol"
    ENV["INFURA_URL"] = "https://kovan.infura.io/v3/78470388123047a2bf23b0b73389d7c9"
    ENV["NETWORK_URL"] = provStateConfig["network_url"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
