module Deployable
	extend ActiveSupport::Concern
	include ActiveModel::Callbacks

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
						erros.add(:base, "Supplied user must not have root access and be on the list of sudoers.")
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