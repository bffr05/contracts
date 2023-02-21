// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../../../interfaces/base/IAble.sol";
import "../../../interfaces/base/IERC721Extended.sol";
import "../../../interfaces/base/IContractWithId.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../../base/access/Ownable.sol";
import "../../base/utils/Array.sol";
import "../../base/utils/Error.sol";
import "../machine/Machine.sol";
import "./IMERC721.sol";

abstract contract aMERC721 is
    Machine,
    IERC721,
    IMERC721,
    //IERC721Metadata,
    IERC721Extended,
    IContractWithId
{
    function supportsInterface(
        bytes4 interfaceId_
    ) public view virtual override(Machine, IERC165) returns (bool) {
        if (TokenPlace(location(kTokenPlace)).exists(msg.sender))
            if (
                interfaceId_ == type(IERC721).interfaceId ||
                //interfaceId_ == type(IERC721Metadata).interfaceId ||
                interfaceId_ == type(IERC721Extended).interfaceId ||
                interfaceId_ == type(IContractWithId).interfaceId
            ) return true;
        return
            super.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IMERC721).interfaceId;
    }

    //constructor(TokenPlace tokenplace_) Machine(tokenplace_) {}

    //using Address for address;
    //using BytesLib for bytes;
    using Strings for uint256;
    using Array for uint256[];

    mapping(address => uint256[]) internal _ids;
    mapping(address => mapping(uint256 => address)) internal _owners;
    mapping(address => mapping(uint256 => address)) internal _approvals;

    //TODO
    mapping(address => mapping(uint256 => address)) internal _blobs;

    function features(address) public view virtual override returns (uint40) {
        return
            Token.TypeERC721 | Token.NFT | Token.ContractWithId | Token.ERC165;
    }

    function ownerOf() public view virtual override(Ownable) returns (address) {
        TokenPlace tokenplace = TokenPlace(location(kTokenPlace));

        if (tokenplace.exists(msg.sender))
            return tokenplace.creatorOf(msg.sender);
        return Ownable.ownerOf();
    }

    function name() public view returns (string memory) {
        return super.name(msg.sender);
    }

    function symbol() public view returns (string memory) {
        return super.symbol(msg.sender);
    }

    /*function tokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(msg.sender, tokenId);
    }*/

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balanceOf(msg.sender, owner);
    }

    function ownerOf(
        uint256 tokenId
    )
        public
        view
        virtual
        override(IContractWithId, IERC721)
        returns (address owner)
    {
        return ownerOf(msg.sender, tokenId);
    }

    function exists(
        uint256 tokenId
    )
        public
        view
        virtual
        override(IContractWithId, IERC721Extended)
        returns (bool)
    {
        return exists(msg.sender, tokenId);
    }

    function listOf(
        address owner
    ) public view virtual returns (uint256[] memory) {
        return listOf(msg.sender, owner);
    }

    function list() public view virtual returns (uint256[] memory) {
        return list(msg.sender);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public {
        _safeTransferFrom(msg.sender, from, to, tokenId, data);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public {
        _safeTransferFrom(token, from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        _safeTransferFrom(msg.sender, from, to, tokenId, "");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) public {
        _safeTransferFrom(token, from, to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(IContractWithId, IERC721) {
        _transferFrom(msg.sender, from, to, tokenId);
    }

    function transfer(
        address to,
        uint256 tokenId
    ) public virtual override(IContractWithId) {
        _transferFrom(msg.sender, _msgSender(), to, tokenId);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) public {
        _transferFrom(token, from, to, tokenId);
    }

    function approve(address token, address to, uint256 tokenId) public {
        address owner = aMERC721.ownerOf(token, tokenId);
        if (to == owner) revert Invalid();
        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender()))
            revert Unauthorized(Unauthorized_Reason.onlyOperator);
        _approve(token, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public {
        approve(msg.sender, to, tokenId);
    }

    function getApproved(
        uint256 tokenId
    ) public view returns (address operator) {
        return getApproved(msg.sender, tokenId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(
        address token,
        address owner
    ) public view virtual returns (uint256 out) {
        if (owner == address(0)) revert ZeroAddress();

        uint256 len = _ids[token].length;
        for (uint256 i; i < len; i++)
            if (_owners[token][_ids[token][i]] == owner) out++;
    }

    function totalSupply(address token) public view virtual returns (uint256) {
        return _ids[token].length;
    }

    function list(
        address token
    ) public view virtual returns (uint256[] memory) {
        return _ids[token];
    }

    function listOf(
        address token,
        address owner
    ) public view virtual returns (uint256[] memory out) {
        uint256 len = _ids[token].length;
        out = new uint256[](len);
        uint256 outlen = 0;
        for (uint256 i; i < len; i++)
            if (_owners[token][_ids[token][i]] == owner)
                out[outlen++] = _ids[token][i];

        assembly {
            mstore(out, outlen)
        }
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(
        address token,
        uint256 tokenId
    ) public view virtual returns (address) {
        address owner = _owners[token][tokenId];
        if (owner == address(0))
            revert Unsupported(Unsupported_Reason.NonExistent);
        return owner;
    }

    function exists(
        address token,
        uint256 tokenId
    ) public view virtual returns (bool) {
        return _exists(token, tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    /*function name(address token)
        public
        view
        virtual
        override( Machine)
        returns (string memory)
    {
        return TokenPlace(location(kTokenPlace)).name(token);
    }*/

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    /*function symbol(address token)
        public
        view
        virtual
        override( Machine)
        returns (string memory)
    {
        return TokenPlace(location(kTokenPlace)).symbol(token);
    }*/

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    /*function tokenURI(
        address token,
        uint256 tokenId
    ) public view virtual returns (string memory) {
        if (!_exists(token, tokenId))
            revert Unsupported(Unsupported_Reason.NonExistent);

        string memory baseURI = _baseURI(token);
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }*/

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    /*function _baseURI(address) internal view virtual returns (string memory) {
        return "";
    }*/

    /**
     * @dev See {IERC721-approve}.
     */
    /*function _approve(
        address token,
        address to,
        uint256 tokenId
    ) internal virtual {
        address owner = aMERC721.ownerOf(token, tokenId);
        require(to != owner, "aMERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "aMERC721: approve caller is not owner nor approved for all"
        );
        _approve(token, to, tokenId);
    }*/

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(
        address token,
        uint256 tokenId
    ) public view virtual returns (address) {
        if (!_exists(token, tokenId))
            revert Unsupported(Unsupported_Reason.NonExistent);

        return _approvals[token][tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(
        address operator,
        bool _approved
    ) public virtual override(IERC721, OperatorableClient) {
        OperatorableClient.setApprovalForAll(operator, _approved);
        emit ApprovalForAll(_msgSender(), operator, _approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override(IERC721, OperatorableClient) returns (bool) {
        return OperatorableClient.isApprovedForAll(owner, operator);
        //return isOperator(owner, operator);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function _transferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        //solhint-disable-next-line max-line-length
        if (!_isApprovedOrOwner(token, _msgSender(), tokenId))
            revert Unauthorized(Unauthorized_Reason.onlyApproved);

        _transfer(token, from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    /*function _safeTransferFrom(
        address token,
        address msgsender,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        _safeTransferFrom(token, msgsender, from, to, tokenId, "");
    }*/

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        if (!_isApprovedOrOwner(token, _msgSender(), tokenId))
            revert Unauthorized(Unauthorized_Reason.onlyApproved);
        _safeTransfer(token, from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address token,
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(token, from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, _data))
            revert Unauthorized(Unauthorized_Reason.Unkwown);
    }

    /**
     * @dev Returns whether `tokenId` machine.exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(
        address token,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return _owners[token][tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(
        address token,
        address spender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        if (!_exists(token, tokenId))
            revert Unsupported(Unsupported_Reason.NonExistent);

        address owner = aMERC721.ownerOf(token, tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(token, tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address token,
        address to,
        uint256 tokenId
    ) internal virtual {
        _safeMint(token, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address token,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(token, to, tokenId);
        if (!_checkOnERC721Received(address(0), to, tokenId, _data))
            revert Unsupported(Unsupported_Reason.Unkwown);
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(
        address token,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (tokenId == 0) revert ZeroAddress();
        if (to == address(0)) revert ZeroAddress();
        if (_exists(token, tokenId))
            revert Unsupported(Unsupported_Reason.Existent);

        _beforeTokenTransfer(token, address(0), to, tokenId);
        _ids[token].insert(tokenId);
        //_balances[to] += 1;
        _owners[token][tokenId] = to;

        emit TokenTransfer(token, address(0), to, tokenId);

        _afterTokenTransfer(token, address(0), to, tokenId);
    }

    function burn(address token, uint256 tokenId) public virtual {
        if (ownerOf(token, tokenId) != _msgSender())
            revert Unauthorized(Unauthorized_Reason.onlyOwner);
        _burn(token, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        if (ownerOf(msg.sender, tokenId) != _msgSender())
            revert Unauthorized(Unauthorized_Reason.onlyOwner);
        _burn(msg.sender, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(address token, uint256 tokenId) internal virtual {
        address owner = aMERC721.ownerOf(token, tokenId);

        _beforeTokenTransfer(token, owner, address(0), tokenId);

        // Clear approvals
        _approve(token, address(0), tokenId);
        assert(_ids[token].remove(tokenId));
        //_balances[owner] -= 1;
        delete _owners[token][tokenId];

        emit TokenTransfer(token, owner, address(0), tokenId);

        _afterTokenTransfer(token, owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (ownerOf(token, tokenId) != from)
            revert Unauthorized(Unauthorized_Reason.onlyOwner);

        if (to == address(0)) revert ZeroAddress();

        _beforeTokenTransfer(token, from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(token, address(0), tokenId);

        //_balances[from] -= 1;
        //_balances[to] += 1;
        _owners[token][tokenId] = to;

        emit TokenTransfer(token, from, to, tokenId);

        _afterTokenTransfer(token, from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address token,
        address to,
        uint256 tokenId
    ) internal virtual {
        _approvals[token][tokenId] = to;
        //if (TokenPlace(location(kTokenPlace)).exists(msg.sender))
        //    emit Approval(aMERC721.ownerOf(token, tokenId), to, tokenId);

        emit TokenApproval(
            token,
            aMERC721.ownerOf(token, tokenId),
            to,
            tokenId
        );
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length != 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert Unsupported(Unsupported_Reason.Unkwown);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address, //token,
        address, //from,
        address, //to,
        uint256 //tokenId
    ) internal virtual {
        if (paused()) revert Paused();
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
