pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Manager.sol";

contract TestState {
  function testItExists() public {
    Manager man = new Manager();
    man.create_group("Org1");

    address adr = man.get_state_contract(0);
    State s = State(adr);
    string memory name = s.get_name();
    Assert.equal(name, "State contract", "The name of the contract should be state contract");
  }

  function testItHasAnOracle() public {
    Manager man = new Manager();
    man.create_group("Org1");

    address adr = man.get_state_contract(0);
    State s = State(adr);

    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    string memory name = o.get_name();

    Assert.equal(name, "Oracle contract", "The name of the contract should be Oracle contract");

    address adr3 = s.get_oracle();
    Oracle o2 = Oracle(adr3);

    name = o2.get_name();

    Assert.equal(name, "Oracle contract", "The name of the contract should be Oracle contract");
  }

  function testItCanAddPatches() public {
    Manager man = new Manager();
    man.create_group("Org1");

    address adr = man.get_state_contract(0);
    State s = State(adr);

    s.add_patch("x59cacs7c0a");
    string memory current = s.get_current_state(0);
    Assert.equal(current, "default", "initial state should be 'default'");
  }

  function testItCanTransitionPatches() public {
    Manager man = new Manager();
    man.create_group("Org1");

    address adr = man.get_state_contract(0);
    State s = State(adr);

    address adr2 = man.get_oracle_contract(0);
    Oracle o = Oracle(adr2);

    s.set_initial("initial");
    s.add_patch("x59cacs7c0a");

    o.add_state("initial");
    o.add_state("first");
    o.add_state("final");

    o.add_transition("initial", "first");
    o.add_transition("first", "final");

    string memory current = s.get_current_state(0);
    Assert.equal(current, "initial", "initially state should be in initial");

    s.transition(0, "first");
    current = s.get_current_state(0);
    Assert.equal(current, "first", "patch state should now be first");

    s.transition(0, "final");
    current = s.get_current_state(0);
    Assert.equal(current, "final", "patch state should now be final");

  }
}