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

def test_Gate_setChain(pm):
    Gate[-1].setChain(10,True,0,{"from": mainaccount()})
    
def test_GateOut_currency():
    tx = Gate[-1].gateOut(10,"0x0000000000000000000000000000000000000000",3,{"from": mainaccount(),"value":8})
    assert(len(tx.events['GateTokenOut'])==1)
    id=tx.events['GateTokenOut'][0]['id']
    assert(id==Gate[-1].base())
    assert(id==1)
    rec = Gate[-1].outRecords(id)
    assert(rec['chainId']==10)
    assert(Gate[-1].validGateOut(id)) ##assert(rec['timestamp']==web3.eth.block_number)
    assert(rec['user']==mainaccount())
    assert(rec['tokenChainId']==web3.eth.chain_id)
    assert(rec['token']=="0x0000000000000000000000000000000000000000")
    assert(rec['localToken']=="0x0000000000000000000000000000000000000000")
    assert(rec['v']==3)
    assert(rec['value']==5)

def test_GateOutRevert_currency(pm):
    id=Gate[-1].base()      
    assert(id==1)
    balancebefore = mainaccount().balance()
    tx = Gate[-1].gateOutRevert(id,{"from": mainaccount()})
    balanceafter = mainaccount().balance()
    if network.show_active() in {"development", "ganache"}:
        assert(balanceafter-balancebefore==3)
    ##else:
    ##    assert(balanceafter>balancebefore)
    ##assert(id<Gate[-1].base())
    assert(Gate[-1].base()==Gate[-1].next())
    rec = Gate[-1].outRecords(id)

testNFTChainId = 7777
testNFTToken = "0x0000000000000000000000000000000000000123"
testNFTFeatures = 0x0000000008 | 0x0000000200
testNFTName = "Artiste"
testNFTSymbol = "ART"

def test_GateIn_EquivNFT(pm):
    ILocator = interface.ILocator(getLocator())
    aMEquivNFT = ILocator.location(kMEquivNFT)

    Token = interface.IMEquiv(aMEquivNFT).get(Gate[-1],testNFTChainId, testNFTToken)
    assert(not interface.IMachine(aMEquivNFT).exists(Token))
    tx = Gate[-1].gateIn(testNFTChainId, 1, mainaccount(),testNFTChainId,testNFTToken,testNFTFeatures,testNFTSymbol,testNFTName,340,{"from": mainaccount()})

    ##function gateIn(uint56 chainId_, uint256 recordId_, address user_,uint56 tokenChainId_, address token_,uint40 features_,string memory symbol_,string memory name_,uint256 v_) external onlyOperator(ownerOf()) {

    assert(len(tx.events['GateTokenIn'])==1)
    assert(tx.events['GateTokenIn'][0]['chainId']==testNFTChainId)
    assert(tx.events['GateTokenIn'][0]['user']==mainaccount())
    assert(tx.events['GateTokenIn'][0]['tokenChainId']==testNFTChainId)
    assert(tx.events['GateTokenIn'][0]['token']==testNFTToken)
    assert(tx.events['GateTokenIn'][0]['localToken']==Token)
    assert(tx.events['GateTokenIn'][0]['v']==340)
    if len(network.web3.eth.get_code(Token)) == 0:
        interface.IMEquiv(aMEquivNFT).deploy(Token,{"from": mainaccount()})
        assert(len(network.web3.eth.get_code(Token)) != 0)
    assert(interface.IERC721Extended(Token).exists(340))
    assert(interface.IERC721(Token).ownerOf(340)==mainaccount())
    assert(interface.IEquiv(Token).equiv()[0]==testNFTChainId)
    assert(interface.IEquiv(Token).equiv()[1]==testNFTToken)

def test_GateOut_EquivNFT(pm):
    Gate[-1].setChain(testNFTChainId,True,5,{"from": mainaccount()})
    Token = token.MEquivNFT[-1].get(Gate[-1],testNFTChainId, testNFTToken)
    assert(token.MEquivNFT[-1].exists['address'](Token))

    print(f"equiv = {interface.IEquiv(Token).equiv()}")
    token.MEquivNFT[-1].approve(Token,Gate[-1],340)
    tx = Gate[-1].gateOut(testNFTChainId,Token,340,{"from": mainaccount(),"value":8})
    assert(len(tx.events['GateTokenOut'])==1)
    id=tx.events['GateTokenOut'][0]['id']
    assert(id==Gate[-1].base())
    assert(Gate[-1].base()<Gate[-1].next())
    assert(not interface.IERC721Extended(Token).exists(340))

    rec = Gate[-1].outRecords(id)
    assert(rec['chainId']==testNFTChainId)
    assert(rec['user']==mainaccount())
    assert(rec['tokenChainId']==testNFTChainId)
    assert(rec['token']==testNFTToken)
    assert(rec['localToken']==Token)
    assert(rec['v']==340)
    assert(rec['value']==8)

