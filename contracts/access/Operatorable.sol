// SPDX-License-Identifier: MIT
// Beef Access Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.0;

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

contract Operatorable is IERC165, Trustable, IOperatorable, IROperatorable {
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(Trustable, IERC165)
        returns (bool)
    {
        return
            Trustable.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IOperatorable).interfaceId ||
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
    function setApprovalForAll(address operator_, bool approved_)
        public
        virtual
    {
        return setOperator(operator_, approved_);
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

    function authorizeOperator(address operator_) public virtual {
        return setOperator(operator_, true);
    }

    function revokeOperator(address operator_) public virtual {
        return setOperator(operator_, false);
    }

    modifier onlyOperator(address user_) {
        require(
            isOperator(user_, _msgSender()),
            "Operatorable: caller is not operator_"
        );
        _;
    }

    function setOperator(address operator_, bool approved_) public {
        _setOperator(_msgSender(), operator_, approved_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          restricted public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function setOperator(
        address user_,
        address operator_,
        bool approved_
    ) public onlyTrusted {
        _setOperator(user_, operator_, approved_);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          public/external functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function getOperators(address user_)
        public
        view
        returns (address[] memory)
    {
        if (isReferred())
            if (Operatorable(referral()).isTrusted(address(this)))
                return Operatorable(referral()).getOperators(user_);
        return _operators[user_];
    }

    function isOperator(address user_, address operator_)
        public
        view
        returns (bool)
    {
        if (isReferred())
            if (Operatorable(referral()).isTrusted(address(this)))
                return Operatorable(referral()).isOperator(user_, operator_);
        return _operators[user_].exist(operator_) || user_ == operator_;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          internal functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function _setOperator(
        address user_,
        address operator_,
        bool approved_
    ) internal {
        if (isReferred()) 
            if (Operatorable(referral()).isTrusted(address(this)))
                return Operatorable(referral()).setOperator(user_,operator_,approved_);
        assert(user_ != operator_);
        if (approved_) _operators[user_].insert(operator_);
        else _operators[user_].remove(operator_);
        emit Operated(user_, operator_, approved_);
    }
}
