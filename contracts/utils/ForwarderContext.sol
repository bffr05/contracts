// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import "./Tools.sol";

abstract contract ForwarderContext is Context {

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return false;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return Tools.getTailAddress();
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}