pragma solidity ^0.4.24;

import './dWart.sol';
import './dWarrior.sol';
import './dStage.sol';
import './dMatch.sol';

/*
* @dev Legends of dWaria contract
* Stores the players, dMatches, dWarriors and dStages
*/
contract dWaria {

    address public dBoss;

    dWart public token;

    address[] public $warriors;
    address[] public $players;
    address[] public $stages;
    address[] public $matches;

    mapping(address => Player) public players;
    mapping(address => Warrior) public warriors;
    mapping(address => Stage) public stages;
    mapping(address => Match) public matches;

    uint256 public price = 1;

    struct Player {
        address id;
        uint256 wins;
        uint256 losses;
        uint256 amountRaised;
        uint256 amountLost;
        address[] oponents;
        address[] matches;
    }

    struct Warrior {
        address id;
    }
    
    struct Stage {
        address id;
    }
    
    struct Match {
        address id;
    }

    constructor(dWart _token) public {
        token = _token;
        dBoss = msg.sender;
    }

    function() external {}

    function registerPlayer() public {
        require(players[msg.sender].id == address(0));
        require(token.balanceOf(msg.sender) >= price);
        
        token.transferFrom(msg.sender, dBoss, price);

        players[msg.sender].id = msg.sender;
        players[msg.sender].wins = 0;
        players[msg.sender].losses = 0;
        players[msg.sender].amountRaised = 0; 
        players[msg.sender].amountLost = 0;

        $players.push(msg.sender);
    }

    function registerDWarrior(dWarrior _warrior) public {
        require(warriors[_warrior].id == address(0));
        warriors[_warrior].id = _warrior;
        $warriors.push(_warrior);
    }

    function registerDStage(dStage _stage) public {
        require(stages[_stage].id == address(0));
        stages[_stage].id = _stage;
        $stages.push(_stage);
    }

    function registerDMatch(dMatch _match) public {
        require(matches[_match].id == address(0));
        require(token.balanceOf(msg.sender) >= price);
        
        token.transferFrom(msg.sender, dBoss, price);

        matches[_match].id = _match;
        $matches.push(_match);
    }
}