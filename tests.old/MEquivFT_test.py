from brownie import (
    accounts,
    network,
    config,
    TokenPlace,
    MEquivFT,
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
testFeatures = 0x0000000004 | 0x0000000100
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
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].exists(Token)==False)

def test_tm_declare():
    MEquivFT[-1].declare(testChainId, testToken,testFeatures,testSymbol,testName,{"from": mainaccount()})

def test_tm_exists2():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].exists(Token)==True)

def test_tm_features():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].features(Token)!=0)

def test_tm_equiv():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].equiv(Token)==[testChainId,testToken,testFeatures])


def test_codelen():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(network.web3.eth.get_code(Token))==0)

def test_tm_deploy():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    MEquivFT[-1].deploy(Token,{"from": mainaccount()})

def test_tm_exists3():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].exists(Token)==True)

def test_tm_features2():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(MEquivFT[-1].features(Token)!=0)

def test_codelen2():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(len(network.web3.eth.get_code(Token))!=0)

def test_t_owner():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IOwnable(Token).ownerOf()==mainaccount())

def test_tm_mint():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    MEquivFT[-1].mint(Token,mainaccount(),4*10**18,"","",{"from": mainaccount()})
    assert(MEquivFT[-1].totalSupply(Token)==4*10**18)

def test_t_name():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20Metadata(Token).name()==testName)

def test_t_symbol():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20Metadata(Token).symbol()==testSymbol)

def test_t_decimals():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20Metadata(Token).decimals()==18)

def test_t_totalSupply():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20(Token).totalSupply()==4*10**18)

def test_t_machine():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IMachined(Token).machine()==MEquivFT[-1])

def test_t_balanceOf():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20(Token).balanceOf(mainaccount())==4*10**18)

def test_tm_burn():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    MEquivFT[-1].burn(Token,0.5*10**18,"",{"from": mainaccount()})
    assert(MEquivFT[-1].totalSupply(Token)==3.5*10**18)

def test_t_burn():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    interface.IERC777(Token).burn(0.5*10**18,"",{"from": mainaccount()})
    assert(interface.IERC777(Token).totalSupply()==3.0*10**18)

def test_t_approve():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    interface.IERC20(Token).approve(extraaccount(),4*10**18,{"from": mainaccount()})
    assert(interface.IERC20(Token).allowance(mainaccount(),extraaccount())==4*10**18)

def test_t_authorizeOperator():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(TokenPlace[-1].isTrusted(MEquivFT[-1]))
    assert(not interface.IERC777(Token).isOperatorFor(mainaccount(),extraaccount()))
    interface.IERC777(Token).authorizeOperator(extraaccount(),{"from": mainaccount()})

    assert(interface.IERC777(Token).isOperatorFor(mainaccount(),extraaccount()))

def test_t_revokeOperator():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    TokenPlace[-1].revokeOperator(extraaccount(),{"from": mainaccount()})
    assert(not TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount()))

def test_t_authorizeOperator2():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(not TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount()))
    TokenPlace[-1].authorizeOperator(extraaccount(),{"from": mainaccount()})
    assert(TokenPlace[-1].isOperatorFor(mainaccount(),extraaccount())==False)

def test_t_revokeOperator():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(TokenPlace[-1].isTrusted(MEquivFT[-1]))
    MEquivFT[-1].revokeOperator(extraaccount(),{"from": mainaccount()})
    assert(not MEquivFT[-1].isOperatorFor(mainaccount(),extraaccount()))

def test_t_balanceOf():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20(Token).balanceOf(extraaccount())==0*10**18)

def test_t_transfer():
    Token = MEquivFT[-1].get(mainaccount(),testChainId, testToken)
    assert(interface.IERC20(Token).transfer(extraaccount(),3*10**18,{"from": mainaccount()}))
    assert(interface.IERC20(Token).balanceOf(extraaccount())==3*10**18)










