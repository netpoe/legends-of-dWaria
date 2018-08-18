pragma solidity ^0.4.24;

import './SafeMath';

/*
* @dev Legends of dWaria contract
* Stores the players, matches and dWarriors
*/
contract dWaria {

    address public beneficiary;

    address[] public $dWarriors;
    address[] public $players;

    mapping(address => Player) public players;
    mapping(address => dWarrior) public dWarriors;

    struct Player {
        address id;
        string name;
        uint256 wins;
        uint256 losses;
        uint256 amountRaised;
        uint256 amountLost;
        address[] oponents;
        address[] matches;
    }

    struct dWarrior {
        address id;
    }

    constructor() public {
        beneficiary = msg.sender;
    }

    function() payable external {}

    function registerPlayer() payable public {}
    function registerDWarrior() public {}
    function registerDMatch() payable public {}
}

contract dMatch {

    use SafeMath for uint256;

    address public player1;
    address public player2;

    address public winner;
    address public loser;

    struct Player {
        address dWarrior;
        uint256 damage;
        uint256 points;
    }

    enum State {
        pendingOponent,
        pendingWinnner,
        won,
        draw
    }
    
    State public state;

    mapping(address => Player) public players;

    uint256 public bet = 0;

    constructor() public {
        state = State.pendingOponent;
    }

    function() payable {
        play();
    }

    /*
    * @dev Sets the bet for the dMatch between a player1 and player2
    * The dMatch creator is not neccesarily the player1
    */
    function play() payable public {
        require(state == State.pendingOponent);
        require(player1 != msg.sender);

        players[msg.sender].damage = 0;
        players[msg.sender].points = 0;

        if (player1 == address(0)) {
            player1 = msg.sender;
            bet = bet.add(msg.value);
        }
        
        if (player2 == address(0)) {
            require(msg.value == bet);
            player2 = msg.sender;
            bet = bet.add(msg.value);
            state = State.pendingWinnner;
        }
    }

    /*
    * @dev Starts the fight
    * This method must be called only by the official dWaria contract reference
    */
    function fight() onlyDWaria public {
        require(state == State.pendingWinnner);
    }

    function setResult(address _winner, address _loser) onlyDWaria public {
        require(state == State.pendingWinnner);

        winner = _winner;
        loser = _loser;

        state = State.
    }

    /*
    * @dev The winner may call this method to retrieve the bet funds
    * If a dMatch is marked as "draw", then the bet is sent back equally
    */
    function withdrawBet() payable public {
        require(state == State.won || state == State.draw);
        require(msg.sender == player1 || msg.sender == player2);

        if (state == State.won) {
            // send the whole bet to the winner
        }
        
        if (state == State.draw) {
            // send the bet eqaully to both players
        }
    }
}