def test_GateOutComplete_EquivNFT(pm):
    id=Gate[-1].base()      
    balancebefore = mainaccount().balance()
    tx = Gate[-1].gateOutComplete(id,5)
    balanceafter = mainaccount().balance()
    assert(balanceafter>balancebefore)
    ##assert(id<Gate[-1].base())
    assert(Gate[-1].base()==Gate[-1].next())
    rec = Gate[-1].outRecords(id)


testFTChainId = 98954568
testFTToken = "0x0000000000000000000000000000000000000321"
testFTFeatures = 0x0000000004 | 0x0000000100
testFTName = "Patate"
testFTSymbol = "PAT"

def test_GateIn_EquivFT(pm):

    Token = token.MEquivFT[-1].get(Gate[-1],testFTChainId, testFTToken)
    assert(not token.MEquivFT[-1].exists(Token))
    tx = Gate[-1].gateIn(testFTChainId, 1, mainaccount(),testFTChainId,testFTToken,testFTFeatures,testFTSymbol,testFTName,10*10**18,{"from": mainaccount()})

    assert(len(tx.events['GateTokenIn'])==1)
    assert(tx.events['GateTokenIn'][0]['chainId']==testFTChainId)
    assert(tx.events['GateTokenIn'][0]['user']==mainaccount())
    assert(tx.events['GateTokenIn'][0]['tokenChainId']==testFTChainId)
    assert(tx.events['GateTokenIn'][0]['token']==testFTToken)
    assert(tx.events['GateTokenIn'][0]['localToken']==Token)
    assert(tx.events['GateTokenIn'][0]['v']==10*10**18)
    if len(network.web3.eth.get_code(Token)) == 0:
        token.MEquivFT[-1].deploy(Token,{"from": mainaccount()})
        assert(len(network.web3.eth.get_code(Token)) != 0)

    assert(interface.IERC777(Token).totalSupply()==10*10**18)
    assert(interface.IERC777(Token).balanceOf(mainaccount())==10*10**18)
    assert(interface.IEquiv(Token).equiv()[0]==testFTChainId)
    assert(interface.IEquiv(Token).equiv()[1]==testFTToken)

def test_GateOut_EquivFT(pm):
    Gate[-1].setChain(testFTChainId,True,5,{"from": mainaccount()})
    Token = token.MEquivFT[-1].get(Gate[-1],testFTChainId, testFTToken)
    assert(token.MEquivFT[-1].exists(Token))

    print(f"equiv = {interface.IEquiv(Token).equiv()}")
    token.MEquivFT[-1].approve(Token,Gate[-1],9*10**18)
    tx = Gate[-1].gateOut(testFTChainId,Token,9*10**18,{"from": mainaccount(),"value":8})
    assert(len(tx.events['GateTokenOut'])==1)
    id=tx.events['GateTokenOut'][0]['id']
    assert(id==Gate[-1].base())
    assert(Gate[-1].base()<Gate[-1].next())
    ##assert(not interface.IERC721Extended(Token).exists(340))

    rec = Gate[-1].outRecords(id)
    assert(rec['chainId']==testFTChainId)
    assert(rec['user']==mainaccount())
    assert(rec['tokenChainId']==testFTChainId)
    assert(rec['token']==testFTToken)
    assert(rec['localToken']==Token)
    assert(rec['v']==9*10**18)
    assert(rec['value']==8)
    assert(interface.IERC777(Token).balanceOf(mainaccount())==10**18)

def test_GateOutRevert_EquivFT(pm):
    id=Gate[-1].base()      
    Token = token.MEquivFT[-1].get(Gate[-1],testFTChainId, testFTToken)
    assert(interface.IERC777(Token).balanceOf(mainaccount())==10**18)
    tx = Gate[-1].gateOutRevert(id)
    assert(interface.IERC777(Token).balanceOf(mainaccount())==10*10**18)
    ##assert(id<Gate[-1].base())
    assert(Gate[-1].base()==Gate[-1].next())
    rec = Gate[-1].outRecords(id)
