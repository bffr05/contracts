// SPDX-License-Identifier: MIT
// Beef Access Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "../utils/Array.sol";
import "./Trustable.sol";

interface IOperatorable_ERC777 {
    function isOperatorFor(address operator, address tokenHolder)
        external
        view
        returns (bool);

    function authorizeOperator(address operator) external;

    function revokeOperator(address operator) external;
}

interface IOperatorable_ERC721 {
    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IOperatorable is IOperatorable_ERC721, IOperatorable_ERC777 {
    event Operated(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setOperator(address operator, bool approved) external;

    function getOperators(address owner)
        external
        view
        returns (address[] memory);

    function isOperator(address owner, address operator)
        external
        view
        returns (bool);
}

interface IROperatorable {
    function setOperator(
        address user_,
        address operator_,
        bool approved_
    ) external;
}

contract OperatorableClient is TrustableClient, IOperatorable {
    
    using Tools for address;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(TrustableClient)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IOperatorable).interfaceId ||
            interfaceId_ == type(IROperatorable).interfaceId;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          _msgSender() public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setApprovalForAll(address operator_, bool approved_) public virtual {
        return setOperator(operator_, approved_);
    }
    function authorizeOperator(address operator_) public virtual {
        return setOperator(operator_, true);
    }
    function revokeOperator(address operator_) public virtual {
        return setOperator(operator_, false);
    }
    function setOperator(address operator_, bool approved_) public virtual {
        if (isReferred()) 
            if (ITrustable(referral()).isTrusted(address(this)))
                return IROperatorable(referral()).setOperator(_msgSender(),operator_,approved_);
    }


    function isApprovedForAll(address user_, address operator_)
        public
        view
        virtual
        returns (bool)
    {
        return isOperator(user_, operator_);
    }

    function isOperatorFor(address operator_, address tokenHolder)
        public
        view
        virtual
        returns (bool)
    {
        return isOperator(tokenHolder, operator_);
    }



    modifier onlyOperator(address user_) {
        require(
            isOperator(user_, _msgSender()),
            "Operatorable: caller is not operator_"
        );
        _;
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function getOperators(address user_) public virtual view returns (address[] memory) { //OK
        if (isReferred())
            return IOperatorable(referral()).getOperators(user_);
        return new address[](0);
    }

    function isOperator(address user_, address operator_) public virtual view returns (bool) { //OK
        if (isReferred())
            return IOperatorable(referral()).isOperator(user_, operator_);
        return false;
    }
}



contract OperatorableServer is TrustableClient,OperatorableClient, TrustableServer, IROperatorable {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(TrustableClient,OperatorableClient,TrustableServer)
        returns (bool)
    {
        return
            OperatorableClient.supportsInterface(interfaceId_) ||
            TrustableServer.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IROperatorable).interfaceId;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          using
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    using Array for address[];

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          attributes
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          constructor
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //constructor(address referral_) Trustable(referral_) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          _msgSender() public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setOperator(address operator_, bool approved_) public override virtual { //OK
        _setOperator(_msgSender(), operator_, approved_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          restricted public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setOperator(address user_,address operator_,bool approved_) public onlyTrusted { //OK
        _setOperator(user_, operator_, approved_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function getOperators(address user_) public virtual override view returns (address[] memory) { //OK
        if (isReferred())
            return IOperatorable(referral()).getOperators(user_);
        return _operators[user_];
    }

    function isOperator(address user_, address operator_) public virtual override view returns (bool) { //OK
        if (isReferred())
            return IOperatorable(referral()).isOperator(user_, operator_);
        return _operators[user_].exist(operator_) || user_ == operator_;
    }


    function isTrusted(address trusted_) public virtual override(TrustableClient,TrustableServer) view returns (bool) { //OK
        return TrustableServer.isTrusted(trusted_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          internal functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function _setOperator(address user_,address operator_,bool approved_) internal { //OK
        if (isReferred()) 
            if (ITrustable(referral()).isTrusted(address(this)))
                return IROperatorable(referral()).setOperator(user_,operator_,approved_);
        assert(user_ != operator_);
        if (approved_) 
            _operators[user_].insert(operator_);
        else 
            _operators[user_].remove(operator_);
        emit Operated(user_, operator_, approved_);
    }
}
