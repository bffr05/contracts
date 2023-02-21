// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com


// Locator.constructor      Gas used:   466 888
// Locator.transfer         Gas used:    28 637

pragma solidity ^0.8.17;

import "../access/Ownable.sol";
import "../utils/Error.sol";
import "../utils/Array.sol";

bytes32 constant kLocator = keccak256("Locator");

address constant LocatorAddress = 0xCC41D983Af9b191209e572D6F9871434019D35F4; 

interface ILocator {
    function location(bytes32 hash_) external view returns (address out_);
    function get(bytes32 hash_) external view returns (address out_);
    //function get(string memory arg_) external view returns (address out_);
    function set(bytes32 hash_, address addr_) external;
    function set(string memory arg_, address addr_) external;
    function hash(string memory arg_) external  view returns (bytes32);
    function hash( address writer_, string memory arg_) external view returns (bytes32);
}
contract Locator is Ownable,ILocator {
    //bool immutable writeonce = false;
    mapping(bytes32 => address) internal _location;

    function location(bytes32 hash_) public view returns (address out_) {
        out_ = get(hash_);
        if (out_==address(0)) revert Failed();
    }

    function _getHistory(bytes32 hash_,address[] memory in_) internal view returns (address[] memory out_) {
        address addr=_location[keccak256(abi.encodePacked(hash_,in_[in_.length-1]))];
        if (addr==address(0))
            return in_;
        out_ = new address[](in_.length+1);
        for (uint i=0;i<in_.length;i++)
            out_[i] = in_[i];
        out_[in_.length]==addr;
        return _getHistory(hash_,out_);

    }
    function getHistory(bytes32 hash_) public view returns (address[] memory out_) {
        address addr = get(hash_);
        if (addr==address(0))
            return new address[](0);
        return _getHistory(hash_,Array.munique(addr));
    }
    function get(bytes32 hash_) public view returns (address out_) {
        if (_location[kLocator]!=address(0))
            out_=Locator(_location[kLocator]).get(hash_);
        if (out_==address(0))
            out_ = _location[hash_];
    }
    function set(bytes32 hash_, address addr_) public onlyOwner {
        if (_location[hash_]!=address(0))
            _location[keccak256(abi.encodePacked(hash_,addr_))] = _location[hash_];
        _location[hash_] = addr_;

    }
    function set(string memory arg_, address addr_) public {
        Locator(this).set(hash(arg_),addr_);
    }
    function hash( address writer_, string memory arg_) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(writer_,arg_));
    }
    function hash(string memory arg_) public view returns (bytes32) {
        if (_msgSender()==ownerOf())
            return keccak256(abi.encodePacked(arg_));
        else
            return hash(_msgSender(),arg_);
    }
}
interface ILocation {
    function setLocator(address arg_) external;
    function locator() external  view returns (address);
}

abstract contract LocationBase {
    address internal _locator = LocatorAddress; 

    function validLocator() public view returns (bool) {
        return _locator.code.length != 0;
    }
    function location(bytes32 arg_) public view returns (address out_) {
        if (!validLocator()) revert Failed();
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
    function setLocator(address arg_) public onlyOwner {
        _setLocator(arg_);
    }
}
