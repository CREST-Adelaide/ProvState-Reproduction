pragma solidity ^0.5.0;

import "./Oracle.sol";

contract State {
  string name;
  address owner = 0x9838a5e2cB634b8852548F0449Fe0A6d116aA232;   // The owner of the contract should be set in the constructor using msg.sender
                                                                // For testing purposes this user address is used as this account has been assigned ether on the kovan testnet
  string public initialState = "default initial";
  string public finalState = "default final";
  address oracleAdr;

  uint public assetCount = 0;
  mapping(uint => Asset) public assets;

  uint public userCount = 0;
  mapping(uint => User) public users;

  uint public roleCount = 0;
  mapping(uint => string) public roles;

  constructor() public {
    name = "State contract";
  }

  struct Asset{                 // struct to store asset (patch)
    uint id;
    string name;
    string operating_system;
    string software_name;
    string state;
    string hash;
    string device;
  }

  struct User{
    uint id;
    string blockchain_address;
    uint user_role;
  }

  function add_role(string memory _rolename) public   // Add a role to the role mapping and do the same on the oracle contract
  {
    roles[roleCount] = _rolename;
    
    Oracle o = Oracle(oracleAdr);
    o.add_role(_rolename, roleCount);
    roleCount++;
  }
  
  function add_user(string memory _address, uint _roleid) public
  {
      User memory u;
      u.id = userCount;
      u.blockchain_address = _address;
      u.user_role = _roleid;
      users[userCount] = u;
      userCount++;
  }

  function add_role_to_user(uint _uid, uint _rid) public
  {
    users[_uid].user_role = _rid;
  }

  function get_name() public view returns (string memory)
  {
    return name;
  }

  function get_owner() public view returns (address)
  {
    return owner;
  }


  function set_oracle(address _oracle) public
  {
    oracleAdr = _oracle;
  }

  function get_oracle() public view returns (address)
  {
    return oracleAdr;
  }

  function set_initial(string memory _newinitial) public
  {
    initialState = _newinitial;
  }
  function set_final(string memory _newfinal) public
  {
    finalState = _newfinal;
  }

  function add_asset(string memory _name, string memory _hash, string memory _operating_system, string memory _software_name) public
  {
    Asset memory p; 
    p.name = _name;
    p.state = initialState;
    p.id = assetCount;
    p.hash = _hash;
    p.operating_system = _operating_system;
    p.software_name = _software_name;
    p.device = "null";
    assets[assetCount] = p;
    assetCount++;
  }

  function copy_patch(uint _assetid) public         // Copies all fields of an asset except the id. Used for applying assets to devices
  {
    Asset memory p; 
    p.name = assets[_assetid].name;
    p.state = assets[_assetid].state;
    p.id = assetCount;
    p.hash = assets[_assetid].hash;
    p.operating_system = assets[_assetid].operating_system;
    p.software_name = assets[_assetid].software_name;
    p.device = "null";
    assets[assetCount] = p;
    assetCount++;
  }

  function apply_device(uint _assetid, string memory _device_name) public
  {
    assets[_assetid].device = _device_name;
  }

  function get_asset_name(uint _assetid) public view returns (string memory)
  {
    return assets[_assetid].name;
  }
  function get_current_state(uint _assetid) public view returns (string memory)
  {
    return assets[_assetid].state;
  }
  function get_operating_system(uint _assetid) public view returns (string memory)
  {
    return assets[_assetid].operating_system;
  }
  function get_software_name(uint _assetid) public view returns (string memory)
  {
    return assets[_assetid].software_name;
  }
  function get_asset_device(uint _assetid) public view returns (string memory)
  {
    return assets[_assetid].device;
  }
  
  function check_hash(uint _assetid, string memory _hash) public view returns (bool)        // Compare the hash stored on the blockchain with the recalculated hash of the locally stored asset
  {
      string memory testhash = assets[_assetid].hash;
      if(keccak256(abi.encodePacked(testhash)) == keccak256(abi.encodePacked(_hash)))
      {
          return true;
      }
      else
      {
          return false;
      }
  }

  function transition(uint _assetid, string memory _targetstate, uint _role, string memory _hash) public    // Transition asset to target state if the hash has not changed, the role is correct, and the transition is correct
  {
    bool hash_check = check_hash(_assetid, _hash);
    if(hash_check == false)
    {
        return;
    }
    string memory _firststate = assets[_assetid].state;

    Oracle o = Oracle(oracleAdr);

    bool result = o.valid_transition(_firststate, _targetstate, _role);

    if(result == false)
    {
      return;
    }
    else
    {
      assets[_assetid].state = _targetstate;
    }

  }

}
