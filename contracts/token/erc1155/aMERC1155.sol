// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../../interfaces/base/IAble.sol";
import "../../base/access/Ownable.sol";
import "../../base/utils/Array.sol";

import "../machine/Machine.sol";
import "./IMERC1155.sol";


abstract contract aMERC1155 is
    Machine,
    IERC1155,
    IMERC1155
{

    using Address for address;

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(Machine,IERC165)
        returns (bool)
    {
        if (TokenPlace(location(kTokenPlace)).exists(msg.sender))
            if (interfaceId_ == type(IERC1155).interfaceId)
                return true;
        return
            super.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IMERC1155).interfaceId;
    }

    //constructor(TokenPlace tokenplace_) Machine(tokenplace_) {}

    //using Address for address;
    //using BytesLib for bytes;
    using Strings for uint256;
    using Array for uint256[];

    mapping(address => mapping(uint256 => mapping(address => uint256))) private _balances;
    mapping(address => string) private _uri;

    function features(address ) public virtual view override returns (uint40) {
        return Token.TypeERC1155 | Token.MT | Token.ERC165;
    }



    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        return balanceOf(msg.sender,account,id);
    }
    function balanceOf(address token,address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[token][id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        return balanceOfBatch(msg.sender,accounts,ids);
    }
    

    function balanceOfBatch(address token,address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(token,accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool _approved)
        public
        virtual
        override(IERC1155,OperatorableClient)
    {
        OperatorableClient.setApprovalForAll(operator,_approved);
        emit ApprovalForAll(_msgSender(), operator, _approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override(IERC1155, OperatorableClient)
        returns (bool)
    {
        return OperatorableClient.isApprovedForAll(owner, operator);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        return safeTransferFrom(msg.sender,from,to,id,amount,data);
    }
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(token,from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        return safeBatchTransferFrom(msg.sender,from,to,ids,amounts,data);
    }
    function safeBatchTransferFrom(
        address token,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(token,from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = Array.munique(id);
        uint256[] memory amounts = Array.munique(amount);

        _beforeTokenTransfer(token,operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[token][id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[token][id][from] = fromBalance - amount;
        }
        _balances[token][id][to] += amount;

        emit TokenTransferSingle(token,operator, from, to, id, amount);

        _afterTokenTransfer(token,operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address token,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(token,operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[token][id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[token][id][from] = fromBalance - amount;
            }
            _balances[token][id][to] += amount;
        }

        emit TokenTransferBatch(token,operator, from, to, ids, amounts);

        _afterTokenTransfer(token,operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(address token,string memory newuri) internal virtual {
        _uri[token] = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address token,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = Array.munique(id);
        uint256[] memory amounts = Array.munique(amount);

        _beforeTokenTransfer(token,operator, address(0), to, ids, amounts, data);

        _balances[token][id][to] += amount;
        emit TokenTransferSingle(token,operator, address(0), to, id, amount);

        _afterTokenTransfer(token,operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address token,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(token,operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[token][ids[i]][to] += amounts[i];
        }

        emit TokenTransferBatch(token,operator, address(0), to, ids, amounts);

        _afterTokenTransfer(token,operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address token,
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = Array.munique(id);
        uint256[] memory amounts = Array.munique(amount);

        _beforeTokenTransfer(token,operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[token][id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[token][id][from] = fromBalance - amount;
        }

        emit TokenTransferSingle(token,operator, from, address(0), id, amount);

        _afterTokenTransfer(token,operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address token,
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(token,operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[token][id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[token][id][from] = fromBalance - amount;
            }
        }

        emit TokenTransferBatch(token,operator, from, address(0), ids, amounts);

        _afterTokenTransfer(token,operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
     /*
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    */
    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address token,
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address token,
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }
/*
    function Array.munique(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
*/



























/*





    function defaultOperators()
        external
        pure
        override(IERC777,IMERC777)
        returns (address[] memory)
    {
        return new address[](0);
    }

    // GHOST
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        address msgsender = Tools.getTailAddress();
        require(
            isOperatorFor(msgsender, account),
            "MERC777: caller is not an operator for holder"
        );
        _burn(msg.sender, msgsender, account, amount, data, operatorData);
    }

    function operatorBurn(
        address token,
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        require(
            isOperatorFor(msg.sender, account),
            "MERC777: caller is not an operator for holder"
        );
        _burn(token, msg.sender, account, amount, data, operatorData);
    }

    // GHOST
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        address msgsender = Tools.getTailAddress();
        require(
            isOperatorFor(msgsender, sender),
            "MERC777: caller is not an operator for holder"
        );
        _send(
            msg.sender,
            msgsender,
            sender,
            recipient,
            amount,
            data,
            operatorData,
            true
        );
    }

    function operatorSend(
        address token,
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        require(
            isOperatorFor(msg.sender, sender),
            "MERC777: caller is not an operator for holder"
        );
        _send(
            token,
            msg.sender,
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

    // GHOST
    function name()
        public
        view
        virtual
        override(IERC20Metadata, IERC777)
        returns (string memory)
    {
        return super.name(msg.sender);
    }

    // GHOST
    function symbol()
        public
        view
        virtual
        override(IERC20Metadata, IERC777)
        returns (string memory)
    {
        return super.symbol(msg.sender);
    }
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

    function decimals(address token) public view virtual returns (uint8) {
        return 18;
    }

    // GHOST
    function granularity() public view virtual override returns (uint256) {
        return granularity(msg.sender);
    }

    function granularity(address token) public view virtual returns (uint256) {
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
        _send(token, msg.sender, msg.sender, recipient, amount, data, "", true);
    }

    // GHOST
    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        address msgsender = Tools.getTailAddress();
        _send(
            msg.sender,
            msgsender,
            msgsender,
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
        _send(token, msg.sender, msg.sender, recipient, amount, "", "", false);
        return true;
    }

    // GHOST
    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        address msgsender = Tools.getTailAddress();
        _send(
            msg.sender,
            msgsender,
            msgsender,
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
        _burn(token, msg.sender, msg.sender, amount, data, "");
    }

    // GHOST
    function burn(uint256 amount, bytes memory data) public virtual override {
        address msgsender = Tools.getTailAddress();
        _burn(msg.sender, msgsender, msgsender, amount, data, "");
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
        _approve(token, msg.sender, spender, value);
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
            Tools.getTailAddress(),
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
        _spendAllowance(token, holder, msg.sender, amount);
        _send(token, msg.sender, holder, recipient, amount, "", "", false);
        return true;
    }

    // GHOST
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        address msgsender = Tools.getTailAddress();
        _spendAllowance(msg.sender, holder, msgsender, amount);
        _send(msg.sender, msgsender, holder, recipient, amount, "", "", false);
        return true;
    }

    function mint(
        address token,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        require(
            TokenPlace(location(kTokenPlace)).creatorOf(token) == msg.sender,
            "MERC777: minter must be creator"
        );
        _mint(token, msg.sender, to, amount, userData, operatorData);
    }

    function mint(
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public virtual {
        address msgsender = Tools.getTailAddress();
        require(
            TokenPlace(location(kTokenPlace)).creatorOf(msg.sender) == msgsender,
            "MERC777: minter must be creator"
        );
        _mint(msg.sender, msgsender, to, amount, userData, operatorData);
    }

    function _mint(
        address token,
        address msgsender,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        _mint(token, msgsender, account, amount, userData, operatorData, true);
    }

    function _mint(
        address token,
        address msgsender,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(
            account != address(0),
            "MERC777: mint to the zero address"
        );

        _beforeTokenTransfer(token, msgsender, address(0), account, amount);

        // Update state variables
        _totalSupply[token] += amount;
        _balances[token][account] += amount;

        _callTokensReceived(
            token,
            msgsender,
            address(0),
            account,
            amount,
            userData,
            operatorData,
            requireReceptionAck
        );
        emit TokenMinted(
            token,
            msgsender,
            account,
            amount,
            userData,
            operatorData
        );
        emit TokenTransfer(token, address(0), account, amount);
    }

    function _send(
        address token,
        address msgsender,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(
            from != address(0),
            "MERC777: transfer from the zero address"
        );
        require(
            to != address(0),
            "MERC777: transfer to the zero address"
        );

        _callTokensToSend(
            token,
            msgsender,
            from,
            to,
            amount,
            userData,
            operatorData
        );

        _move(token, msgsender, from, to, amount, userData, operatorData);

        _callTokensReceived(
            token,
            msgsender,
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
        address msgsender,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        require(
            from != address(0),
            "MERC777: burn from the zero address"
        );

        _callTokensToSend(
            token,
            msgsender,
            from,
            address(0),
            amount,
            data,
            operatorData
        );

        _beforeTokenTransfer(token, msgsender, from, address(0), amount);

        // Update state variables
        uint256 fromBalance = _balances[token][from];
        require(
            fromBalance >= amount,
            "MERC777: burn amount exceeds balance"
        );
        unchecked {
            _balances[token][from] = fromBalance - amount;
        }
        _totalSupply[token] -= amount;

        emit TokenBurned(token, msgsender, from, amount, data, operatorData);
        emit TokenTransfer(token, from, address(0), amount);
    }

    function _move(
        address token,
        address msgsender,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        _beforeTokenTransfer(token, msgsender, from, to, amount);

        uint256 fromBalance = _balances[token][from];
        require(
            fromBalance >= amount,
            "MERC777: transfer amount exceeds balance"
        );
        unchecked {
            _balances[token][from] = fromBalance - amount;
        }
        _balances[token][to] += amount;
        emit TokenSent(
            token,
            msgsender,
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
        require(
            holder != address(0),
            "MERC777: approve from the zero address"
        );
        require(
            spender != address(0),
            "MERC777: approve to the zero address"
        );

        _allowances[token][holder][spender] = value;
        //if (TokenPlace(location(kTokenPlace)).exists(msg.sender)) emit Approval(holder, spender, value);
        emit TokenApproval(token, holder, spender, value);
    }
    */
}
