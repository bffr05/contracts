// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com


// Locator.constructor      Gas used:   466 888
// Locator.transfer         Gas used:    28 637

pragma solidity ^0.8.0;

import "../access/Ownable.sol";

bytes32 constant kLocator = keccak256("Locator");

address constant LocatorAddress = 0x455b153B592d4411dCf5129643123639dcF3c806; 

interface ILocator {
    function location(bytes32 hash_) external view returns (address out_);
    function get(bytes32 hash_) external view returns (address out_);
    function get(string memory arg_) external view returns (address out_);
    function set(bytes32 hash_, address addr_) external;
    //function set(string memory arg_, address addr_) external;
    function hash(string memory arg_) external  pure returns (bytes32);
}
contract Locator is Ownable,ILocator {
    mapping(bytes32 => address) internal _location;

    function location(bytes32 hash_) public view returns (address out_) {
        out_ = get(hash_);
        require(out_!=address(0),"location failed");
    }
    function get(bytes32 hash_) public view returns (address out_) {
        if (_location[kLocator]!=address(0))
            out_=Locator(_location[kLocator]).get(hash_);
        if (out_==address(0))
            out_ = _location[hash_];
    }
    function get(string memory arg_) public view returns (address out_) {
        return get(keccak256(abi.encodePacked(arg_)));
    }

    function set(bytes32 hash_, address addr_) public onlyOwner() {
        _location[hash_] = addr_;
    }
    /*function set(string memory arg_, address addr_) public onlyOwner() {
        set(keccak256(abi.encodePacked(arg_)),addr_);
    }*/
     
    function hash(string memory arg_) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(arg_));
    }
}
interface ILocation {
    function setLocator(address arg_) external;
    function locator() external  view returns (address);
}

abstract contract LocationBase {
    address internal _locator = LocatorAddress; 


    function location(bytes32 arg_) public view returns (address out_) {
        require(_locator.code.length != 0,"Locator not found");
        out_ = Locator(_locator).location(arg_);
    }
    function location(string memory arg_) public view returns (address out_) {
        out_ = location(keccak256(abi.encodePacked(arg_)));
    }

}


abstract contract Location is LocationBase,ILocation,Ownable {
    function _setLocator(address arg_) internal {
        _locator = arg_;
    }
    function locator() public view returns (address) {
        return _locator;
    }
    function setLocator(address arg_) public onlyOwner() {
        _setLocator(arg_);
    }
}
