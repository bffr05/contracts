
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
kForwarder_Deployer = network.web3.keccak(bytes("Forwarder_Deployer", 'ascii'))
kMEquivFT = network.web3.keccak(bytes("MEquivFT", 'ascii'))
kMEquivNFT = network.web3.keccak(bytes("MEquivNFT", 'ascii'))
kGate = network.web3.keccak(bytes("Gate", 'ascii'))

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
    myLocator = getLocator()

    ILocator = interface.ILocator(myLocator)

    destChainId = 9998
    if web3.eth.chain_id == 9998:
        destChainId = 9997

    tx = Gate[-1].test(destChainId,{"from": mainaccount()})
    exit(0)
    tx = Gate[-1].tokenOut(destChainId,"0x0000000000000000000000000000000000000000",0,3,{"from": mainaccount(),"value":8})
    blocknumber = tx.block_number
    assert(len(tx.events['Outbound'])==1)
    print(f"base={Gate[-1].base()} nonce={Gate[-1].nonce()}")
    id = Gate[-1].nonce()-1
    ##blocknumber = Gate[-1].messages(Gate[-1].nonce()-1)
    print(f"id={id} blocknumber={blocknumber}")

    GateContract = network.web3.eth.contract(address=Gate[-1].address, abi=Gate.abi)


    GateOut = None
    
    block = network.web3.eth.get_block(blocknumber)
    for t in block.transactions:
        tr = network.web3.eth.get_transaction_receipt(t)
        for l in tr['logs']:
            if (l['address']) == GateContract.address:
                r = GateContract.events.Outbound().processReceipt(tr)
                for ri in r:
                    if ri['args']['nonce'] == id:
                        GateOut = ri['args']
    ##print(f"GateOut={GateOut}")
    assert(GateOut['nonce']==id)
    assert(GateOut['chainId']==destChainId)
    assert(GateOut['src']==mainaccount())
    assert(GateOut['message'][0]==1)
    mm = GateContract.functions.decodeMulti(GateOut['message'][1]).call()
    ##print(mm)
    assert(mm[0][0]==2) ## FT
    assert(mm[1][0]==5) ## Transfer
    sft = GateContract.functions.decodeFT(mm[0][1]).call()
    st = GateContract.functions.decodeAddress(mm[1][1]).call()
    ##print(mm)
    assert(sft[0]==network.web3.eth.chain_id)
    assert(sft[1]=="0x0000000000000000000000000000000000000000")
    assert(sft[2]==3)
    assert(st[0]==mainaccount())
    ##assert(ft[0]==mainaccount())
    ##assert(ft[1]=="0x0000000000000000000000000000000000000000")
    ##assert(ft[2]==mainaccount())
    ##assert(ft[3]==network.web3.eth.chain_id)
    ##assert(ft[4]=="0x0000000000000000000000000000000000000000")
    ##assert(ft[5]==3)
   
