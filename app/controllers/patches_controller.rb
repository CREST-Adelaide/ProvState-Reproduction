class PatchesController < ApplicationController
	include SessionHelper
	require 'digest'
  def index
  	@patches = Patch.all
  end

  def new
  	@patch = Patch.new
  end

  def create
    @patch = Patch.create(params.require(:patch).permit(:patch, :name, :attachment, :operating_system, :install_command, :software_name))
  	
    @patch.save
  	#sha_calc = Digest::SHA256.hexdigest File.read(@patch.attachment_url)		Note the hash is not actually calcualted here. There has been an error with retrieving the file
  	sha_calc = Digest::SHA256.hexdigest @patch.name
  	puts sha_calc
  	$state_contract.transact_and_wait.add_asset(@patch.name, sha_calc, @patch.operating_system, @patch.software_name)
    nm = @patch.name
    os = @patch.operating_system
    sn = @patch.software_name
    id = $state_contract.call.asset_count - 1
    s = $state_contract.call.get_current_state(id)
    hash = { :name => nm, :operating_system => os, :software_name => sn, :id => id, :state => s }
    $asset_array.push(hash)

  	if @patch.save
  		redirect_to patches_path, notice: "The patch #{@patch.name} has been uploaded"
  	else
  		render "new"
  	end
  end

  def destroy
  	@patch = Patch.find(params[:id])
    @patch.destroy
    redirect_to patches_path, notice:  "The patch #{@patch.name} has been deleted."
   end

  def patch_params
  	params.require(:patch).permit(:name, :attachment)
  end
end
