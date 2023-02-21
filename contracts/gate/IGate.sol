// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./GateTypes.sol";


interface IGateEvent {

}

interface IGateReturn {
    function GateOutReturned(uint256 nonce,bool result, bytes calldata returned, Message calldata remainer) external;
}
interface IGateOut {
    event Outbound(uint56 indexed chainId, uint256 indexed nonce,address src, Message message);
    event OutboundCompleted(uint256 indexed nonce,bool result, bytes returned, Message remainer);
    //function Out(uint56  chainId, Message memory message) external payable returns (uint256 nonce_);
}
interface IGateIn {
    event Inbound(uint56 indexed chainId, uint256 indexed nonce,address src, Message remainer, bool result, bytes returned);
}

interface IGate is IGateOut,IGateIn{
}


interface IBotGateIn {
    //function validIn(uint56 chainId_,uint256 nonce_) external view returns (bool);
    //function In(GateMessage[] calldata msgs_) external;
}
interface IBotGateOut {
    //function validOut(uint256 id_) external view returns (bool);
    //function OutCompleted(GateMessageCompleted[] calldata msgs_) external;
}

interface IBotGate is IBotGateOut,IBotGateIn{
}

interface IRGate is IBotGate {
}

