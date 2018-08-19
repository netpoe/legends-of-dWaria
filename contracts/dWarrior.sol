pragma solidity ^0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';
import './dWart.sol';

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

/*
* @dev a dWaria dMatch
* It is a match between 2 registered players
* Any registered player can create a match
* a match is initialized by sending a bet in dWart tokens
*/
contract dMatch {

    using SafeMath for uint256;

    modifier onlyDWaria() {
        require(msg.sender == address(parent));
        _;
    }
    
    modifier pendingOponent() {
        require(state == State.pendingOponent);
        _;
    }
    
    modifier pendingWinner() {
        require(state == State.pendingWinner);
        _;
    }

    dWaria public parent;
    dWart public token;

    address public player1;
    address public player2;

    address public winner;
    address public loser;

    dStage public stage;

    uint256 public roundCount = 2;
    uint256 public round = 0;
    mapping(uint256 => Round) public rounds; 

    struct Player {
        address warrior;
        uint256 damage;
        uint256 points;
    }

    struct Round {
        address winner;
        address loser;
    }

    enum State {
        pendingOponent,
        pendingWinner,
        won,
        draw
    }
    
    State public state;

    mapping(address => Player) public players;

    uint256 public bet = 0;

    constructor(
    dWaria _parent, 
    dWart _token,
    dWarrior _warrior,
    dStage _stage,
    uint256 _bet) public {
        parent = _parent;
        token = _token;
        stage = _stage;
        state = State.pendingOponent;
        bet = _bet;
        _initPlayer1(_warrior);
    }

    function() external {}

    function _initPlayer(dWarrior _warrior) pendingOponent internal {
        players[msg.sender].warrior = _warrior;
        players[msg.sender].damage = 0;
        players[msg.sender].points = 0;
    }

    function _initPlayer1(dWarrior _warrior) pendingOponent internal {
        require(player1 != msg.sender);
        player1 = msg.sender;
        token.transferFrom(msg.sender, address(this), bet);
        _initPlayer(_warrior);
    }
    
    function initPlayer2(dWarrior _warrior) pendingOponent public {
        require(player2 == address(0));
        require(token.balanceOf(msg.sender) >= bet);
        player2 = msg.sender;
        bet = bet.add(bet);
        token.transferFrom(msg.sender, address(this), bet);
        _initPlayer(_warrior);
        state = State.pendingWinner;
    }

    /*
    * @dev Starts the fight
    * This method must be called only by the official dWaria contract reference
    * Both players must be ready to fight
    * Ready means their connection is stable and the websockets are plugged in and listening
    */
    function fight() onlyDWaria, pendingWinner public {
        round = round.add(1);
    }

    function endRound(
    uint256 player1Damage,
    uint256 player1Points,
    uint256 player2Damage,
    uint256 player2Points
    ) onlyDWaria, pendingWinner public {
        require(player1Damage >= 0 && player1Points >= 0);
        require(player2Damage >= 0 && player2Points >= 0);

        players[player1].damage = player1Damage;
        players[player1].points = player1Points;
        players[player2].damage = player2Damage;
        players[player2].points = player2Points;

        if () 
        rounds[round].winner = _winner;
        rounds[round].loser = _loser;
    }

    function setResult(address _winner, address _loser) onlyDWaria, pendingWinner public {
        require(_winner == player1 || _loser == player1);
        require(_winner == player2 || _loser == player2);

        winner = _winner;
        loser = _loser;

        // state = State.
    }

    /*
    * @dev The winner may call this method to retrieve the bet funds
    * If a dMatch is marked as "draw", then the bet is sent back equally
    */
    function withdraw() public {
        require(state == State.pendingOponent || state == State.won || state == State.draw);
        require(msg.sender == player1 || msg.sender == player2);

        if (state == State.pendingOponent) {
            require(msg.sender == player1);
            token.transfer(player1, bet);
        }

        if (state == State.won) {
            token.transfer(winner, bet);
        }
        
        if (state == State.draw) {
            token.transfer(player1, bet.div(2));
            token.transfer(player2, bet.div(2));
        }
    }
}

