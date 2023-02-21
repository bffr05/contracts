// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../../../interfaces/base/IAble.sol";
import "../../base/access/Operatorable.sol"; 


import "../../base/utils/Array.sol";
import "../../base/utils/Tools.sol";
import "../../base/utils/Forwarder.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../../base/utils/ForwarderContext.sol";
import "./IMachine.sol";
import "../../base/utils/Locator.sol";

abstract contract Machine is IERC165,Location, OperatorableClient, IMachine, IMachined {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(OperatorableClient, Ownable, IERC165)
        returns (bool)
    {
        if (TokenPlace(location(kTokenPlace)).exists(msg.sender))    
            if (interfaceId_ == type(IMachined).interfaceId)
                return true;    
        return (Ownable.supportsInterface(interfaceId_) ||
                OperatorableClient.supportsInterface(interfaceId_) ||
                interfaceId_ == type(IMachine).interfaceId);
    }

    function isTrustedForwarder(address forwarder) public view virtual override returns (bool) {
        if (!validLocator()) return false;
        return TokenPlace(location(kTokenPlace)).exists(forwarder);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          Attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //using Address for address;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          Constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    constructor() {}

    function paused() public view virtual returns (bool) {
        return false;
    }
    function machine() public view returns (address) {
        return address(this);
    }


    function name(address token_) public view virtual  returns (string memory) {
        return TokenPlace(location(kTokenPlace)).name(token_);
    }

    function symbol(address token_) public view virtual  returns (string memory) {
        return TokenPlace(location(kTokenPlace)).symbol(token_);
    }

    function creatorOf(address token_) public view returns (address) {
        return TokenPlace(location(kTokenPlace)).creatorOf(token_);
    }

    function exists(address token_) public view returns (bool) {
        return TokenPlace(location(kTokenPlace)).machine(token_) == address(this);
    }

    /*function msgSender() external view returns (address) {
        return Tools.getTailAddress();
    }
    function msgData() external view returns (bytes memory) {
        return msg.data;
    }*/


}
