pragma solidity ^0.5.0;

import "./State.sol";
import "./Oracle.sol";

contract Manager {
  string name;

  uint public stateContractCount = 0;
  mapping(uint => address) stateContracts;

  uint public oracleContractCount = 0;
  mapping(uint => address) oracleContracts;

  uint public userGroupCount = 0;
  mapping(uint => UserGroup) public userGroups;

  constructor() public {
    name = "Manager";
  }

  struct UserGroup {
    uint id;
    address owner;
    string name;
    address stateContract;
    address oracleContract;
  }

  function get_name() public view returns (string memory)
  {
    return name;
  }

  function create_group(string memory _name) public       // Creates a new group and assigns a new state and oracle contract
  {
    UserGroup memory ug; 
    ug.id = userGroupCount;
    ug.owner = msg.sender;
    ug.name = _name;
    ug.oracleContract = create_oracle_contract();
    State s = State(create_state_contract());
    s.set_oracle(ug.oracleContract);
    ug.stateContract = address(s);
    userGroups[userGroupCount] = ug;
    userGroupCount++;
  }

  function create_state_contract() private returns(address)
  {
    State s = new State();
    stateContracts[stateContractCount] = address(s);    // Create state contract and add the address to the stateContracts mapping
    stateContractCount++;
    return address(s);
  }

  function create_oracle_contract() private returns(address)
  {
    Oracle o = new Oracle();
    oracleContracts[oracleContractCount] = address(o);    // Create oracle contract and add the address to the oracleContracts mapping
    oracleContractCount++;
    return address(o);
  }

  function get_id(string memory _groupname) public view returns(uint)
  {
    for(uint i = 0; i < userGroupCount; i++)
    {
      if(keccak256(abi.encodePacked(userGroups[i].name)) == keccak256(abi.encodePacked(_groupname)))
      {
        return i;
      }
    }
  }

  function get_group_name(uint _gid) public view returns(string memory)
  {
    return userGroups[_gid].name;
  }

  function get_state_contract(uint _gid) public view returns(address)
  {
    return userGroups[_gid].stateContract;
  }

  function get_oracle_contract(uint _gid) public view returns(address)
  {
    return userGroups[_gid].oracleContract;
  }
}
