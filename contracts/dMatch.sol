pragma solidity ^0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';
import './dWart.sol';
import './dWaria.sol';

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
        _enterPlayer1(_warrior);
    }

    function() external {}

    function _init(dWarrior _warrior) pendingOponent internal {
        players[msg.sender].warrior = _warrior;
        players[msg.sender].damage = 0;
        players[msg.sender].points = 0;
    }

    function _enterPlayer1(dWarrior _warrior) pendingOponent internal {
        require(player1 != msg.sender);
        player1 = msg.sender;
        token.transferFrom(msg.sender, address(this), bet);
        _init(_warrior);
    }
    
    function enterPlayer2(dWarrior _warrior) pendingOponent public {
        require(player2 == address(0));
        require(token.balanceOf(msg.sender) >= bet);
        player2 = msg.sender;
        bet = bet.add(bet);
        token.transferFrom(msg.sender, address(this), bet);
        _init(_warrior);
        state = State.pendingWinner;
    }

    /*
    * @dev Starts the fight
    * This method must be called only by the official dWaria contract reference
    * Both players must be ready to fight
    * Ready means their connection is stable and the websockets are plugged in and listening
    */
    function fight() onlyDWaria pendingWinner public {
        round = round.add(1);
    }

    function endRound(
    uint256 player1Damage,
    uint256 player1Points,
    uint256 player2Damage,
    uint256 player2Points
    ) onlyDWaria pendingWinner public {
        require(player1Damage >= 0 && player1Points >= 0);
        require(player2Damage >= 0 && player2Points >= 0);

        players[player1].damage = player1Damage;
        players[player1].points = player1Points;
        players[player2].damage = player2Damage;
        players[player2].points = player2Points;

        // if () 
        // rounds[round].winner = _winner;
        // rounds[round].loser = _loser;
    }

    function setResult(address _winner, address _loser) onlyDWaria pendingWinner public {
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