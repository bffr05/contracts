// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

//import "@solidity-bytes-utils/contracts/BytesLib.sol";

import "../../../interfaces/base/IAble.sol";
import "../../base/access/Ownable.sol";
import "../../base/utils/Array.sol";
import "../machine/Machine.sol";
import "../../base/token/IBEP20.sol";
import "./IMERC777.sol";
import "../../base/utils/Error.sol";


abstract contract aMERC777 is
    Machine,
    IERC777,
    IMERC777,
    IBEP20
{
    // GHOST and Direct
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(Machine)
        returns (bool)
    {
        if (TokenPlace(location(kTokenPlace)).exists(msg.sender))
            if (interfaceId_ == type(IERC777).interfaceId ||
            interfaceId_ == type(IBEP20).interfaceId )
                return true;
        return super.supportsInterface(interfaceId_)||
            interfaceId_ == type(IMERC777).interfaceId;
    }

    //constructor(TokenPlace tokenplace_) Machine(tokenplace_) {}

    //using Address for address;
    //using BytesLib for bytes;
    using Strings for uint256;
    using Array for uint256[];

    mapping(address => mapping(address => uint256)) private _balances;
    mapping(address => uint256) private _totalSupply;
    mapping(address => mapping(address => mapping(address => uint256)))
        private _allowances;



    function features(address ) public virtual view override returns (uint40) {
        return Token.TypeERC777 | Token.FT | Token.ERC165;
    }

    function defaultOperators()
        external
        pure
        override(IERC777,IMERC777)
        returns (address[] memory)
    {
        return new address[](0);
    }

    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        operatorBurn(msg.sender,account, amount, data, operatorData);
    }

    function operatorBurn(
        address token,
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) public {
        if (!isOperatorFor(_msgSender(), account))
            revert Unauthorized(Unauthorized_Reason.onlyOperator);
        _burn(token, account, amount, data, operatorData);
    }

    // GHOST
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        operatorSend(msg.sender,
            sender,
            recipient,
            amount,
            data,
            operatorData);
    }

    function operatorSend(
        address token,
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) public {
        if (!isOperatorFor(_msgSender(), sender))
            revert Unauthorized(Unauthorized_Reason.onlyOperator);
        _send(
            token,
            sender,
            recipient,
            amount,
            data,
            operatorData,
            true
        );
    }

    function getOwner(address token) external view returns (address) {
        return TokenPlace(location(kTokenPlace)).creatorOf(token);
    }

    function getOwner() external view returns (address) {
        return ownerOf();
    }

    function ownerOf() public view virtual override(Ownable) returns (address) {
        if (validLocator())
            if (TokenPlace(location(kTokenPlace)).exists(msg.sender)) 
                return TokenPlace(location(kTokenPlace)).creatorOf(msg.sender);
        return Ownable.ownerOf();
    }

    function name()
        public
        view
        virtual
        override(IERC20Metadata, IERC777)
        returns (string memory)
    {
        return name(msg.sender);
    }
/*
    function name(address token)
        public
        view
        virtual
        override(Machine)
        returns (string memory)
    {
        return TokenPlace(location(kTokenPlace)).name(token);
    }
*/

    // GHOST
    function symbol()
        public
        view
        virtual
        override(IERC20Metadata, IERC777)
        returns (string memory)
    {
        return symbol(msg.sender);
    }
