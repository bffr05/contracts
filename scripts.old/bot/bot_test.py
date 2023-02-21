import json
from operator import truediv
import random
from web3 import Web3,IPCProvider,middleware
##from web3.auto.gethdev import w3
from web3.middleware import geth_poa_middleware
from web3.gas_strategies.time_based import medium_gas_price_strategy
from web3.gas_strategies.rpc import rpc_gas_price_strategy
from eth_keys import keys
import time
from requests.exceptions import ConnectionError
import json
from eth_account import Account
import os
import sys
from dotenv import load_dotenv ##pipx install python-dotenv  
from web3_multicall import Multicall ## pip3 install web3_multicall
from decimal import Decimal

print(f"starting...")
load_dotenv()

LocatorAddress = "0x1Fde523e424307d606E2d64839503495B2dE653e"
account = Account.from_key(os.getenv("BOT_PKEY"))

print(f"account.address :               {account.address}")
print(f"\n")

LocatorJSON = json.load(open('bffr05/locator@0.0.2/build/contracts/Locator.json'))
GateJSON = json.load(open('build/contracts/Gate.json'))
MERC777JSON = json.load(open('build/contracts/MERC777.json'))
MERC721JSON = json.load(open('build/contracts/MERC721.json'))


config = dict()


## check pre requisite
with open("network-config.json", "r") as network_config:
    data = json.load(network_config)
    for entry in data["live"]:
        for currentnetwork in entry["networks"]:
            try:
                chainid = currentnetwork['chainid']
                web3 = Web3(Web3.HTTPProvider(currentnetwork["host"])) 
                web3.eth.default_account = account.address
                web3.eth.set_gas_price_strategy(rpc_gas_price_strategy)
                ##assert(web3.eth.chain_id==currentnetwork["chainid"])
                print(f"###################### Connect {chainid}")
                print(f"chainid :               {web3.eth.chain_id}")
                print(f"gasPrice :              {web3.eth.gasPrice}")
                print(f"generate_gas_price :    {web3.eth.generate_gas_price()}")
                print(f"syncing :               {web3.eth.syncing}")
                print(f"mining :                {web3.eth.mining}")
                print(f"block_number :          {web3.eth.block_number}")
                print(f"Locator Size :          {len(web3.eth.get_code(LocatorAddress))}")
                Locator = web3.eth.contract(address=LocatorAddress, abi=LocatorJSON['abi'])
                GateAddress = Locator.functions.location_assert(Locator.functions.hash("Gate").call()).call()
                MERC777Address = Locator.functions.location_assert(Locator.functions.hash("MERC777").call()).call()
                MERC721Address = Locator.functions.location_assert(Locator.functions.hash("MERC721").call()).call()
                print(f"Gate Address :          {GateAddress}")
                print(f"MEquivFT Address :      {MEquivFTAddress}")
                print(f"MEquivNFT Address :     {MEquivNFTAddress}")
                Gate = web3.eth.contract(address=GateAddress, abi=GateJSON['abi'])
                MERC777 = web3.eth.contract(address=MERC777Address, abi=MERC777JSON['abi'])
                MERC721 = web3.eth.contract(address=MERC721Address, abi=MERC721JSON['abi'])
                print(f"\n")
                print(f"\n")

                if not chainid in config:
                    config[chainid] = dict()
                config[chainid]["web3"] = web3
                config[chainid]["Locator"] = Locator
                config[chainid]["Gate"] = Gate
                config[chainid]["MERC777"] = MERC777
                config[chainid]["MERC721"] = MERC721

            except KeyboardInterrupt:
                raise
            finally:
                pass

print(config)
while True:
    for chainid in config:
        print(f"###################### Connect {chainid}")
        try:
            web3 = config[chainid]["web3"]
            print(f"block_number :          {web3.eth.block_number}")


        except KeyboardInterrupt:
            raise
        finally:
            pass
    break

