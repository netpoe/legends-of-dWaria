pragma solidity ^0.4.21;

import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol';

contract dWart is StandardToken, DetailedERC20 {
    constructor ()
    public DetailedERC20 ('dWart Token', 'dWART', 18) {
        uint256 supply = 21000000 * 1 ether;
        totalSupply_ = supply;
        balances[msg.sender] = supply;
        emit Transfer(0x0, msg.sender, supply);
    }
}