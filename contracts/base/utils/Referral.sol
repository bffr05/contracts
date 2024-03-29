// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../access/Ownable.sol";
import "./Error.sol";
import "./Tools.sol";

abstract contract ReferralBasic {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    address          internal       _referral;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    constructor(address referral_) { _referral = referral_; }
    
    function referral() public view virtual returns (address) {
        return _referral;
    }

}
interface IReferral  {
    function referral() external view returns (address);
    function isReferred() external view returns (bool);
}

abstract contract Referral is IERC165,IReferral,Ownable { 
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165,Ownable)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId) ||
            interfaceId == type(IReferral).interfaceId;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    address          private      _referral;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*constructor() {
        _referral = referral_;
    }*/

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          modifiers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    modifier onlyReferral() {
        if (msg.sender!=referral()) revert Unauthorized(Unauthorized_Reason.onlyReferral);
        _;
    }
    modifier delegateIfReferral() {
        if (isReferred())
            Tools.delegate(referral());
        else
            _;
    }
    function setReferral(address arg_) external onlyOwner {
        _setReferral(arg_);
    }
    function _setReferral(address arg_) internal {
        _referral = arg_;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external view functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function referral() public view virtual returns (address) {
        return _referral;
    }
    function isReferred() public view virtual returns (bool) {

        return referral()!=address(0) && referral() != msg.sender;
    }
}