contract dWarriorInterface {
    
    /*
    * @dev Causes the actual damage to the oponent
    */
    function hit(uint256 _damage) internal {}

    /*
    * @dev the dWarrior just stands there
    */
    function wait() public {}

    /*
    * @dev These methods in combination with directional actions cause damage to the oponent
    * ONLY if the oponent is hit
    */
    function kick() public {}
    function lowerKick() public {}
    function upperKick() public {} 
    function punch() public {}
    function lowerPunch() public {}
    function upperPunch() public {}

    /*
    * @dev combos and powers
    */
    function punchCombo() public {}
    function kickCombo() public {}
    function powerCombo() public {}
    function distancePower() public {}

    /*
    * @dev shields
    * Ways that the dWarrior can protect from the oponent attack
    * Being hit by the oponent while shielding causes half the damage
    */
    function shield() public {}
    function lowerShield() public {}
    function upperShield() public {}
    
    /*
    * @dev directional actions cause no damage because they don't "hit()"
    */
    function grab() public {}
    function grabFromBack() public {}
    function jump() public {}
    function doubleJump() public {}
    function trippleJump() public {}
    function dock() public {}
    function walk() public {}
    function walkBackwards() public {}
    function run() public {}
    function turnLeft() public {}
    function turnRight() public {}
    
    /*
    * @dev dWarrior action combinations cause the sum of the base damage
    */

    // Punches
    function grabAndPunch() public {}
    function grabFromBackAndPunch() public {}
    function dockAndPunch() public {}
    function jumpAndPunch() public {}
    function doubleJumpAndPunch() public {}
    function trippleJumpAndPunch() public {}
    function jumpAndUpperPunch() public {}
    function doubleJumpAndUpperPunch() public {}
    function trippleJumpAndUpperPunch() public {}
    function jumpAndLowerPunch() public {}
    function doubleJumpAndLowerPunch() public {}
    function trippleJumpAndLowerPunch() public {}
    function walkAndPunch() public {}
    function walkBackwardsAndPunch() public {}
    function runAndPunch() public {}
    function walkAndUpperPunch() public {}
    function walkBackwardsAndUpperPunch() public {}
    function runAndUpperPunch() public {}
    function walkAndLowerPunch() public {}
    function walkBackwardsAndLowerPunch() public {}
    function runAndLowerPunch() public {}
    function turnLeftAndPunch() public {}
    function turnRightAndPunch() public {}

    // Kicks
    function grabAndKick() public {}
    function grabFromBackAndKick() public {}
    function dockAndKick() public {}
    function jumpAndKick() public {}
    function doubleJumpAndKick() public {}
    function trippleJumpAndKick() public {}
    function jumpAndUpperKick() public {}
    function doubleJumpAndUpperKick() public {}
    function trippleJumpAndUpperKick() public {}
    function jumpAndLowerKick() public {}
    function doubleJumpAndLowerKick() public {}
    function trippleJumpAndLowerKick() public {}
    function walkAndKick() public {}
    function walkBackwardsAndKick() public {}
    function runAndKick() public {}
    function walkAndUpperKick() public {}
    function walkBackwardsAndUpperKick() public {}
    function runAndUpperKick() public {}
    function walkAndLowerKick() public {}
    function walkBackwardsAndLowerKick() public {}
    function runAndLowerKick() public {}
    function turnLeftAndKick() public {}
    function turnRightAndKick() public {}

    /*
    * @dev dWarrior states
    * These states represent the actions of the dWarrior when is hit by the oponent
    * These methods cause the actual damage to the player after hit by the oponent
    */
    function onIsPunched() internal {}
    function onIsLowerPunched() internal {}
    function onIsUpperPunched() internal {}
    function onIsKicked() internal {}
    function onIsLowerKicked() internal {}
    function onIsUpperKicked() internal {}
    
    function onIsGrabbedAndPunched() internal {}
    function onIsGrabbedAndLowerPunched() internal {}
    function onIsGrabbedAndUpperPunched() internal {}
    function onIsGrabbedAndKicked() internal {}
    function onIsGrabbedAndLowerKicked() internal {}
    function onIsGrabbedAndUpperKicked() internal {}
}

/*
* @dev Official dWarriors have a sprite of each of the action methods
* All dWarriors cause the same damage according to this contract
* The dWarrior creator is free of designing the style, props and movement implementations
*/
contract dWarrior is dWarriorInterface {

    use SafeMath for uint256;

    address public creator;
    string public name;
    string public bio;

    uint256 public amountRaised = 0;
    uint256 public price = 100 finney;
    uint256 public fights = 0;
    uint256 public fightsThreshold = 15;

    /*
    * @dev damage caused by the dWarrior
    */
    uint256 public kick = 1;
    uint256 public lowerKick = 2;
    uint256 public upperKick = 3;
    uint256 public punch = 1;
    uint256 public lowerPunch = 2;
    uint256 public upperPunch = 3;
    uint256 public grab = 1;
    uint256 public grabFromBack = 2;
    uint256 public jump = 1;
    uint256 public doubleJump = 2;
    uint256 public trippleJump = 3;
    uint256 public walk = 1;
    uint256 public walkBackwards = 1;
    uint256 public run = 2;
    uint256 public dock = 1;
    uint256 public hit = 0;
    uint256 public punchCombo = 3;
    uint256 public kickCombo = 4;
    uint256 public powerCombo = 5;
    uint256 public distancePower = 3;
  
    constructor(string _name, string _bio) public {
        creator = msg.sender;
        name = _name;
        bio = _bio;
    }

    function() payable {
        fight();
    }

    /*
    * @dev a Player chooses this dWarrior for a Match
    */
    function fight() payable public {
        require(msg.value == price);
        amountRaised = amountRaised.add(msg.value);
        creator.transfer(msg.value);
        fights = fights.add(1);
        
        if (fights % fightsThreshold == 0) {
            price = price.add(100 finney);
        }
    }
}