from brownie import (
    accounts,
    network,
    config,
    TokenPlace,
    MERC721,
    interface
)
import os
import sys

sys.path.append('./scripts')
from deploy import *

from dotenv import load_dotenv ##pipx install python-dotenv 
load_dotenv()


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

def test_t_exists():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].exists['address'](Token)==False)

def test_t_declare():
    Token = MERC721[-1].get(mainaccount(),"", "")
    tx = MERC721[-1].declare("", "",{"from": mainaccount()})

def test_t_exists2():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].exists['address'](Token)==True)

def test_t_feature():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].features(Token)!=0)

def test_t_codelen():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(network.web3.eth.get_code(Token))==0)

def test_t_deploy():
    Token = MERC721[-1].get(mainaccount(),"", "")
    MERC721[-1].deploy(Token,{"from": mainaccount()})

def test_t_feature2():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].features(Token)!=0)

def test_t_codelen2():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(network.web3.eth.get_code(Token))!=0)

def test_t_owner():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

def test_t_minting():
    Token = MERC721[-1].get(mainaccount(),"", "")
    MERC721[-1].safeMint(Token,mainaccount(), 1, "",{"from": mainaccount()})

def test_ownerOf():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].ownerOf(Token,1)==mainaccount())
    assert(interface.IERC721(Token).ownerOf(1)==mainaccount())

def test_tm_exists():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(MERC721[-1].exists(Token,1))

def test_t_exists():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721Extended(Token).exists(1))

def test_t_list():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(interface.IERC721Extended(Token).list())==1)
    assert(interface.IERC721Extended(Token).list()[0]==1)

def test_tm_list():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(MERC721[-1].list(Token))==1)
    assert(MERC721[-1].list(Token)[0]==1)

def test_t_list():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(interface.IERC721Extended(Token).list())==1)
    assert(interface.IERC721Extended(Token).list()[0]==1)

def test_tm_listOf():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(MERC721[-1].listOf(Token,mainaccount()))==1)
    assert(MERC721[-1].listOf(Token,mainaccount())[0]==1)

def test_t_listOf():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(interface.IERC721Extended(Token).listOf(mainaccount()))==1)
    assert(interface.IERC721Extended(Token).listOf(mainaccount())[0]==1)

def test_t_balanceOf():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721(Token).balanceOf(mainaccount())==1)

def test_t_ownerOf():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721(Token).ownerOf(1)==mainaccount())

def test_t_name():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721Metadata(Token).name()=="")

def test_t_symbol():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721Metadata(Token).symbol()=="")

def test_t_tokenURI():
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(interface.IERC721Metadata(Token).tokenURI(1)=="")

def test_t_approve():
    Token = MERC721[-1].get(mainaccount(),"", "")
    interface.IERC721(Token).approve(extraaccount(),1,{"from": mainaccount()})
    assert(interface.IERC721(Token).getApproved(1)==extraaccount())

def test_tp_setApprovalForAll():
    TokenPlace[-1].setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    TokenPlace[-1].setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))

def test_tp_setApprovalForAll():
    MERC721[-1].setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(MERC721[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    MERC721[-1].setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not MERC721[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))


def test_t_setApprovalForAll():
    Token = MERC721[-1].get(mainaccount(),"", "")
    interface.IERC721(Token).setApprovalForAll(extraaccount(),True,{"from": mainaccount()})
    assert(MERC721[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(interface.IERC721(Token).isApprovedForAll(mainaccount(),extraaccount()))
    interface.IERC721(Token).setApprovalForAll(extraaccount(),False,{"from": mainaccount()})
    assert(not MERC721[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not TokenPlace[-1].isApprovedForAll(mainaccount(),extraaccount()))
    assert(not interface.IERC721(Token).isApprovedForAll(mainaccount(),extraaccount()))



def test_t_safeTransferFrom():
    Token = MERC721[-1].get(mainaccount(),"", "")
    interface.IERC721(Token).safeTransferFrom(mainaccount(),extraaccount(),1,"",{"from": mainaccount()})
    assert(interface.IERC721(Token).ownerOf(1)==extraaccount())


