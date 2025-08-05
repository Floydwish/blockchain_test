// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BaseERC721 {
    using Strings for uint256;
    using Address for address;

    // Token name
    string private _name;
    
    // Token symbol
    string private _symbol;

    // Token baseURI
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals ,即 A 是否授权 B 管理所有 NFT
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Initializes the contract by setting a `name`, a `symbol` and a `baseURI` to the token collection.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        /**code*/
        _name = name_;          // NFT 系列的名称
        _symbol = symbol_;      // NFT 系列的简称
        _baseURI = baseURI_;    // NFT 的图片地址
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f;   // ERC165 Interface ID for ERC721Metadata
    }
    
    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        /**code*/
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        /**code*/
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        
        require(_exists(tokenId),/**code*/
            "ERC721Metadata: URI query for nonexistent token"
        );

        // should return baseURI
        /**code*/
        //return string(abi.encodePacked(_baseURI, tokenId.toString()));
        return string.concat(_baseURI, tokenId.toString()); //拼接 地址 和 tokenId
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` must not exist.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, uint256 tokenId) public {
        require(to != address(0)/**code*/ , "ERC721: mint to the zero address");
        require(/**code*/_exists(tokenId) != true, "ERC721: token already minted");

        /**code
        将NFT 从无主状态 转为 to 拥有*/
        _transfer(address(0), to, tokenId);

        // 增加 to 地址的 NFT 数量
        _balances[to]++;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view returns (uint256) {
        /**code*/
        // 返回 owner 地址拥有的 NFT 数量
        return _balances[owner];
    }
    

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        /**code*/
        return _owners[tokenId];
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);

        // to 不能是当前 NFT 的所有者
        require(to != _owners[tokenId]/**code*/, "ERC721: approval to current owner");

        // 必须满足 msg.sender 是 owner , 或者 owner 授权 msg.sender 管理所有 NFT
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender)
            /**code*/,
            "ERC721: approve caller is not owner nor approved for all"
        );

       _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId)
            /**code*/,
            "ERC721: approved query for nonexistent token"
        );

        /**code 返回 这个 NFT 被单独授权给了谁 */
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        address sender = msg.sender;
        require(sender != operator/**code*/, "ERC721: approve to caller");
        
        /**code*/
        // sender 授权 operator 管理所有的 NFT
        _operatorApprovals[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        /**code*/
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
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
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        /**code*/
        //如果 NFT 存在，那么可以找到所有者地址，否则为0地址（不存在）
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(_exists(tokenId)
            /**code*/,
            "ERC721: operator query for nonexistent token"
        );

        /**code*/
        //NFT 存在
        address owner = ownerOf(tokenId); //找到该 NFT 的所有者地址

        return (spender == owner ||                 // spender 是 owner
                spender == getApproved(tokenId) ||  // spender 被 owner 单独授权
                isApprovedForAll(owner, spender));  // spender 被 owner 完全授权
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
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(from == ownerOf(tokenId)
           /**code*/,
            "ERC721: transfer from incorrect owner"
        );

        require(address(0) != to /**code*/, "ERC721: transfer to the zero address");

        /**code*/
        //清除该 NFT 的所有授权
        _approve(address(0), tokenId);

        //减少 from 的数量
        _balances[from]--;

        //增加 to 的数量
        _balances[to]--;

        // 更新 NFT 所有权
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        /**code*/
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

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
        // 合约地址：to.code.length > 0, 也就是合约的字节码
        // 外部地址：to.code.length == 0, 没有数据
        // 这里isContract 调用失败，检查 5.4.0 版本 Address.sol 中没有这个接口
        if (to.code.length > 0/*to.isContract()*/) {
            try
                /*
                1. 当接收NFT 的地址是合约时，必须确保 接收方合约可以处理 NFT;
                2. to 地址是合约，实现了IERC721Receiver 接口；
                3. 调用 接口中的 onERC721Received函数（任何要安全接收 NFT的合约都必须实现）；
                4. 成功后返回值放在 retval 中
                5. 如果成功接收，返回特定值
                */
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )//try...returns (bytes4 retval)如果调用成功，返回值存储在retval中
            returns (bytes4 retval) {
                // 成功：返回了4字节的函数选择器，IERC721Receiver.onERC721Received.selector;
                // 失败原因1：返回值不正确
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {   // 失败原因2：该合约没有实现 onERC721Received 函数
                    revert(                 // 回退
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {              //失败原因3：内部错误
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {//普通地址(非合约)
            return true;
        }
    }
}

contract BaseERC721Receiver is IERC721Receiver {
    constructor() {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
/*
编写 ERC721 NFT 合约
  
介绍
ERC721 标准代表了非同质化代币（NFT），它为独一无二的资产提供链上表示。
从数字艺术品到虚拟产权，NFT的概念正迅速被世界认可。了解并能够实现 ERC721 标准对区块链开发者至关重要。
通过这个挑战，你不仅可以熟悉 Solidity 编程，而且可以了解 ERC721 合约的工作原理。

目标
你的任务是创建一个遵循 ERC721 标准的智能合约，该合约能够用于在以太坊区块链上铸造与交易 NFT。
*/