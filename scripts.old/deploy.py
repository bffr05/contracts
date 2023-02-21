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

def deployeraccount():
    if network.show_active() in {"development", "ganache"}:
        return accounts[1]
    else:
        return accounts.add(os.getenv("DEPLOYER_PKEY"))

def supply(accountfrom,account,amount):
    if account.balance() < amount:
        accountfrom.transfer(account,amount-account.balance()).wait(1)
    assert(account.balance() >= amount)


LocatorAddress = EthAddress("0x455b153B592d4411dCf5129643123639dcF3c806")
kAccess = network.web3.keccak(bytes("Access", 'ascii'))
kForwarder_Deployer = network.web3.keccak(bytes("Forwarder_Deployer", 'ascii'))

def main():
    export_network()
    myLocator = LocatorAddress
    nolocator = (len(network.web3.eth.get_code(myLocator)) == 0)

    if nolocator and len(Locator) > 0:
        myLocator = Locator[-1].address
    if nolocator:
        Locator.deploy({"from": mainaccount()})
        myLocator = Locator[-1].address
    print(f"LocatorAddress = {myLocator}")
    print(f"nolocator = {nolocator}")
    print(f"len = {len(network.web3.eth.get_code(myLocator))}")

    updatemapjson(str(network.web3.chain_id),"Locator",myLocator)
    print()

    ILocator = interface.ILocator(myLocator)

    TestAccess = True

    print(f"mainaccount = {mainaccount()}")
    print(f"mainaccount nonce = {mainaccount().nonce}")
    print(f"mainaccount balance = {mainaccount().balance()}")
    print(f"deployeraccount = {deployeraccount()}")
    print(f"deployeraccount nonce = {deployeraccount().nonce}")
    print(f"deployeraccount balance = {deployeraccount().balance()}")
    print(f"block_number :          {web3.eth.block_number}")

    if True: ##len(Access) ==0 or ILocator.get(kAccess) != Access[-1]:
        addr = Access.deploy({"from": mainaccount()}).address
        ILocator.set(kAccess,addr,{"from": mainaccount()})

        if nolocator:
            interface.ILocation(addr).setLocator(myLocator,{"from": mainaccount()}) 
            assert(interface.ILocation(addr).locator()==myLocator)
        else:
            assert(interface.ILocation(addr).locator()==LocatorAddress)

        if TestAccess:
            interface.IOperatorable(addr).setOperator(LocatorAddress,True,{"from": mainaccount()})
            assert(interface.IOperatorable(addr).isOperator(mainaccount(),LocatorAddress))
    updatemapjson(str(network.web3.chain_id),"Access",ILocator.get['bytes32'](kAccess))


    if True: ##len(Forwarder_Deployer) ==0 or ILocator.get(kForwarder_Deployer) != Forwarder_Deployer[-1]:
        addr = Forwarder_Deployer.deploy({"from": mainaccount()})
        ILocator.set(kForwarder_Deployer,addr,{"from": mainaccount()})
    updatemapjson(str(network.web3.chain_id),"Forwarder_Deployer",ILocator.get['bytes32'](kForwarder_Deployer))

    time.sleep(0.1)

