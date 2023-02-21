## brownie run scripts/deploy.py --network n9997


from brownie import * 
from brownie.convert.datatypes import EthAddress 
import os
import json
import yaml
import time

from dotenv import load_dotenv ##pipx install python-dotenv 

load_dotenv()

def brownie_project(tag):
    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        for entry in config_dict["dependencies"]:
            if tag in entry:
                return  project.load(entry)
    return project.main

def updatemapjson( network, title, address):
    open("./build/deployments/map.json", "a+")
    with open("./build/deployments/map.json", "r+") as map_json:
        map_json.seek(0)
        try:
            data = json.load(map_json)
        except:
            data = json.loads("{}")
        list = []
        if data.get(network) is None:
            data[network] = dict()
        if not data[network].get(title) is None:
            list = data[network][title]
            if list[len(list)-1] == address:
                return
        ##if list[-1]!=address:
        list.append(address)
        data[network][title] = list
        map_json.seek(0)
        map_json.write(json.dumps(data,sort_keys=True,indent=2))


def find_network(chainid):
    with open("network-config.json", "r") as network_config:
        data = json.load(network_config)
        for entry in data["live"]:
            for network in entry["networks"]:
                print(network)
                if network["chainid"] == chainid:
                    return network["host"]

def export_network():
    print(f"\nExporting network")
    with open("network-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        with open("network-config.json", "w") as brownie_config_json:
            json.dump(config_dict, brownie_config_json,sort_keys=True,indent=2)

def supply(accountfrom,account,amount):
    if account.balance() < amount:
        accountfrom.transfer(account,amount-account.balance()).wait(1)


EthAddress0 = EthAddress("0x0000000000000000000000000000000000000000")

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

def supply(accountfrom,account,amount):
    if account.balance() < amount:
        accountfrom.transfer(account,amount-account.balance()).wait(1)
    assert(account.balance() >= amount)


LocatorAddress = EthAddress("0x455b153B592d4411dCf5129643123639dcF3c806")
mycontracts = brownie_project("bffr05/contracts")
token = brownie_project("bffr05/token")
kAccess = network.web3.keccak(bytes("Access", 'ascii'))
kTokenPlace = network.web3.keccak(bytes("TokenPlace", 'ascii'))
kOracle = network.web3.keccak(bytes("Oracle", 'ascii'))

kForwarder_Deployer = network.web3.keccak(bytes("Forwarder_Deployer", 'ascii'))
kMEquivFT = network.web3.keccak(bytes("MEquivFT", 'ascii'))
kMEquivNFT = network.web3.keccak(bytes("MEquivNFT", 'ascii'))
kGate = network.web3.keccak(bytes("Gate", 'ascii'))
kMulticall = network.web3.keccak(bytes("Multicall", 'ascii'))

myLocator = EthAddress0

def getNoLocator():
    return (len(network.web3.eth.get_code(LocatorAddress)) == 0)
def getLocator():
    nolocator = getNoLocator()
    if nolocator and len(mycontracts.Locator) > 0:
        return mycontracts.Locator[-1].address
    elif nolocator:
        mycontracts.Locator.deploy({"from": mainaccount()})
        return mycontracts.Locator[-1].address
    else:
        return LocatorAddress
    

def main():
    export_network()
    nolocator = getNoLocator()
    myLocator = getLocator()

    print(f"LocatorAddress = {myLocator}")
    print(f"nolocator = {nolocator}")
    print(f"len = {len(network.web3.eth.get_code(myLocator))}")

    updatemapjson(str(network.web3.chain_id),"Locator",myLocator)
    print()

    ILocator = interface.ILocator(myLocator)

    TestAccess = False



    if True: ##len(Access) ==0 or ILocator.get(kAccess) != Access[-1]:
        addr = mycontracts.Access.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kAccess,addr,{"from": mainaccount()})

        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()}) 
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        if TestAccess:
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"Access",ILocator.get(kAccess))


    if True: ##len(TokenPlace) ==0 or ILocator.get(kTokenPlace) != TokenPlace[-1]:
        addr = token.TokenPlace.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kTokenPlace,addr,{"from": mainaccount()})
        ##isTrusted
        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()}) 
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        assert(addr.referral()==ILocator.location(kAccess))

        if False: ##TestAccess:
            assert(not addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,False,{"from": mainaccount()})
            assert(not addr.isOperator(mainaccount(),LocatorAddress))

        mycontracts.interface.IRTrustable(ILocator.location(kAccess)).setContract(addr,True,{"from": mainaccount()}) 

        if TestAccess:
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"TokenPlace",ILocator.get(kTokenPlace))


    if True: ##len(TokenPlace) ==0 or ILocator.get(kTokenPlace) != TokenPlace[-1]:
        addr = mycontracts.Oracle.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kOracle,addr,{"from": mainaccount()})
        ##isTrusted
        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()}) 
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        assert(addr.referral()==ILocator.location(kAccess))

        if False: ##TestAccess:
            assert(not addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,False,{"from": mainaccount()})
            assert(not addr.isOperator(mainaccount(),LocatorAddress))

        mycontracts.interface.IRTrustable(ILocator.location(kAccess)).setContract(addr,True,{"from": mainaccount()}) 

        if TestAccess:
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"Oracle",ILocator.get(kOracle))

    if True: ##len(Forwarder_Deployer) ==0 or ILocator.get(kForwarder_Deployer) != Forwarder_Deployer[-1]:
        addr = mycontracts.Forwarder_Deployer.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kForwarder_Deployer,addr,{"from": mainaccount()})
    updatemapjson(str(network.web3.chain_id),"Forwarder_Deployer",ILocator.get(kForwarder_Deployer))



    if True: ##len(MEquivFT) ==0 or ILocator.get(kMEquivFT) != MEquivFT[-1]:
        addr = token.MEquivFT.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kMEquivFT,addr,{"from": mainaccount()})

        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()})
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        if False: ##TestAccess:
            assert(not addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,False,{"from": mainaccount()})
            assert(not addr.isOperator(mainaccount(),LocatorAddress))

        mycontracts.interface.IRTrustable(ILocator.location(kAccess)).setContract(addr,True,{"from": mainaccount()}) 

        if TestAccess:
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"MEquivFT",ILocator.get(kMEquivFT))


    if True: ##len(MEquivNFT) ==0 or ILocator.get(kMEquivNFT) != MEquivNFT[-1]:
        addr = token.MEquivNFT.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kMEquivNFT,addr,{"from": mainaccount()})

        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()})
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        if False: ##TestAccess:
            assert(not addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,False,{"from": mainaccount()})
            assert(not addr.isOperator(mainaccount(),LocatorAddress))

        mycontracts.interface.IRTrustable(ILocator.location(kAccess)).setContract(addr,True,{"from": mainaccount()}) 

        if TestAccess:
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"MEquivNFT",ILocator.get(kMEquivNFT))


    if True: ##len(Gate) ==0 or ILocator.get(kGate) != Gate[-1]:
        GateLib.deploy({"from": mainaccount()})
        addr = Gate.deploy({"from": mainaccount()})
        ILocator.set['bytes32,address'](kGate,addr,{"from": mainaccount()})

        if nolocator:
            addr.setLocator(myLocator,{"from": mainaccount()})
            assert(addr.locator()==myLocator)
        else:
            assert(addr.locator()==LocatorAddress)

        if False: ##TestAccess:
            assert(not addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(addr.isOperator(mainaccount(),LocatorAddress))
            addr.setOperator(LocatorAddress,False,{"from": mainaccount()})
            assert(not addr.isOperator(mainaccount(),LocatorAddress))

        mycontracts.interface.IRTrustable(ILocator.location(kAccess)).setContract(addr,True,{"from": mainaccount()}) 

        if TestAccess:
            assert(addr.isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"Gate",ILocator.get(kGate))

    if False: ##len(Gate) ==0 or ILocator.get(kGate) != Gate[-1]:
        addr = multicall.deploy({"from": mainaccount()})
        ILocator.set(kMulticall,addr,{"from": mainaccount()})
        updatemapjson(str(network.web3.chain_id),"Multicall",ILocator.get['bytes32'](kMulticall))

    ##destChainId = 9998
    ##if web3.eth.chain_id == 9998:
    ##    destChainId = 9997

    ##Gate[-1].tokenOut(destChainId,"0x0000000000000000000000000000000000000000",0,3,{"from": mainaccount(),"value":8})

    time.sleep(0.5)