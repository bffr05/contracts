// SPDX-License-Identifier: MIT
// Beef Access Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
//import "@openzeppelin/contracts/utils/Context.sol";
import "../utils/ForwarderContext.sol";

interface IOwnable {
    event Owned(address indexed from,address indexed to);

    function ownerOf() external view returns (address);
    function isOwner(address caller) external view returns (bool);

}
interface IROwnable {
    function transfer(address to) external;
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transfer}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is IERC165, IOwnable,IROwnable,ForwarderContext {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(IERC165)
        returns (bool)
    {
        return
            interfaceId_ == type(IOwnable).interfaceId||
            interfaceId_ == type(IROwnable).interfaceId;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    address private _owner;
 
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transfer(msg.sender);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          modifiers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// @dev Private method is used instead of inlining into modifier because modifiers are copied into each method,
    ///     and the use of immutable means the address bytes are copied in every place the modifier is used.
    function checkOnlyOwner() internal view {
        require(isOwner(_msgSender()),"Ownable: caller is not the owner");
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() virtual {
        checkOnlyOwner();
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          restricted public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner_`).
     * Can only be called by the current owner.
     */
    function transfer(address newOwner_) public virtual onlyOwner {
        require(newOwner_ != address(0),"Ownable: new owner is the zero address");
        _transfer(newOwner_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external view functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns the address of the current owner.
     */
    function ownerOf() public view virtual returns (address) {
        return _owner;
    }

    function isOwner(address caller_) public view virtual returns (bool) {
        return (caller_ == _owner || caller_ == address(this));
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          internal functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner_`).
     * Internal function without access restriction.
     */
    function _transfer(address newOwner_) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner_;
        emit Owned(oldOwner, newOwner_);
    }
}
