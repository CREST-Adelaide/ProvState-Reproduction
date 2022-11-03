pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Manager.sol";

contract TestManager {
    function testItExists() public {
        // Get the deployed contract

        Manager man = new Manager();

        string memory name = man.get_name();
        // Assert that the function returns the correct name
        Assert.equal(name, "Manager", "It should be called Manager.");
    }

    function testItCreatesGroup() public {
        Manager man = new Manager();
        uint gnum = man.userGroupCount();

        Assert.equal(gnum, 0, "Initially group count should be 0");

        man.create_group("Org1");
        gnum = man.userGroupCount();

        Assert.equal(gnum, 1, "Group count should be 1");

        uint gid = man.get_id("Org1");
        Assert.equal(gid, 0, "Group id should be 0");

        string memory name = man.get_group_name(0);
        Assert.equal(name, "Org1", "Group name should be Org1");
    }

    function testItCreatesOracle() public {
        Manager man = new Manager();

        man.create_group("Org1");

        uint num;
        num = man.oracleContractCount(); 
        Assert.equal(num, 1, "oracle contract count should increment after creation of contract");

        address adr = man.get_oracle_contract(0);
        Oracle o = Oracle(adr);
        string memory name = o.get_name();
        Assert.equal(name, "Oracle contract", "The name of the contract should be oracle contract");
    }

    function testItCreatesState() public {
        Manager man = new Manager();

        man.create_group("Org1");

        uint num;
        num = man.stateContractCount(); 
        Assert.equal(num, 1, "state contract count should increment after creation of contract");

        address adr = man.get_state_contract(0);
        State s = State(adr);
        string memory name = s.get_name();
        Assert.equal(name, "State contract", "The name of the contract should be state contract");

    }
}
