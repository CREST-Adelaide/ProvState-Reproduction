class SessionsController < ApplicationController

	skip_before_action :authorized, only: [:new, :create, :welcome]

  include SessionHelper
  include DeviceHelper

  def new
  end

  def create
    initialise_manager

  	@user = User.find_by(username: params[:username])

  	if @user && @user.authenticate(params[:password])

    	session[:user_id] = @user.id
      session[:address] = @user.address

    	redirect_to '/welcome'

   	else

      flash[:danger] = 'Invalid email/password combination'

     	redirect_to '/login'

  	end

	end

  def login
  end

  def destroy
    session.delete(:user_id)
    session.delete(:group)
    @user = nil
    $my_role = ""
    redirect_to '/welcome'
  end

  def welcome
  end

  def page_requires_login
  end

  def create_group
    initialise_manager

  end

  def send_group

    initialise_manager
    $contract.transact_and_wait.create_group(params[:name])

    group_id = $contract.call.get_id(params[:name])
    session[:group] = group_id

    initialise_oracle
    initialise_state

    @user = current_user

    $state_contract.transact_and_wait.add_user(@user.address, 0);
    $state_contract.transact_and_wait.add_role("Admin");

    redirect_to '/welcome'
  end

  def find_group
    initialise_manager
    @group_count = $contract.call.user_group_count
  end

  def access_group
    

    group_id = params[:id].to_i

    session[:group] = group_id

    initialise_oracle
    initialise_state

    redirect_to '/welcome'

  end

  def users

    total_users = $state_contract.call.user_count

    @user_list = Array.new(total_users)

    $i = 0
    $num = total_users

    while $i < $num do
      id = $i
      addr = $state_contract.call.users($i)[1]
      role = $state_contract.call.users($i)[2]
      rolename = $state_contract.call.roles(role)
      
      @user = User.find_by(address: addr) 

      hash = { :name => @user.username, :id => id, :blockchain_address => addr, :user_role => rolename}
      @user_list[$i] = hash
      $i += 1
    end


    @total_roles = $state_contract.call.role_count
  end

  def add_user
    @user = User.find_by(address: params[:address]) 
    if @user == nil
      redirect_to '/users', alert: "User does not exist"
    else
    $state_contract.transact_and_wait.add_user(params[:address], 1);
    redirect_to '/users', notice: "User added"
  end
  end

  def add_role
     
    $state_contract.transact_and_wait.add_role(params[:name])
    redirect_to '/users'

  end

  def add_user_role
     @total_roles = $state_contract.call.role_count
  end

  def post_user_role
     $state_contract.transact_and_wait.add_role_to_user(params[:id].to_i, params[:role_id].to_i)
     redirect_to '/users'
  end

  def oracle

    
    
  end

  def add_state_oracle
    $oracle_contract.transact_and_wait.add_state(params[:name])

    $oracle_states.push($oracle_contract.call.states($total_oracle_states))

    $total_oracle_states = $oracle_contract.call.state_count

    redirect_to '/oracle'
  end

  def add_transition_oracle

    $oracle_contract.transact_and_wait.add_transition(params[:first], params[:second])

    id = $total_transitions
    state1 = params[:first]
    state2 = params[:second]
    roleid = $oracle_contract.call.transitions(id)[2]

    role = $oracle_contract.call.roles(roleid)

    hash = { :id => id, :state1 => state1, :state2 => state2, :role => role}
    $oracle_transitions.push(hash)

    $total_transitions = $oracle_contract.call.transition_count

    redirect_to '/oracle'
  end

  def add_transition_role

    $i = 0
    $num = $oracle_contract.call.role_count


    while $i < $num do
      if $oracle_contract.call.roles($i) == params[:name]
        $oracle_contract.transact_and_wait.add_transition_role(params[:id].to_i, $i)
        update_transition_array
        redirect_to '/oracle'
        return
      end
      $i += 1
    end

    update_transition_array
    redirect_to '/oracle'
  end

  def delete_oracle_state

    $oracle_contract.transact_and_wait.delete_state(params[:name])
    redirect_to '/oracle'
  end

  def delete_oracle_transition
    
    tid = params[:id].to_i
    $oracle_contract.transact_and_wait.delete_transition(tid)
    redirect_to '/oracle'
  end

  def state
    
  end

  def set_state_initial
    $state_contract.transact.set_initial(params[:new_initial])

    $state_initial = params[:new_initial]

    redirect_to '/state'
  end

  def set_state_final
    $state_contract.transact.set_final(params[:new_final])

    $state_final = $state_contract.call.final_state

    redirect_to '/state'
  end

  def add_patch
    $state_contract.transact_and_wait.add_asset(params[:hash], params[:operating_system],params[:software_name])
    os = params[:operating_system]
    sn = params[:software_name]
    id = $state_contract.call.asset_count - 1
    s = $state_contract.call.get_current_state(id)
    hash = { :operating_system => os, :software_name => sn, :id => id, :state => s }
    $asset_array.push(hash)
    redirect_to '/state'
  end

  def transition_patch
    sname = $state_contract.call.get_asset_name(params[:aid].to_i)

    sha_calc = Digest::SHA256.hexdigest sname
    $state_contract.transact_and_wait.transition(params[:aid].to_i, params[:state], $role_id.to_i, sha_calc)
    update_asset_array
    redirect_to '/state'
  end


end
