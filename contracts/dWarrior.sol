pragma solidity ^0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol';
import './dWart.sol';

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