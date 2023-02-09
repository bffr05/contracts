// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "../access/Trustable.sol";

bytes32 constant kCoinWallet = keccak256("CoinWallet");

abstract contract CoinWallet is TrustableClient {

    mapping(address => uint256) private _wallets;

    modifier valued() virtual {
        _wallets[_msgSender()]+=msg.value;
        _;
    }

    receive() external virtual payable valued {
    }
    function balance(address wallet_) public returns (uint256) {
        return _wallets[wallet_];
    }
    function fund(address wallet_) external virtual payable {
        _wallets[wallet_]+=msg.value;
    }
    function refund() external {
        uint256 value = _wallets[_msgSender()];
        _wallets[_msgSender()] = 0;
        payable(_msgSender()).transfer(value);
    }

    function pop(address wallet_,uint256 value_) public onlyTrusted {
        _wallets[wallet_]-=value_;
        _wallets[_msgSender()]+=value_;
    }
    function push(address wallet_,uint256 value_) public onlyTrusted {
        _wallets[_msgSender()]-=value_;
        _wallets[wallet_]+=value_;
    }
}