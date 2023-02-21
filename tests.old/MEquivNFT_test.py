from brownie import (
    accounts,
    network,
    config,
    TokenPlace,
    MEquivNFT,
    interface
)
import os
import sys

sys.path.append('./scripts')
from deploy import *

from dotenv import load_dotenv ##pipx install python-dotenv 
load_dotenv()


testChainId = 7777
testToken = "0x0000000000000000000000000000000000000123"
testFeatures = 0x0000000008 | 0x0000000200
testName = "Artiste"
testSymbol = "ART"

def mainaccount():
    if network.show_active() in {"development", "ganache"}:
        return accounts[0]
    else:
        return accounts.add(os.getenv("MAIN_PKEY"))

def extraaccount():
    if network.show_active() in {"development", "ganache"}:
        return accounts[1]
    else:
        return accounts.add(os.getenv("EXTRA_PKEY"))

def test_deploy():
    main()

def test_tm_exists():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].exists['address'](Token)==False)


def test_tm_declare():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    tx = MEquivNFT[-1].declare(testChainId, testToken,testFeatures,testSymbol,testName,{"from": mainaccount()})

def test_tm_exists2():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].exists['address'](Token)==True)

def test_tm_feature():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].features(Token)!=0)

def test_tm_codelen():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(network.web3.eth.get_code(Token))==0)

def test_tm_equiv():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].equiv(Token)==[testChainId,testToken,testFeatures])


def test_t_deploy():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    MEquivNFT[-1].deploy(Token,{"from": mainaccount()})

def test_t_feature2():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].features(Token)!=0)

def test_t_codelen2():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(network.web3.eth.get_code(Token))!=0)

def test_t_owner():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

def test_t_minting():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    MEquivNFT[-1].safeMint(Token,mainaccount(), 1, "",{"from": mainaccount()})

def test_ownerOf():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].ownerOf(Token,1)==mainaccount())
    assert(interface.IERC721(Token).ownerOf(1)==mainaccount())

def test_tm_exists():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivNFT[-1].exists(Token,1))

def test_t_exists():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721Extended(Token).exists(1))

def test_t_list():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(interface.IERC721Extended(Token).list())==1)
    assert(interface.IERC721Extended(Token).list()[0]==1)

def test_tm_list():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(MEquivNFT[-1].list(Token))==1)
    assert(MEquivNFT[-1].list(Token)[0]==1)

def test_t_list():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(interface.IERC721Extended(Token).list())==1)
    assert(interface.IERC721Extended(Token).list()[0]==1)

def test_tm_listOf():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(MEquivNFT[-1].listOf(Token,mainaccount()))==1)
    assert(MEquivNFT[-1].listOf(Token,mainaccount())[0]==1)

def test_t_listOf():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(interface.IERC721Extended(Token).listOf(mainaccount()))==1)
    assert(interface.IERC721Extended(Token).listOf(mainaccount())[0]==1)

def test_t_balanceOf():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721(Token).balanceOf(mainaccount())==1)

def test_t_ownerOf():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721(Token).ownerOf(1)==mainaccount())

def test_t_name():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721Metadata(Token).name()==testName)

def test_t_symbol():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721Metadata(Token).symbol()==testSymbol)

def test_t_tokenURI():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC721Metadata(Token).tokenURI(1)=="")

def test_t_approve():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    interface.IERC721(Token).approve(extraaccount(),1,{"from": mainaccount()})
    assert(interface.IERC721(Token).getApproved(1)==extraaccount())

def test_tp_setApprovalForAll():
    TokenPlace[-1].setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    TokenPlace[-1].setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))

def test_tp_setApprovalForAll():
    MEquivNFT[-1].setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(MEquivNFT[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    MEquivNFT[-1].setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not MEquivNFT[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))


def test_t_setApprovalForAll():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    interface.IERC721(Token).setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(MEquivNFT[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(interface.IERC721(Token).isApprovedForAll(mainaccount(),extraaccount()))
    interface.IERC721(Token).setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not MEquivNFT[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not interface.IERC721(Token).isApprovedForAll(mainaccount(),extraaccount()))


def test_t_safeTransferFrom():
    Token = MEquivNFT[-1].get(mainaccount(),testChainId, testToken)
    interface.IERC721(Token).safeTransferFrom(mainaccount(),extraaccount(),1,"",{"from": mainaccount()})
    assert(interface.IERC721(Token).ownerOf(1)==extraaccount())


