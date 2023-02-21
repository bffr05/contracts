from brownie import * 

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

def test_ERC721():
    Token = MERC721[-1].get(mainaccount(),"", "")
    if MERC721[-1].exists['address'](Token)==False:
        MERC721[-1].declare("", "",{"from": mainaccount()})
        assert(MERC721[-1].exists['address'](Token)==True)
        MERC721[-1].deploy(Token,{"from": mainaccount()})
        assert(len(network.web3.eth.get_code(Token))!=0)
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

    MERC721[-1].safeMint(Token,mainaccount(), 1, "",{"from": mainaccount()})
    assert(interface.IERC721(Token).ownerOf(1)==mainaccount())

    MERC721[-1].safeMint(Token,mainaccount(), 222, "",{"from": mainaccount()})
    assert(interface.IERC721(Token).ownerOf(222)==mainaccount())

def test_ERC777():
    Token = MERC777[-1].get(mainaccount(),"", "")
    if MERC777[-1].exists(Token) == False:
        MERC777[-1].declare("", "",{"from": mainaccount()})
        assert(MERC777[-1].exists(Token)==True)
        MERC777[-1].deploy(Token,{"from": mainaccount()})
        assert(len(network.web3.eth.get_code(Token))!=0)
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

    Token = MERC777[-1].get(mainaccount(),"", "")
    MERC777[-1].mint(Token,mainaccount(),4*10**18,"","",{"from": mainaccount()})

def test_Container(pm):
    Container.deploy(MContainer[-1],False,{"from": mainaccount()})
    MContainer[-1].set(Container[-1],True,{"from": mainaccount()})

def test_Container_isSelected(pm):
    assert(MContainer[-1].isTrusted(Container[-1]))

##def test_declareFromOwner(pm):
##    MContainer[-1].declareFromOwner(Container[-1],"","",{"from": mainaccount()})

def test_lencontent0(pm):
    assert(len(Container[-1].content['uint,address'](0,"0x0000000000000000000000000000000000000000"))==0)

def test_cur_stake(pm):
    Container[-1].stake(0,"0x0000000000000000000000000000000000000000",1,{"from": mainaccount()})

def test_cur_exists(pm):
    assert(Container[-1].exists(MContainer[-1].toIdAddress(mainaccount())))

def test_cur_exists2(pm):
    assert(Container[-1].exists(0,{"from": mainaccount()}))

def test_cur_ownerOf(pm):
    assert(Container[-1].ownerOf(MContainer[-1].toIdAddress(mainaccount()))==mainaccount())

def test_cur_ownerOf2(pm):
    assert(Container[-1].ownerOf(0,{"from": mainaccount()})==mainaccount())

def test_cur_lencontent1(pm):
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),"0x0000000000000000000000000000000000000000"))==1)

def test_cur_valuecontent1(pm):
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),"0x0000000000000000000000000000000000000000")[0]==1)

def test_cur_lencontent1_0(pm):
    assert(len(Container[-1].content['uint,address'](0,"0x0000000000000000000000000000000000000000",{"from": mainaccount()}))==1)

def test_cur_valuecontent1_0(pm):
    assert(Container[-1].content['uint,address'](0,"0x0000000000000000000000000000000000000000",{"from": mainaccount()})[0]==1)

def test_cur_stake2(pm):
    Container[-1].stake(MContainer[-1].toIdAddress(mainaccount()),"0x0000000000000000000000000000000000000000",1,{"from": mainaccount()})

def test_cur_lencontent2(pm):
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),"0x0000000000000000000000000000000000000000"))==1)

def test_cur_valuecontent2(pm):
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),"0x0000000000000000000000000000000000000000")[0]==2)

def test_cur_unstake(pm):
    Container[-1].unstake(0,"0x0000000000000000000000000000000000000000",1,{"from": mainaccount()})

def test_erc721_lencontent0(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](0,Token))==0)

def test_erc721_stake(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    Container[-1].stake(0,Token,1,{"from": mainaccount()})

def test_erc721_lencontent1(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token))==1)

def test_erc721_valuecontent1(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token)[0]==1)

def test_erc721_lencontent1_0(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](0,Token,{"from": mainaccount()}))==1)

def test_erc721_valuecontent1_0(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](0,Token,{"from": mainaccount()})[0]==1)

def test_erc721_stake2(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    Container[-1].stake(MContainer[-1].toIdAddress(mainaccount()),Token,222,{"from": mainaccount()})

def test_erc721_lencontent2(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token))==2)

def test_erc721_valuecontent2(pm):
    Token = MERC721[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token)[1]==222)

def test_erc777_lencontent0(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](0,Token))==0)

def test_erc777_stake(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    Container[-1].stake(0,Token,1,{"from": mainaccount()})

def test_erc777_lencontent1(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token))==1)

def test_erc777_valuecontent1(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token)[0]==1)

def test_erc777_lencontent1_0(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](0,Token,{"from": mainaccount()}))==1)

def test_erc777_valuecontent1_0(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](0,Token,{"from": mainaccount()})[0]==1)

def test_erc777_stake2(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    Container[-1].stake(MContainer[-1].toIdAddress(mainaccount()),Token,222,{"from": mainaccount()})

def test_erc777_lencontent2(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token))==1)

def test_erc777_valuecontent2(pm):
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(Container[-1].content['uint,address'](MContainer[-1].toIdAddress(mainaccount()),Token)[0]==223)
