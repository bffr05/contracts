## brownie run scripts/deploy.py --network n9997


from brownie import * 
from brownie.convert.datatypes import EthAddress 
import os
import json
import yaml

try:
    from Crypto.Hash import keccak
    sha3_256 = lambda x: keccak.new(digest_bits=256, data=x).digest()
except:
    import sha3 as _sha3
    sha3_256 = lambda x: _sha3.sha3_256(x).digest()

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
    with open("./build/deployments/map.json", "r+") as map_json:
        data = json.load(map_json)
        list = []
        if not data[network].get(title) is None:
            list = data[network][title]
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


#################################################################################
## For Testing Purpose
#################################################################################
DEPLOYER_KEY="0xb0527ed7ff4c0eed996e913a96f4c3eb794f885a74e152131d8566d4ea05078a"
DEPLOYER_KEY="0xbefe15befe15befe15befe15befe15eb794f885a74e152131d8566d4ea05078a"
DEPLOYER_PUBKEY="0x613a238E5330a09fd0b0bae84AB1447e9b9CEA39"

SUPPLY_NEEDED = 0.1*10**18

def deployer():
    return accounts.add(DEPLOYER_KEY)

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


mycontracts = brownie_project("bffr05/contracts")

def main():
    assert(deployer().address==DEPLOYER_PUBKEY)
    print(f"initial")
    print(f"deployer address : {deployer().address}")
    print(f"deployer balance : {deployer().balance()}")
    print(f"mainaccount balance : {mainaccount().balance()}")
    print()

    supply(mainaccount(),deployer(),SUPPLY_NEEDED)

    print(f"deployer nonce : {deployer().nonce}")
    print()


    if deployer().nonce == 0:
        predicted = deployer().get_deployment_address(deployer().nonce)
        print(f"predicted Locator={predicted}")
        print()
        mycontracts.Locator.deploy({"from": deployer(),"nonce":deployer().nonce})
        print()

    if deployer().nonce == 1:
        print(f"owner Locator={mycontracts.Locator[-1].ownerOf()}")
        mycontracts.Locator[-1].transfer(mainaccount(),{"from": deployer(),"nonce":deployer().nonce})
        print(f"new owner Locator={mycontracts.Locator[-1].ownerOf()}")
        print()


    print(f"deployer balance : {deployer().balance()}")
    print(f"mainaccount balance : {mainaccount().balance()}")
    print()


