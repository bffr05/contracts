
// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./IGate.sol";
import "./GateIn.sol";
import "./GateOut.sol";
import "./GateBase.sol";
import "./GateLibTranscript.sol";

import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../base/utils/Locator.sol";
import "../base/token/Token.sol";
import "../base/access/Operatorable.sol"; 

contract Gate is Ownable,Location,GateIn,GateOut { //

    function supportsInterface(bytes4 interfaceId_) public view override(Ownable,OperatorableClient,IERC165) returns (bool) { //Access,
        return
            OperatorableClient.supportsInterface(interfaceId_) ||
            Ownable.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IGate).interfaceId ||
            interfaceId_ == type(IRGate).interfaceId ||
            interfaceId_ == type(IERC721Receiver).interfaceId ||
            interfaceId_ == type(IERC1155Receiver).interfaceId;
    }
    //uint256 immutable public chainid;


    using Array for address[];
/*
    function isValidOperator(address op_) external returns (bool) {
        return isOperator(ownerOf(),op_);
    }
*/



/*
    struct Chain {
        bool    active;
        uint240 fee;
    }
    mapping(uint56 => Chain) public chain;
    function setChain(uint56 chainId_, bool active_, uint240 fee_) external onlyOperator(ownerOf()) {
        chain[chainId_]=Chain({active:active_,fee:fee_});
    }
*/

}

