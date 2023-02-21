// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../machine/Machine.sol";
import "./IMEquiv.sol";
import "../../base/utils/Error.sol";



abstract contract MEquiv is LocationBase,IEquiv,IMEquiv {


    mapping(address => TokenPlaceStorage.TMInfo) public equivs;    
 

    function equiv(address token_) public virtual view returns (uint56 remotechainId_,address remotetoken_, uint40 features) {
        return (equivs[token_].chainId,equivs[token_].addr,equivs[token_].features);
    }
    function equiv() public virtual view returns (uint56 remotechainId_,address remotetoken_, uint40 features) {
        return equiv(msg.sender);
    }

    function getSalt(address creator_,uint56 remotechainId_,address remotetoken_) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(creator_,address(this),remotechainId_,remotetoken_));
    }

    function get(address creator_,uint56 remotechainId_,address remotetoken_) public view returns (address) {
        Forwarder_Deployer forwarder_deployer = Forwarder_Deployer(location(kForwarder_Deployer));
        return forwarder_deployer.predict(address(this),getSalt(creator_,remotechainId_,remotetoken_));
    }
    function get(uint56 remotechainId_,address remotetoken_) external view returns (address) {
        return get(msg.sender,remotechainId_,remotetoken_);
    }

    function create(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) public returns (address out_) {
        out_ = declare(remotechainId_, remotetoken_, remotefeatures_,   remotesymbol_,   remotename_);
        deploy(out_);
    }

    function declare(uint56 remotechainId_,address remotetoken_) public virtual returns (address) {
        return declare(remotechainId_,remotetoken_,0,"","");
    }
    function declare(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) public virtual returns (address) {
        TokenPlace tokenplace = TokenPlace(location(kTokenPlace));
        address addr = get(msg.sender,remotechainId_,remotetoken_);
        if (tokenplace.machine(addr) != address(this)) {
            tokenplace.declare(addr,address(this),msg.sender,remotesymbol_,remotename_);
            equivs[addr] = TokenPlaceStorage.TMInfo({addr:remotetoken_ , chainId:remotechainId_ , features: remotefeatures_ });
        }
        return addr;
    }
    function deploy(address token_) public  {
        Forwarder_Deployer forwarder_deployer = Forwarder_Deployer(location(kForwarder_Deployer));
        TokenPlace tokenplace = TokenPlace(location(kTokenPlace));

        if (token_.code.length != 0) revert Unsupported(Unsupported_Reason.Existent);
        (uint56 remotechainId,address remotetoken,) = equiv(token_);
        if (token_!=forwarder_deployer.deploy(address(this),getSalt(tokenplace.creatorOf(token_),remotechainId,remotetoken)))
            revert Assert();         
    }

}