/*
    function symbol(address token)
        public
        view
        virtual
        override(Machine)
        returns (string memory)
    {
        return TokenPlace(location(kTokenPlace)).symbol(token);
    }
*/
    // GHOST
    function decimals()
        public
        view
        virtual
        override(IERC20Metadata)
        returns (uint8)
    {
        return decimals(msg.sender);
    }

    function decimals(address ) public view virtual returns (uint8) {
        return 18;
    }

    // GHOST
    function granularity() public view virtual override returns (uint256) {
        return granularity(msg.sender);
    }

    function granularity(address ) public view virtual returns (uint256) {
        return 1;
    }

    // GHOST
    function totalSupply()
        public
        view
        virtual
        override(IERC777, IERC20)
        returns (uint256)
    {
        return totalSupply(msg.sender);
    }

    function totalSupply(address token) public view virtual returns (uint256) {
        return _totalSupply[token];
    }

    // GHOST
    function balanceOf(address tokenHolder)
        public
        view
        virtual
        override(IERC777, IERC20)
        returns (uint256)
    {
        return balanceOf(msg.sender, tokenHolder);
    }

    function balanceOf(address token, address tokenHolder)
        public
        view
        virtual
        returns (uint256)
    {
        return _balances[token][tokenHolder];
    }

    function send(
        address token,
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual {
        _send(token, _msgSender(), recipient, amount, data, "", true);
    }

    // GHOST
    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        _send(
            msg.sender,
            _msgSender(),
            recipient,
            amount,
            data,
            "",
            true
        );
    }

    function transfer(
        address token,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        _send(token, _msgSender(), recipient, amount, "", "", false);
        return true;
    }

    // GHOST
    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _send(
            msg.sender,
            _msgSender(),
            recipient,
            amount,
            "",
            "",
            false
        );
        return true;
    }

    function burn(
        address token,
        uint256 amount,
        bytes memory data
    ) public virtual {
        _burn(token, _msgSender(), amount, data, "");
    }

    // GHOST
    function burn(uint256 amount, bytes memory data) public virtual override {
        _burn(msg.sender, _msgSender(), amount, data, "");
    }

    function isOperatorFor(address operator, address tokenHolder)
        public
        view
        virtual
        override(IERC777,IMERC777, OperatorableClient)
        returns (bool)
    {
        return OperatorableClient.isApprovedForAll(operator, tokenHolder);
    }

    // GHOST
    function authorizeOperator(address operator)
        public
        virtual
        override(IERC777, IMERC777,OperatorableClient)
    {
        OperatorableClient.authorizeOperator(operator);
        emit AuthorizedOperator(operator, _msgSender());
    }

    // GHOST
    function revokeOperator(address operator)
        public
        virtual
        override(IERC777,IMERC777,OperatorableClient)
    {
        OperatorableClient.revokeOperator(operator);
        emit RevokedOperator(operator, _msgSender());
    }

    function allowance(
        address token,
        address holder,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[token][holder][spender];
    }

    // PROB
    // GHOST
    function allowance(address holder, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return allowance(msg.sender, holder, spender);
    }

    // PROB
    function approve(
        address token,
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        _approve(token, _msgSender(), spender, value);
        return true;
    }

    // GHOST
    function approve(address spender, uint256 value)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            _msgSender(),
            spender,
            value
        );
        return true;
    }

    function transferFrom(
        address token,
        address holder,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        _spendAllowance(token, holder, _msgSender(), amount);
        _send(token, holder, recipient, amount, "", "", false);
        return true;
    }

    // GHOST
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
       _spendAllowance(msg.sender, holder, _msgSender(), amount);
        _send(msg.sender, holder, recipient, amount, "", "", false);
        return true;
    }

    function mint(
        address token,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        if (TokenPlace(location(kTokenPlace)).creatorOf(token) != _msgSender())
            revert Unauthorized(Unauthorized_Reason.onlyCreator);
        _mint(token, to, amount, userData, operatorData);
    }
    function burn(
        address token,
        address from,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        if (TokenPlace(location(kTokenPlace)).creatorOf(token) != _msgSender())
            revert Unauthorized(Unauthorized_Reason.onlyCreator);
        _burn(token, from, amount, userData, operatorData);
    }

    function mint(
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        mint(msg.sender, to, amount, userData, operatorData);
    }
    function burn(
        address from,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        burn(msg.sender, from, amount, userData, operatorData);
    }

    function _mint(
        address token,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        _mint(token, account, amount, userData, operatorData, true);
    }

    function _mint(
        address token,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        if (account == address(0))
            revert ZeroAddress();

        _beforeTokenTransfer(token, _msgSender(), address(0), account, amount);

        // Update state variables
        _totalSupply[token] += amount;
        _balances[token][account] += amount;

        _callTokensReceived(
            token,
            address(0),
            account,
            amount,
            userData,
            operatorData,
            requireReceptionAck
        );
        emit TokenMinted(
            token,
            _msgSender(),
            account,
            amount,
            userData,
            operatorData
        );
        emit TokenTransfer(token, address(0), account, amount);
    }

    function _send(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        if (from == address(0) || to == address(0))
            revert ZeroAddress();

        _callTokensToSend(
            token,
            from,
            to,
            amount,
            userData,
            operatorData
        );

        _move(token, from, to, amount, userData, operatorData);

        _callTokensReceived(
            token,
            from,
            to,
            amount,
            userData,
            operatorData,
            requireReceptionAck
        );
    }

    function _burn(
        address token,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        if (from == address(0))
            revert ZeroAddress();

        _callTokensToSend(
            token,
            from,
            address(0),
            amount,
            data,
            operatorData
        );

        _beforeTokenTransfer(token, _msgSender(), from, address(0), amount);

        // Update state variables
        uint256 fromBalance = _balances[token][from];
        if (fromBalance < amount)
            revert BalanceExceeded();
        unchecked {
            _balances[token][from] = fromBalance - amount;
        }
        _totalSupply[token] -= amount;
        emit TokenBurned(token, _msgSender(), from, amount, data, operatorData);
        emit TokenTransfer(token, from, address(0), amount);
    }

    function _move(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        _beforeTokenTransfer(token, _msgSender(), from, to, amount);

        uint256 fromBalance = _balances[token][from];
        if (fromBalance < amount)
            revert BalanceExceeded();

        unchecked {
            _balances[token][from] = fromBalance - amount;
        }
        _balances[token][to] += amount;
        emit TokenSent(
            token,
            _msgSender(),
            from,
            to,
            amount,
            userData,
            operatorData
        );
        emit TokenTransfer(token, from, to, amount);
    }

    function _approve(
        address token,
        address holder,
        address spender,
        uint256 value
    ) internal virtual {
        if (holder == address(0) || spender == address(0))
            revert ZeroAddress();

        _allowances[token][holder][spender] = value;
        emit TokenApproval(token, holder, spender, value);
    }

    function _callTokensToSend(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        /*address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }*/
    }

    function _callTokensReceived(
        address token,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        /*address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.code.length != 0, "MERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }*/
    }

    function _spendAllowance(
        address token,
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(token, owner, spender);
        if (currentAllowance != type(uint256).max) {
            if(currentAllowance < amount)
                revert AllowanceExceeded();
            unchecked {
                _approve(token, owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address , //token,
        address , //msgsender,
        address , //from,
        address , //to,
        uint256 //amount
    ) internal virtual {
        if (paused())
            revert Paused();

    }
}
