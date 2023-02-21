from brownie import (
    accounts,
    network,
    config,
    TokenPlace,
    MERC777,
    interface
)
import os
import sys

sys.path.append('./scripts')
from deploy import main

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

def test_tm_exists():
    Token = MERC777[-1].get(mainaccount(),"", "",{"from": mainaccount()})
    assert(MERC777[-1].exists(Token)==False)

def test_tm_declare():
    Token = MERC777[-1].get(mainaccount(),"", "",{"from": mainaccount()})
    MERC777[-1].declare("", "",{"from": mainaccount()})

def test_tm_exists2():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(MERC777[-1].exists(Token)==True)

def test_tm_features():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(MERC777[-1].features(Token)!=0)

def test_codelen():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(network.web3.eth.get_code(Token))==0)

def test_tm_deploy():
    Token = MERC777[-1].get(mainaccount(),"", "")
    MERC777[-1].deploy(Token,{"from": mainaccount()})

def test_tm_exists3():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(MERC777[-1].exists(Token)==True)

def test_tm_features2():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(MERC777[-1].features(Token)!=0)

def test_codelen2():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(len(network.web3.eth.get_code(Token))!=0)

def test_t_owner():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

def test_tm_mint():
    Token = MERC777[-1].get(mainaccount(),"", "")
    MERC777[-1].mint(Token,mainaccount(),4*10**18,"","",{"from": mainaccount()})
    assert(MERC777[-1].totalSupply(Token)==4*10**18)

def test_t_name():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20Metadata(Token).name()=="")

def test_t_symbol():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20Metadata(Token).symbol()=="")

def test_t_decimals():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20Metadata(Token).decimals()==18)

def test_t_totalSupply():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20(Token).totalSupply()==4*10**18)

def test_t_balanceOf():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20(Token).balanceOf(mainaccount())==4*10**18)

def test_t_approve():
    Token = MERC777[-1].get(mainaccount(),"", "")
    interface.IERC20(Token).approve(extraaccount(),4*10**18,{"from": mainaccount()})
    assert(interface.IERC20(Token).allowance(mainaccount(),extraaccount())==4*10**18)

def test_t_authorizeOperator():
    Token = MERC777[-1].get(mainaccount(),"", "")
    ##assert(Access[-1].isTrusted(MERC777[-1]))
    assert(not interface.IERC777(Token).isOperatorFor(mainaccount(),extraaccount()))
    interface.IERC777(Token).authorizeOperator(extraaccount(),{"from": mainaccount()})

    assert(interface.IERC777(Token).isOperatorFor(mainaccount(),extraaccount()))

def test_t_revokeOperator():
    Token = MERC777[-1].get(mainaccount(),"", "")
    TokenPlace[-1].revokeOperator(extraaccount(),{"from": mainaccount()})
    assert(not TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount()))

def test_t_authorizeOperator2():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(not TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount()))
    TokenPlace[-1].authorizeOperator(extraaccount(),{"from": mainaccount()})
    assert(TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount())==False)

def test_t_revokeOperator():
    Token = MERC777[-1].get(mainaccount(),"", "")
    ##assert(Access[-1].isTrusted(MERC777[-1]))
    MERC777[-1].revokeOperator(extraaccount(),{"from": mainaccount()})
    assert(not MERC777[-1].isOperatorFor(mainaccount(),extraaccount()))

def test_t_balanceOf():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20(Token).balanceOf(extraaccount())==0*10**18)

def test_t_transfer():
    Token = MERC777[-1].get(mainaccount(),"", "")
    assert(interface.IERC20(Token).transfer(extraaccount(),3*10**18,{"from": mainaccount()}))
    assert(interface.IERC20(Token).balanceOf(extraaccount())==3*10**18)










