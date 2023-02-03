// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

//import "@solidity-bytes-utils/contracts/BytesLib.sol";

library Tools  {
    //using BytesLib for bytes;


    bytes32 constant KECCAK256NULL = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function hash(address a_) internal view returns (bytes32 h) {
        assembly { h := extcodehash(a_) }
    }
    function isKeccakNull(bytes32 hash_) internal pure returns (bool) {
        return hash_ == KECCAK256NULL;
    }
    function forward(address delegate_) internal {
        (bool _result, ) = delegate_.call( msg.data);
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    function addTailMsgSender(bytes memory data_) internal view returns (bytes memory ) {
        return addTailAddress( data_, msg.sender );
    }
    function addTailAddress(bytes memory data_,address addr_) internal view returns (bytes memory ) {
        return abi.encodePacked( data_, addr_ );
    }
    function getTailAddress() internal pure returns (address sender_) {
        /// @solidity memory-safe-assembly
        assembly {
            sender_ := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
    /*function forwardWithTailMsgSender(address delegate_) internal {
        (bool _result, ) = delegate_.call(addTailMsgSender( msg.data));
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }*/
    function forwardWithTailMsgSender(address delegate_) internal {
        assembly {

            calldatacopy(0, 0, calldatasize())
            mstore(calldatasize(),caller()) 

            let result := call(gas(), delegate_,callvalue(), 0, add(calldatasize(),32), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    function forwardStaticWithTailMsgSender(address delegate_) internal view {
        assembly {

            calldatacopy(0, 0, calldatasize())
            mstore(calldatasize(),caller()) 

            let result := staticcall(gas(), delegate_, 0, add(calldatasize(),32), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    function delegate(address implementation_) internal {
        (bool _result, ) = implementation_.delegatecall(msg.data);
        assembly {
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
      
    }

    function forwardStatic(address delegate_) internal view {
        (bool _result, ) = delegate_.staticcall(msg.data);

        assembly {
            returndatacopy(0, 0, returndatasize())
            switch _result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    function create2Address(bytes memory bytecode_, bytes32 salt_) internal view returns (address) {
        bytes32 hashed = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt_, keccak256(bytecode_)));
        return address(uint160(uint(hashed)));
    }
    function create2(bytes memory bytecode_,bytes32 salt_) internal returns (address addr_) {
        assembly {
            addr_ := create2(
                callvalue(), 
                add(bytecode_, 0x20),
                mload(bytecode_), 
                salt_ 
            )

            if iszero(extcodesize(addr_)) {
                revert(0, 0)
            }
        }
    }
}
