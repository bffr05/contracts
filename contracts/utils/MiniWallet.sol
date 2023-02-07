// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "./ForwarderContext.sol";


abstract contract MiniWallet is ForwarderContext {

    mapping(address => uint256) private _wallets;
    uint256 private totalwallet;

    modifier valued() virtual {
        _wallets[_msgSender()]+=msg.value;
        totalwallet+=msg.value;
        _;
    }

    receive() external virtual payable valued {
    }
    function total() external returns (uint256) {
        return totalwallet;
    }
    function balance() external returns (uint256) {
        return balance(address(0));
    }
    function balance(address wallet_) public returns (uint256) {
        return _wallets[wallet_!=address(0)?wallet_:_msgSender()];
    }
    function fund(address wallet_) external virtual payable {
        _wallets[wallet_]+=msg.value;
        totalwallet+=msg.value;
    }
    function refund() external {
        uint256 value = _wallets[_msgSender()];
        _wallets[_msgSender()] = 0;
        totalwallet-=value;
        payable(_msgSender()).transfer(value);
    }

    function _pop(address wallet_,uint256 value_) internal {
        _wallets[wallet_]-=value_;
        totalwallet-=value_;
    }
    function _push(address wallet_,uint256 value_) internal {
        _wallets[wallet_]+=value_;
        totalwallet+=value_;
    }
}