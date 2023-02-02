from brownie import *
import os
import sys
from eth_utils import keccak

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

def test_trusted1():
    Trustable1 = TrustableServer.deploy({"from": mainaccount()})
    Trustable2 = TrustableServer.deploy({"from": mainaccount()})
    Trustable3 = TrustableServer.deploy({"from": mainaccount()})
    Trustable1.setHash(keccak(network.web3.eth.get_code(
        Trustable2.address)), True, {"from": mainaccount()})
    assert (Trustable1.isTrusted(Trustable2))
    assert (Trustable1.isTrusted(Trustable3))


def test_trusted2():
    Trustable1 = TrustableServer.deploy({"from": mainaccount()})
    Trustable2 = TrustableServer.deploy({"from": mainaccount()})
    Trustable3 = TrustableServer.deploy({"from": mainaccount()})
    Trustable1.set(Trustable2, True, {"from": mainaccount()})
    assert (Trustable1.isTrusted(Trustable2))
    assert (Trustable1.isTrusted(Trustable3))


def test_trusted3():
    Trustable1 = TrustableServer.deploy({"from": mainaccount()})
    Trustable2 = TrustableServer.deploy({"from": mainaccount()})
    Trustable3 = TrustableServer.deploy({"from": mainaccount()})
    Trustable1.setContract(Trustable2, True, {"from": mainaccount()})
    assert (Trustable1.isTrusted(Trustable2))
    assert (not Trustable1.isTrusted(Trustable3))


def test_trusted4():
    Trustable1 = TrustableServer.deploy({"from": mainaccount()})
    predicted = mainaccount().get_deployment_address(mainaccount().nonce+1)
    Trustable1.setContract(predicted, True, {"from": mainaccount()})
    Trustable2 = TrustableServer.deploy({"from": mainaccount()})
    Trustable3 = TrustableServer.deploy({"from": mainaccount()})
    assert (Trustable2 == predicted)
    assert (Trustable1.isTrusted(Trustable2))
    assert (not Trustable1.isTrusted(Trustable3))
