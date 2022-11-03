pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Manager.sol";

contract TestOracle {
    Manager man = new Manager();
  function testItExists() public {
    
    man.create_group("Org1");

    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    string memory name = o.get_name();

    Assert.equal(name, "Oracle contract", "The name of the oracle contract should be Oracle contract");
  }

  function testItAddsStates() public {
    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    o.add_state("initial");
    o.add_state("intermediate");
    o.add_state("final");

    string memory one = o.get_state(0);
    string memory two = o.get_state(1);
    string memory three = o.get_state(2);

    Assert.equal(one, "initial", "first state should be initial");
    Assert.equal(two, "intermediate", "second state should be intermediate");
    Assert.equal(three, "final", "third state should be final");

    o.delete_state("initial");
    
    one = o.get_state(0);
    two = o.get_state(1);

    Assert.equal(two, "intermediate", "second state should be intermediate");
    Assert.equal(one, "final", "first state should be final");

    uint t = o.stateCount();

    Assert.equal(t, 2, "State count should be 2");
  }

  function testItAddsTransitions() public {

    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    string memory one = o.get_state(0); 
    string memory two = o.get_state(1);

    o.add_transition(one,two);

    uint t = o.transitionCount();

    Assert.equal(t, 1, "transition count should be 1");

    string memory four = o.get_transition(0);

    Assert.equal(four, "final => intermediate", "transition should be final to intermediate");
  }


  function testItValidatesTransitions() public {
    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    bool check = o.valid_transition("initial", "intermediate");
    Assert.equal(check, false, "transition between initial and intermediate should not exist yet");


    check = o.valid_transition("final", "intermediate");
    Assert.equal(check, true, "transition between final and intermediate should be allowed");

  }
  function testItDeletesTransitions() public {
    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    bool check = o.valid_transition("final", "intermediate");
    Assert.equal(check, true, "transition between final and intermediate should be allowed");

    o.delete_transition(0);

    check = o.valid_transition("final", "intermediate");
    Assert.equal(check, false, "transition between final and intermediate should not exist");

  }

  
}