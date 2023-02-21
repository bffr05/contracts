// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../../interfaces/base/IAble.sol";
import "../../base/access/Ownable.sol";
import "../../base/utils/Array.sol";
import "../../base/token/Token.sol";
import "../../base/access/Operatorable.sol"; 
import "./ITokenPlace.sol";
import "./TokenPlaceStorage.sol";

bytes32 constant kTokenPlace = keccak256("TokenPlace");


contract TokenPlace is TokenPlaceStorage,IERC165,OperatorableClient, ITokenPlace,IRTokenPlace {

    using Array for address[];
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //          supportsInterface
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(OperatorableClient, IERC165)
        returns (bool)
    {
        return
            OperatorableClient.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IForwarder_Deployer).interfaceId ||
            interfaceId_ == type(ITokenPlace).interfaceId ||
            interfaceId_ == type(IRTokenPlace).interfaceId;
    }

    constructor() {}

    function machines() public view returns (address[] memory) {
        return _machines;
    }

    function updateCoin( string memory symbol_, string memory name_) external onlyOwner {
        _symbol[address(0)]=symbol_;
        _name[address(0)]=name_;
    }


    /*function declareEquiv( address token_, address remotetoken_, uint56 remotechainId_, address machine_, address creator_, uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) external  { 
        require(_info[token_].machine == address(0), "TokenM token exist");
        _creatorOf[token_] = creator_;
        _info[token_].machine = machine_;
        _name[token_] = remotename_;
        _symbol[token_] = remotesymbol_;
        _equiv[token_] = TMEquiv({token:remotetoken_ , chainId:remotechainId_ , features: remotefeatures_ });
        emit Tokened(token_);
    }*/

    function declare( address token_, address machine_, address creator_, string memory symbol_, string memory name_) external  { 
        require(_info[token_].addr == address(0), "TokenM token exist");
        _creatorOf[token_] = creator_;
        _info[token_].addr = machine_;
        _name[token_] = name_;
        _symbol[token_] = symbol_;

        _tokens.insert(token_);
        _machines.insert(machine_);

        emit Tokened(token_);
    }
    function update( address token_, string memory symbol_, string memory name_) external  { 
        require(creatorOf(token_) == _msgSender(),"MERC721: minter must be creator");
        _name[token_] = name_;
        _symbol[token_] = symbol_;
    }


    function roFeatures(address token_) public view returns (uint40 features_) {
        features_ = _info[token_].features;
        if (features_==0 && machine(token_) != address(0))
            return ITokenMachine(machine(token_)).features(token_);
        if (machine(token_) == address(0) || (_info[token_].features==0 && token_.code.length > 0))
            features_ = Token.features(token_,false);
    }
    function features(address token_) public returns (uint40 features_) {
        if (_info[token_].features==0 && machine(token_) != address(0))
            return ITokenMachine(machine(token_)).features(token_);
        if (machine(token_) == address(0) || (_info[token_].features==0 && token_.code.length > 0))
        {
            _tokens.insert(token_);
            _info[token_].features = Token.features(token_,false);
        }
        features_ = _info[token_].features;
        
    }

    function machine(address token_) public view returns (address) {
        return _info[token_].addr;
    }
    function creatorOf(address token_) public view returns (address) {
        return _creatorOf[token_];
    }
    function name(address token_) public view returns (string memory out_) {
        if (machine(token_) == address(0) && token_.code.length > 0) {
            uint40 vfeatures = _info[token_].features;
            if (vfeatures==0)
                vfeatures = Token.features(token_,false);
            if (vfeatures & Token.TypeERC20 != 0)
                try IERC20Metadata(token_).name() {
                    return IERC20Metadata(token_).name(); } catch {}
            else if (vfeatures & Token.TypeERC777 != 0)
                try IERC777(token_).name() {
                    return IERC777(token_).name(); } catch {}
            else if (vfeatures & Token.TypeERC721 != 0)
                try IERC721Metadata(token_).name() {
                    return IERC721Metadata(token_).name(); } catch {}
        }
        return _name[token_];
    }
    function symbol(address token_) public view returns (string memory ) {
        if (machine(token_) == address(0) && token_.code.length > 0) {
            uint40 vfeatures = _info[token_].features;
            if (vfeatures==0)
                vfeatures = Token.features(token_,false);
            if (vfeatures & Token.TypeERC20 != 0)
                try IERC20Metadata(token_).symbol() {
                    return IERC20Metadata(token_).symbol(); } catch {}
            else if (vfeatures & Token.TypeERC777 != 0)
                try IERC777(token_).symbol() {
                    return IERC777(token_).symbol(); } catch {}
            else if (vfeatures & Token.TypeERC721 != 0)
                try IERC721Metadata(token_).symbol() {
                    return IERC721Metadata(token_).symbol(); } catch {}
        }
        return _symbol[token_];
    }
    function exists(address token_) public view returns (bool) {
        return _info[token_].features != 0 || _info[token_].addr != address(0);
        //return roFeatures(token_) != 0;
    }
    /*
    function image(address token_, uint256 tokenId_) public view returns (string memory) {
        if (token_ == address(0)) return _imageeth;
        string memory _image = _images[
            BytesAndKeccakLib.pureAddressUInt256(token_, tokenId_)
        ];
        if (
            keccak256(abi.encodePacked((_image))) !=
            keccak256(abi.encodePacked(("")))
        ) return _image;
        if (tokenId_ != 0) {
            _image = _images[BytesAndKeccakLib.pureAddressUInt256(token_, 0)];
            if (
                keccak256(abi.encodePacked((_image))) !=
                keccak256(abi.encodePacked(("")))
            ) return _image;
        }
        return _defaultimage;
    }
    */
}
