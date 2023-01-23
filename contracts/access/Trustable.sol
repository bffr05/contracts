// SPDX-License-Identifier: MIT
// Beef Access Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "../utils/Array.sol";
import "./Ownable.sol";
import "../utils/Referral.sol";
import "../utils/Tools.sol";
import "../utils/Locator.sol";

bytes32 constant kAccess = keccak256("Access");


interface ITrustable {
    function isTrusted(address trusted_) external view returns (bool);
}

interface IRTrustable {
    function setHash(bytes32 hash_, bool approved_) external;
    function set(address trusted_, bool approved_) external;
    function setContract(address trusted_, bool approved_) external;
}

contract Trustable is Ownable,Location, Referral, ITrustable, IRTrustable {


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(Ownable, Referral)
        returns (bool)
    {
        return
            Ownable.supportsInterface(interfaceId) ||
            Referral.supportsInterface(interfaceId) ||
            interfaceId == type(ITrustable).interfaceId ||
            interfaceId == type(IRTrustable).interfaceId;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          using
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    using Array for address[];
    using Array for bytes32[];
    using Tools for address;
    using Tools for bytes32;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    bytes32[] private _hashs;
    mapping(address => address[]) internal _operators;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    constructor() {}

    function referral() public view virtual override returns (address out_) {
        if (super.referral()!=address(0))
            return super.referral();
        if (locator().code.length == 0)
            return address(0);
        out_ = get(kAccess);
        if (out_==address(this))
            out_=address(0);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          modifiers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    modifier onlyTrusted() {
        require(isTrusted(msg.sender), "caller is not trusted");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          restricted public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setHash(bytes32 hash_, bool approved_) public {
        if (isReferred())
            if (Trustable(referral()).isTrusted(address(this)))
                return Trustable(referral()).setHash(hash_, approved_);

        require(isTrusted(msg.sender),"caller is not owner or trusted");

        if (hash_.isKeccakNull() || hash_ == 0) return;
        if (approved_) _hashs.insert(hash_);
        else _hashs.remove(hash_);
    }

    function set(address contract_, bool approved_) public {
        setHash(contract_.hash(), approved_);
        setContract(contract_, approved_);
    }

    function setContract(address contract_, bool approved_) public {
        if (isReferred())
            if (Trustable(referral()).isTrusted(address(this)))
                return Trustable(referral()).setContract(contract_, approved_);

        require(isTrusted(msg.sender),"caller is not owner or trusted");

        if (contract_ == address(0)) return;
        if (approved_) _operators[address(this)].insert(contract_);
        else _operators[address(this)].remove(contract_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external view functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function isTrusted(address trusted_) public view returns (bool) {
        if (isReferred())
            if (Trustable(referral()).isTrusted(address(this)))        
                return Trustable(referral()).isTrusted(trusted_);

        if (isOwner(trusted_) || _hashs.s_exist(trusted_.hash())) return true;
        return _operators[address(this)].s_exist(trusted_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
