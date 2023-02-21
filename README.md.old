All bunch of usefull solidity libraries or contracts used across projects
Fell free to use them and let me know about hello@mcdu.com

## utils
    * Array.sol is a very useful internal library (no need to deploy it) to handle arrays from various types, used a lot in my projects
    * Tools.sol are some tools related to contract address with asm 
    * Referal.sol are base abstract contract specifying a contract refer to a another contract
    * Forwarder.sol is a empty contract that forward all calls to a refered contract adding the msg.sender to end of call params, the is the base for all virtual tokens

## token
    * iERC721Extended.sol is my own Interface expension of IERC721 specifying the exists(id) and listing all ids of NFT globally or per user
    * ERC721.sol is the expension of OZ ERC721 that complies with iERC721Extended
    * IBEP.sol is the Binance Extension to ERC20 introducing getOwner
    * Token is a library allwing to analyse a contract to see if it fits any Token standard and some features and allowing generic transferTo/transferFrom 

## access
    * Ownable.sol personal improvement to OZ Ownable ith a iOwnable and RiOwnable interface
    * Trustable.sol
        A attempt to define the trust between a contract and interactors
        A trustee can be a account address, a contract address or hash
        The trust can be delegated to a referal, allowinf to manage the trust globally to a ecosystem
    * Operatorable.sol
        Operatorable is a derivation of Trustable with a compliance to ERC721 and ERC777
    * Blacklist.sol is the opposite of Trustable.sol, allowinf to ban address or contracts
    * Access.sol is the base class for all the access management, it provides trustable, operatorable, blacklist with referal features