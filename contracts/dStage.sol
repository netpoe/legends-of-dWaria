pragma solidity ^0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';
import './dWart.sol';

contract dStage {

    using SafeMath for uint256;

    dWart public token;

    address public creator;
    string public name;
    string public shortStory;

    uint256 public amountRaised = 0;
    uint256 public price = 1;
    uint256 public fights = 0;
    uint256 public fightsThreshold = 15;

    constructor(
    dWart _token,
    string _name, 
    string _shortStory
    ) public {
        creator = msg.sender;
        name = _name;
        shortStory = _shortStory;
        token = _token;
    }

    function() external {
        select();
    }

    /*
    * @dev a Player selects this dWarrior for a Match
    */
    function select() public {
        require(token.balanceOf(msg.sender) >= price);
        token.transferFrom(msg.sender, creator, price);
        amountRaised = amountRaised.add(price);
        fights = fights.add(1);
        if (fights % fightsThreshold == 0) {
            price = price.add(1);
        }
    }

    // left
    // center
    // right

    // roof
    // floor
    
    // higherground
    // underground

}