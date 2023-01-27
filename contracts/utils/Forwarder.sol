// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.0;

import "./Tools.sol";

bytes32 constant kForwarder_Deployer = keccak256("Forwarder_Deployer");

/*
//----------------- 00                              01                               02                              03                               04                              05                               06                              07                               08                              09
//----------------- 000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f 000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f 000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f 000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f 000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f
//  Init            3d604280600a3d3981f3
//  Compile cr   4c 3d604280600a3d3981f360806040523660008037333652600080602036016000 3473bebebebebebebebebebebebebebebebebebebebe5af13d6000803e808015 603d573d6000f35b3d6000fd
//  Compile rt   42 608060405236600080373336526000806020360160003473bebebebebebebebe bebebebebebebebebebebebe5af13d6000803e808015603d573d6000f35b3d60 00fd

contract Forwarder_byte
{
    //using Tools for address;
    address          constant       _delegate=0xBEbeBeBEbeBebeBeBEBEbebEBeBeBebeBeBebebe;
   
    fallback() external virtual payable {
        assembly {

            calldatacopy(0, 0, calldatasize())
            mstore(calldatasize(),caller()) 

            let result := call(gas(), _delegate,callvalue(), 0, add(calldatasize(),32), 0, 0)

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

}
*/

contract Forwarder  {
    using Tools for address;
    address          internal       _delegate;
   
    fallback() external virtual payable {
        //if (msg.sender == _delegate)
        //    Tools.delegateToTailAddress();
        _delegate.forwardWithTailMsgSender();
    }

    constructor(address delegate_)  {
        _delegate = delegate_;
    }

}

interface IForwarder_Deployer
{
    //function getBytecode() external view returns (bytes memory);
    //function deploy(address delegate_) external returns (address);
    function deploy(address delegate_, bytes32 salt_) external returns (address);
    function predict(address delegate_,bytes32 salt_) external view returns (address); 
}
contract Forwarder_Deployer is IForwarder_Deployer {

    /*function getBytecode() public view virtual returns (bytes memory) {
        return type(Forwarder).creationCode; 
    }

    function deploy(address delegate_) public virtual returns (address) {
        return address(new Forwarder(delegate_));
    }*/
   
    
    function deploy(address delegate_, bytes32 salt_) public returns (address instance) {
        assembly {
            let ptr := mload(0x40)
           
            mstore(ptr,             0x3d604280600a3d3981f360806040523660008037333652600080602036016000)
            mstore(add(ptr, 0x20),  0x3473000000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x22), shl(0x60, delegate_))
            mstore(add(ptr, 0x36),  0x5af13d6000803e808015603d573d6000f35b3d6000fd00000000000000000000)
            instance := create2(0, ptr, 0x4c, salt_)
        }
    }



    function predict(address delegate_,bytes32 salt_) public view returns (address predicted_) {
        
        address deployer = address(this);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr,             0x3d604280600a3d3981f360806040523660008037333652600080602036016000)
            mstore(add(ptr, 0x20),  0x3473000000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x22), shl(0x60, delegate_))
            mstore(add(ptr, 0x36),  0x5af13d6000803e808015603d573d6000f35b3d6000fdff000000000000000000)
            mstore(add(ptr, 0x4d), shl(0x60, deployer))
            mstore(add(ptr, 0x61), salt_)
            mstore(add(ptr, 0x81), keccak256(ptr, 0x4c))
            predicted_ := keccak256(add(ptr, 0x4c), 0x55)
        }
    }

}