contract dWarriorInterface {
    
    /*
    * @dev Causes the actual damage to the oponent
    */
    function hit(uint256 _damage) internal;

    /*
    * @dev the dWarrior just stands there
    */
    function wait() public;
    
    /*
    * @dev the dWarrior distinctive salute
    */
    function salute() public;

    /*
    * @dev These methods in combination with directional actions cause damage to the oponent
    * ONLY if the oponent is hit
    */
    function kick() public;
    function lowerKick() public;
    function upperKick() public; 
    function punch() public;
    function lowerPunch() public;
    function upperPunch() public;

    /*
    * @dev combos and powers
    */
    function punchCombo() public;
    function kickCombo() public;
    
    /*
    * @dev a power combo happens on a tripple jump grab with kick and punch
    */
    function powerCombo() public;

    /*
    * @dev a distance power happens on walk backwards + kick + punch
    */
    function distancePower() public;

    /*
    * @dev shields
    * Ways that the dWarrior can protect from the oponent attack
    * Being hit by the oponent while shielding causes half the damage
    */
    function shield() public;
    function lowerShield() public;
    function upperShield() public;
    
    /*
    * @dev directional actions cause no damage because they don't "hit()"
    */
    function grab() public;
    function grabFromBack() public;
    function jump() public;
    function doubleJump() public;
    function trippleJump() public;
    function dock() public;
    function walk() public;
    function walkBackwards() public;
    function run() public;
    function turnLeft() public;
    function turnRight() public;
    
    /*
    * @dev dWarrior action combinations cause the sum of the base damage
    */

    // Punches
    function grabAndPunch() public;
    function grabFromBackAndPunch() public;
    function dockAndPunch() public;
    function jumpAndPunch() public;
    function doubleJumpAndPunch() public;
    function trippleJumpAndPunch() public;
    function jumpAndUpperPunch() public;
    function doubleJumpAndUpperPunch() public;
    function trippleJumpAndUpperPunch() public;
    function jumpAndLowerPunch() public;
    function doubleJumpAndLowerPunch() public;
    function trippleJumpAndLowerPunch() public;
    function walkAndPunch() public;
    function walkBackwardsAndPunch() public;
    function runAndPunch() public;
    function walkAndUpperPunch() public;
    function walkBackwardsAndUpperPunch() public;
    function runAndUpperPunch() public;
    function walkAndLowerPunch() public;
    function walkBackwardsAndLowerPunch() public;
    function runAndLowerPunch() public;
    function turnLeftAndPunch() public;
    function turnRightAndPunch() public;

    // Kicks
    function grabAndKick() public;
    function grabFromBackAndKick() public;
    function dockAndKick() public;
    function jumpAndKick() public;
    function doubleJumpAndKick() public;
    function trippleJumpAndKick() public;
    function jumpAndUpperKick() public;
    function doubleJumpAndUpperKick() public;
    function trippleJumpAndUpperKick() public;
    function jumpAndLowerKick() public;
    function doubleJumpAndLowerKick() public;
    function trippleJumpAndLowerKick() public;
    function walkAndKick() public;
    function walkBackwardsAndKick() public;
    function runAndKick() public;
    function walkAndUpperKick() public;
    function walkBackwardsAndUpperKick() public;
    function runAndUpperKick() public;
    function walkAndLowerKick() public;
    function walkBackwardsAndLowerKick() public;
    function runAndLowerKick() public;
    function turnLeftAndKick() public;
    function turnRightAndKick() public;

    function jumpGrabAndPunch() public;
    function doubleJumpGrabAndPunch() public;
    function trippleJumpGrabAndPunch() public;
    function jumpGrabAndKick() public;
    function doubleJumpGrabAndKick() public;
    function trippleJumpGrabAndKick() public;


    /*
    * @dev dWarrior states
    * These states represent the actions of the dWarrior when is hit by the oponent
    * These methods cause the actual damage to the player after hit by the oponent
    */
    function onIsPunched() internal;
    function onIsLowerPunched() internal;
    function onIsUpperPunched() internal;
    function onIsKicked() internal;
    function onIsLowerKicked() internal;
    function onIsUpperKicked() internal;
    
    function onIsGrabbedAndPunched() internal;
    function onIsGrabbedAndLowerPunched() internal;
    function onIsGrabbedAndUpperPunched() internal;
    function onIsGrabbedAndKicked() internal;
    function onIsGrabbedAndLowerKicked() internal;
    function onIsGrabbedAndUpperKicked() internal;

    /*
    @dev a face smash happens when grabbed from a tripple jump
    */
    function onIsFaceSmashed() internal;
}

/*
* @dev Official dWarriors have a sprite of each of the action methods
* All dWarriors cause the same damage according to this contract
* The dWarrior creator is free of designing the style, props and movement implementations
*/
contract dWarrior is dWarriorInterface {

    using SafeMath for uint256;

    dWart public token;

    address public creator;
    string public name;
    string public bio;

    uint256 public amountRaised = 0;
    uint256 public price = 1;
    uint256 public fights = 0;
    uint256 public fightsThreshold = 15;

    /*
    * @dev Initial life means that the warrior can take
    * 3 upper kicks, 3 upper punches, 3 distance powers, 1 power combo and any damage in between
    * before lossing the round
    */
    uint256 public life = 31;

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
  
    constructor(
    dWart _token,
    string _name, 
    string _bio
    ) public {
        creator = msg.sender;
        name = _name;
        bio = _bio;
        token = _token;
    }

    function() external {
        select();
    }

    /*
    * @dev a Player selects this dWarrior for a Match
    * Whenever the fights threshold is reached, the price of selecting the warrior increases + 1
    * as well as the life + 5
    */
    function select() public {
        require(token.balanceOf(msg.sender) >= price);
        token.transferFrom(msg.sender, creator, price);
        amountRaised = amountRaised.add(price);
        fights = fights.add(1);
        if (fights % fightsThreshold == 0) {
            price = price.add(1);
            life = life.add(5);
        }
    }
}

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