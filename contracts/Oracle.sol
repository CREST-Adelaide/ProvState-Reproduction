pragma solidity ^0.5.0;

contract Oracle {
  string name;

  uint public stateCount;
  mapping(uint => string) public states;
  
  uint public transitionCount;
  mapping(uint => Transition) public transitions;
  
  uint public roleCount = 0;
  mapping(uint => string) public roles;

  struct Transition {
    string state1; 
    string state2;
    uint role;
  }

  constructor() public {
    name = "Oracle contract";
  }

  function get_name() public view returns(string memory)
  {
    return name;
  }
  
  function add_role(string memory _rolename, uint _rcount) public
  {
    roles[_rcount] = _rolename;
    roleCount++;
  }

  function add_state(string memory _state) public
  {
    states[stateCount] = _state;
    stateCount++;
  }

  function get_states() public view returns(string memory)
  {
    string memory retval;
    for(uint i = 0; i < stateCount; i++)
    {
      abi.encodePacked(retval, states[i]);
    }
    return retval;
  }

  function state_exists(string memory _state) public view returns(bool)
  {
    for(uint i = 0; i < stateCount; i++)
    {
      if(keccak256(abi.encodePacked(_state)) == keccak256(abi.encodePacked(states[i])))
      return true;
    }
    return false;
  }
  function add_transition(string memory _state1, string memory _state2) public
  {
    if(state_exists(_state1) == false || state_exists(_state2) == false)  // test state exists
    {
      return; // need to emit success/failure events
    }
    Transition memory t;
    t.state1 = _state1;
    t.state2 = _state2;
    transitions[transitionCount] = t;
    transitionCount++;
  }
  
  function add_transition_role(uint _tid, uint _rid) public
  {
    transitions[_tid].role = _rid;
  }

  function get_transition(uint _loc) public view returns (string memory)
  {
    if(_loc >= transitionCount)
    {
      return "transition does not exist"; // Need event emitted here
    }
    string memory first = transitions[_loc].state1;
    string memory third = transitions[_loc].state2;

    string memory second = " => ";

    string memory retval = string(abi.encodePacked(first, second));
    retval = string(abi.encodePacked(retval, third));

    return retval;
  }

  function valid_transition(string memory _state1, string memory _state2, uint _role) public view returns (bool)
  {
    for(uint i = 0; i < transitionCount; i++)
    {
      if(keccak256(abi.encodePacked(transitions[i].state1)) == keccak256(abi.encodePacked(_state1)))    // If the first state is found in the transition
      {
        if(keccak256(abi.encodePacked(transitions[i].state2)) == keccak256(abi.encodePacked(_state2)))    // Check the second state
        {
          if(_role == 0)                            //if role is admin or a valid role return true
          {
              return true;
          }
          else if(transitions[i].role == _role)
          {
              return true;
          }
          else
          {
              return false;
          }
        }
      }
    }
    return false;
  }

}
