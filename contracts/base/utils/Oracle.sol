// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "../access/Trustable.sol";
import "./Locator.sol";
import "./Array.sol";

bytes32 constant kOracle = keccak256("Oracle");

interface IOracle {
    function get(bytes32 hash_) external view returns (bytes memory out_);
    function timestamp(bytes32 hash_) external view returns (uint256 out_);

    function set(bytes32 hash_, bytes calldata data_) external;
    function unset(bytes32 hash_) external;


    function set(string memory arg_, bytes calldata data_) external;
    function hash(string memory arg_) external  view returns (bytes32);
    function hash( address writer_, string memory arg_) external view returns (bytes32);

}
interface IOracleDynamic {
    function get(bytes32 hash_) external view returns (bytes memory out_);
    function timestamp(bytes32 hash_) external view returns (uint256 out_);
} 
contract Oracle is Ownable,Location,TrustableClient,IOracle {
    mapping(bytes32 => uint256) internal _timestamp;
    mapping(bytes32 => bytes) internal _oracle;
    using Array for address[];

    address[] internal _dynamic;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (Ownable,TrustableClient)
        returns (bool)
    {
        return
            Ownable.supportsInterface(interfaceId) ||
            TrustableClient.supportsInterface(interfaceId) ||
            interfaceId == type(IOracle).interfaceId;
    }

    function getUInt256(bytes32 hash_) public view returns (uint256 out_) {
        return abi.decode(get(hash_),(uint256));
    }

    function get(bytes32 hash_) public view returns (bytes memory out_) {
        if (!_dynamic.exist(_msgSender()))
            for (uint i=0;i<_dynamic.length;i++)
                if (IOracleDynamic(_dynamic[i]).timestamp(hash_)!=0)
                    return IOracleDynamic(_dynamic[i]).get(hash_);
        return _oracle[hash_];
    }
    function timestamp(bytes32 hash_) public view returns (uint256 out_) {
        if (!_dynamic.exist(_msgSender()))
            for (uint i=0;i<_dynamic.length;i++)
                if (IOracleDynamic(_dynamic[i]).timestamp(hash_)!=0)
                    return IOracleDynamic(_dynamic[i]).timestamp(hash_);
        out_ = _timestamp[hash_];
    }
    
    function insert(address feed_) public onlyTrusted {
        _dynamic.insert(feed_);
    }
    function remove(address feed_) public onlyTrusted {
        _dynamic.remove(feed_);
    }

    function set(bytes32 hash_, uint256 data_) public onlyTrusted {
        _oracle[hash_] = abi.encode(data_);
        _timestamp[hash_] = block.timestamp;
    }
    function set(bytes32 hash_, bytes calldata data_) public onlyTrusted {
        _oracle[hash_] = data_;
        _timestamp[hash_] = block.timestamp;
    }
    function unset(bytes32 hash_) public onlyTrusted {
        delete _oracle[hash_];
        delete _timestamp[hash_];
    }
    function set(string memory arg_, bytes calldata data_) public {
        Oracle(this).set(hash(arg_),data_);
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

