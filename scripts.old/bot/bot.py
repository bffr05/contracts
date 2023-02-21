import os
import json
import yaml
import time
import sys
import web3 as web3
import requests
from os.path import expanduser
from web3.middleware import geth_poa_middleware
from enum import Enum

from eth_account import Account
from web3 import Web3,IPCProvider,middleware
from web3.exceptions import TransactionNotFound
from web3.middleware import geth_poa_middleware
from web3.gas_strategies.time_based import medium_gas_price_strategy
from web3.gas_strategies.rpc import rpc_gas_price_strategy
from eth_keys import keys

from dotenv import load_dotenv ##pipx install python-dotenv 

load_dotenv()

chains = requests.get("https://chainid.network/chains_mini.json").json()

def brownie_dependencies(tag):
    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        for entry in config_dict['dependencies']:
            if tag in entry:
                return  entry

def botaccountpriv():
    return os.getenv("BOT_PKEY")
def botaccount():
    return Account.from_key(botaccountpriv())

def In(web3conn,gate,msglist):
    nonce = web3conn.eth.get_transaction_count(botaccount().address)
    print(f"==> In nonce={nonce}")
    txn = gate.functions.In(msglist).buildTransaction({
        'chainId': web3conn.eth.chain_id,
        'gasPrice': web3conn.eth.generate_gas_price() ,
        'from': botaccount().address,
        'nonce': nonce,
        })

    signed_txn = web3conn.eth.account.sign_transaction(txn, private_key=botaccountpriv())
    tx_hash = web3conn.eth.send_raw_transaction(signed_txn.rawTransaction)  
    return tx_hash

def OutCompleted(web3conn,gate,msglist):
    nonce = web3conn.eth.get_transaction_count(botaccount().address)
    print(f"==> GateOutCompleted nonce={nonce}")
    txn = gate.functions.OutCompleted(msglist).buildTransaction({
        'chainId': web3conn.eth.chain_id,
        'gasPrice': web3conn.eth.generate_gas_price() ,
        'from': botaccount().address,
        'nonce': nonce,
        })

    signed_txn = web3conn.eth.account.sign_transaction(txn, private_key=botaccountpriv())
    tx_hash = web3conn.eth.send_raw_transaction(signed_txn.rawTransaction)  
    return tx_hash

kBlockTruth = Web3.keccak(bytes("BlockTruth", 'ascii'))


def BlockTruth(web3conn,oracle,blocknumber):
    nonce = web3conn.eth.get_transaction_count(botaccount().address)
    print(f"==> BlockTruth nonce={nonce}")
    txn = oracle.functions.set(kBlockTruth,blocknumber).buildTransaction({
        'chainId': web3conn.eth.chain_id,
        'gasPrice': web3conn.eth.generate_gas_price() ,
        'from': botaccount().address,
        'nonce': nonce,
        })

    signed_txn = web3conn.eth.account.sign_transaction(txn, private_key=botaccountpriv())
    tx_hash = web3conn.eth.send_raw_transaction(signed_txn.rawTransaction)  
    return tx_hash

def findEventOut(web3conn,gate,blocknumber, id):
    block = web3conn.eth.get_block(blocknumber)
    for t in block.transactions:
        tr = web3conn.eth.get_transaction_receipt(t)
        for l in tr['logs']:
            if (l['address']) == gate.address:
                print(f'processReceipt {tr}')
                r = gate.events.Outbound().processReceipt(tr)
                for ri in r:
                    if ri['args']['message'][0] == id:
                        return ri['args']['message']
    assert(False)


##event In(uint56 indexed chainId, uint256 indexed nonce, Message message, bool result, bytes returned_);
def findEventIn(web3conn,gate,id):
    blocknumber = web3.eth.block_number
    while True:
        block = web3conn.eth.get_block(blocknumber)
        for t in block.transactions:
            tr = web3conn.eth.get_transaction_receipt(t)
            for l in tr['logs']:
                if (l['address']) == gate.address:
                    r = gate.events.In().processReceipt(tr)
                    for ri in r:
                        if ri['args']['message'][0] == id:
                            return ri['args']['message']
        blocknumber=blocknumber-1

print(f"argv = {sys.argv}")
##for arg in sys.argv:
##    print(arg)

EthAddress0 = "0x0000000000000000000000000000000000000000"

GateMessageDict_chainId = 0
GateMessageDict_id = 1

MessageDict_type = 0     
MessageDict_msg = 1           

class MessageType(Enum):
    NONE=0
    Multi = 1
    FT = 2 
    NFT = 3
    MT = 4 
    Transfer = 5

def queryTokenInfo(config,chainid,token,outlist):
    for o in outlist:
        if o[0]==chainid and o[1]==token:
            return
    features = 0
    symbol = ''
    name = ''
    if chainid in config:
        TokenPlace = config[chainid]['TokenPlace'] 
        features  = TokenPlace.functions.roFeatures(token).call()
        symbol = TokenPlace.functions.symbol(token).call()
        name = TokenPlace.functions.name(token).call()
    if  (symbol=='' or name=='') and  token == EthAddress0:
        features  = 0x101
        name = "Currency " + str(chainid)
        symbol = "Cur"
        for c in chains:
            #print(f" c entry = {c}")
            if c['chainId']==chainid:
                symbol = c['nativeCurrency']['symbol']
                name = c['nativeCurrency']['name']
                break
    print(f"\t\tToken {chainid}/{token} {symbol} {name} {features} ")
    outlist.append([chainid,token,symbol,name,18,features])

def getTokenInfo(config,chainid,msg,outlist):
    Gate = config[chainid]['Gate'] 
    ##print(f"\t\tgetTokenInfo {msg}")
    ##print(f"\t\tmsg[MessageDict_type] {msg[MessageDict_type]}")
    if MessageType(msg[MessageDict_type]) == MessageType.Multi:
        ##print(f"\t\tmsg[MessageDict_type] == MessageType.Multi")
        submessage = Gate.functions.decodeMulti(msg[MessageDict_msg]).call()
        ##print(f"\t\tdecodeMulti {submessage}")
        for s in submessage:
            getTokenInfo(config,chainid,s,outlist)
    elif MessageType(msg[MessageDict_type]) == MessageType.FT:
        submessage = Gate.functions.decodeFT(msg[MessageDict_msg]).call()
        ##print(f"\t\tdecodeFT {submessage}")

        if submessage[0]!=chainid:
            print(f"\t\tprocessing Token {submessage[0]}/{submessage[1]}")
            queryTokenInfo(config,submessage[0],submessage[1],outlist)
    elif MessageType(msg[MessageDict_type]) == MessageType.NFT:
        submessage = Gate.functions.decodeNFT(msg[MessageDict_msg]).call()
        ##print(f"\t\tdecodeNFT {submessage}")

        if submessage[0]!=chainid:
            print(f"\t\tprocessing Token {submessage[0]}/{submessage[1]}")
            queryTokenInfo(config,submessage[0],submessage[1],outlist)

    elif MessageType(msg[MessageDict_type]) ==  MessageType.MT:
        submessage = Gate.functions.decodeMT(msg[MessageDict_msg]).call()
        ##print(f"\t\tdecodeMT {submessage}")

        if submessage[0]!=chainid:
            print(f"\t\tprocessing Token {submessage[0]}/{submessage[1]}")
            queryTokenInfo(config,submessage[0],submessage[1],outlist)




LocatorAddress = "0x455b153B592d4411dCf5129643123639dcF3c806"



print(f"account.address :               {botaccount().address}")
print(f"\n")
LocatorJSON = json.load(open(expanduser(f"~/.brownie/packages/{brownie_dependencies('bffr05/contracts')}/build/contracts/Locator.json")))
GateJSON = json.load(open('build/contracts/Gate.json'))
TokenPlaceJSON = json.load(open(expanduser(f"~/.brownie/packages/{brownie_dependencies('bffr05/token')}/build/contracts/TokenPlace.json")))
OracleJSON = json.load(open(expanduser(f"~/.brownie/packages/{brownie_dependencies('bffr05/contracts')}/build/contracts/Oracle.json")))

kAccess = Web3.keccak(bytes("Access", 'ascii'))
kTokenPlace = Web3.keccak(bytes("TokenPlace", 'ascii'))
kOracle = Web3.keccak(bytes("Oracle", 'ascii'))
kForwarder_Deployer = Web3.keccak(bytes("Forwarder_Deployer", 'ascii'))
kMEquivFT = Web3.keccak(bytes("MEquivFT", 'ascii'))
kMEquivNFT = Web3.keccak(bytes("MEquivNFT", 'ascii'))
kGate = Web3.keccak(bytes("Gate", 'ascii'))
kMulticall = Web3.keccak(bytes("Multicall", 'ascii'))



config = dict()


EventDict_chainId = 0
EventDict_nonce = 1
EventDict_message = 2
EventDict_len = 3


RunChainValidator = True


## check pre requisite
with open("network-config.json", "r") as network_config:
    data = json.load(network_config)
    for entry in data['live']:
        for currentnetwork in entry['networks']:
            if len(sys.argv) > 1:
                
                if not str(currentnetwork['chainid']) in sys.argv:
                    continue
            try:
                web3 = Web3(Web3.HTTPProvider(currentnetwork['host'])) 
                web3.eth.default_account = botaccount().address
                web3.eth.set_gas_price_strategy(rpc_gas_price_strategy)
                web3.middleware_onion.inject(geth_poa_middleware, layer=0)

                ##assert(web3.eth.chain_id==currentnetwork['chainid'])
                chainid = currentnetwork['chainid']
                print(f"\n###################### Connect {chainid}")
                print(f"chainid :               {web3.eth.chain_id}")
                print(f"gasPrice :              {web3.eth.gasPrice}")
                print(f"generate_gas_price :    {web3.eth.generate_gas_price()}")
                print(f"syncing :               {web3.eth.syncing}")
                print(f"mining :                {web3.eth.mining}")
                print(f"block_number :          {web3.eth.block_number}")
                print(f"Locator Size :          {len(web3.eth.get_code(LocatorAddress))}")
                print(f"Locator Address :       {LocatorAddress}")
                Locator = web3.eth.contract(address=LocatorAddress, abi=LocatorJSON['abi'])

                OracleAddress = Locator.functions.location(Locator.functions.hash("Oracle").call()).call()
                print(f"Oracle Address :          {OracleAddress}")
                Oracle = web3.eth.contract(address=OracleAddress, abi=OracleJSON['abi'])

                GateAddress = Locator.functions.location(Locator.functions.hash("Gate").call()).call()
                print(f"Gate Address :          {GateAddress}")
                Gate = web3.eth.contract(address=GateAddress, abi=GateJSON['abi'])

                TokenPlaceAddress = Locator.functions.location(Locator.functions.hash("TokenPlace").call()).call()
                print(f"TokenPlace Address :          {TokenPlaceAddress}")
                TokenPlace = web3.eth.contract(address=TokenPlaceAddress, abi=TokenPlaceJSON['abi'])

                
                if not chainid in config:
                    config[chainid] = dict()
                ##config[chainid]['Block'] = web3.eth.block_number

                config[chainid]['InboundEvent'] = dict()
                config[chainid]['OutboundCompletedEvent'] = dict()
                config[chainid]['OutboundEvent'] = dict()

                config[chainid]['In'] = dict()
                config[chainid]['OutCompleted'] = dict()

                config[chainid]['Tx'] = 0
                config[chainid]['web3'] = web3
                config[chainid]['Locator'] = Locator
                config[chainid]['Oracle'] = Oracle
                config[chainid]['Gate'] = Gate
                config[chainid]['TokenPlace'] = TokenPlace
                ##config[chainid]['InboundFilter'] = Gate.events.Inbound.createFilter(fromBlock=config[chainid]['Block'])
                ##config[chainid]['OutboundFilter'] = Gate.events.Outbound.createFilter(fromBlock=config[chainid]['Block'])
                ##config[chainid]['OutboundCompletedFilter'] = Gate.events.OutboundCompleted.createFilter(fromBlock=config[chainid]['Block'])
            except KeyboardInterrupt:
                raise
            finally:
                pass


if RunChainValidator:
    for chainid in config:
        web3 = config[chainid]['web3']
        Oracle = config[chainid]['Oracle'] 

        block = web3.eth.get_block('latest')
        print(block)
        exit(0)
        ##BlockTruth(web3conn,oracle,blocknumber):
        if web3.eth.block_number > 15:
            BlockTruth(web3,Oracle,web3.eth.block_number-15)

for chainid in config:
    try:
        web3 = config[chainid]['web3']
        Gate = config[chainid]['Gate'] 

        base = Gate.functions.base().call()
        nonce = Gate.functions.nonce().call()
        print(f"Processing Init {chainid} {web3.eth.block_number} base={base} nonce={nonce}")

        for id in range(base, nonce):
            filter = Gate.events.Outbound.createFilter(fromBlock=0, argument_filters={'nonce':id})
            events = web3.eth.get_filter_logs(filter.filter_id)
            event = events[0]
            receipt = web3.eth.get_transaction_receipt(event['transactionHash'])
            devents = Gate.events.Outbound().processReceipt(receipt) 
            for devent in devents:
                devent = devent['args']
                assert(devent)
                if devent['nonce']==id:           
                    if devent['chainId'] in config:
                        config[chainid]['OutboundEvent'][id] = devent
                        print(f"Outbound Event {devent['chainId']}/{devent['nonce']} type={devent['message'][0]} ")
                    break
    except : ##KeyboardInterrupt:
        raise
    finally:
        pass
                

print(f"\nInit Completed")


## Workflow         FromChain -> FromChain Msg(nonce) -> ToChain
##
## 1        [FromChain] Outbound event -> [FromChain]['OutboundEvent'][nonce]
## 2        [FromChain]['OutboundEvent'][nonce] -> [ToChain]['In'][FromChain/nonce]
## 3        [ToChain]['In'][FromChain/nonce] -> ToChain.In()
## 4        [ToChain] Inbound event -> [ToChain]['InboundEvent'][FromChain/nonce]
## 5        [ToChain]['InboundEvent'][FromChain/nonce] -> [FromChain]['OutCompleted'][nonce]
## 6        [FromChain]['OutCompleted'][nonce] -> FromChain.OutCompleted()
## 7        [FromChain] OutboundCompleted event -> [FromChain]['OutboundCompletedEvent'][nonce]
## 8        [FromChain]['OutboundCompletedEvent'][nonce] -> 
##                          delete [FromChain]['OutboundEvent'][nonce]
##                          delete [ToChain]['In'][FromChain/nonce]
##                          delete [ToChain]['InboundEvent'][FromChain/nonce]
##                          delete [FromChain]['OutCompleted'][nonce]
##                          delete [FromChain]['OutboundCompletedEvent'][nonce]
##                          End

while True:
    for chainid in config:
        try:
            web3 = config[chainid]['web3']

            ##if config[chainid]['Block'] == web3.eth.block_number:
            ##    continue
            ##prev_block_number = config[chainid]['Block']
            ##config[chainid]['Block'] = web3.eth.block_number


            Gate = config[chainid]['Gate'] 
            ##outboundfilter = config[chainid]['OutboundFilter']
            ##inboundfilter = config[chainid]['InboundFilter']
            ##outboundcompletedfilter = config[chainid]['OutboundCompletedFilter']

            ## event Outbound(uint56 indexed chainId, uint256 indexed nonce, Message message);
            events = [] ##outboundfilter.get_new_entries()
            if len(events):
                print(f"\nProcessing Outbound event {chainid} {web3.eth.block_number}")
                for fullevent in events:
                    devent = fullevent['args']
                    if devent['chainId'] in config:
                        config[chainid]['OutboundEvent'][devent['nonce']] = devent
                        print(f"Outbound Event {devent['nonce']}->{devent['chainId']} src={devent['src']} type={devent['message'][0]} len={len(devent['message'][1])}")

            ## event OutboundCompleted(uint256 indexed nonce,bool result, bytes returned);
            events = [] ##outboundcompletedfilter.get_new_entries()
            if len(events):
                print(f"\nProcessing OutboundCompleted event {chainid} {web3.eth.block_number}")
                for fullevent in events:
                    devent = fullevent['args']
                    config[chainid]['OutboundCompletedEvent'][devent['nonce']] = devent
                    print(f"OutboundCompleted Event {devent['nonce']} result={devent['result']} len_returned={len(devent['returned'])} returned={devent['returned']}")

            ## event Inbound(uint56 indexed chainId, uint256 indexed nonce, Message message, bool result, bytes returned);
            events = [] ##inboundfilter.get_new_entries()
            if len(events):
                print(f"\nProcessing Inbound event {chainid} {web3.eth.block_number}")
                for fullevent in events:
                    devent = fullevent['args']
                    if devent['chainId'] in config:
                        key = str(devent['chainId']) + "/" + str(devent['nonce'])
                        config[chainid]['InboundEvent'][key] = devent
                        print(f"Inbound Event {key} type={devent['remainer'][0]} src={devent['src']} len_remainer={len(devent['remainer'][1])} result={devent['result']} len_returned={len(devent['returned'])}")

            if config[chainid]['Tx'] != 0:
                try :
                    r = web3.eth.get_transaction_receipt(config[chainid]['Tx'])
                    if r.blockNumber == None:
                        continue
                    print(f"==> Tx completed {chainid} {web3.eth.block_number} gasUsed={r['gasUsed']}")
                    config[chainid]['Tx'] = 0


                except TransactionNotFound as e:
                    print(f"==> Tx running .... {chainid} {web3.eth.block_number}")
                    continue
                except:
                    raise

            ## ['OutboundEvent'][nonce] (uint56 indexed chainId, uint256 indexed nonce, Message message)
            if len(config[chainid]['OutboundEvent']):
                ##print(f"\nDispatching OutBound Event {chainid} {web3.eth.block_number}")
                for nonce in config[chainid]['OutboundEvent']:
                    devent = config[chainid]['OutboundEvent'][nonce]

                    assert(devent['chainId'] in config)

                    if False: ##not devent['chainId'] in config:
                        ## Chain doesnt exist .... sending back a cancel event
                        continue
                        key = f"{chainid}/{devent['nonce']}"
                        config[chainid]['InboundEvent'][key] = dict()
                        config[chainid]['InboundEvent'][key]['chainId'] = chainid
                        config[chainid]['InboundEvent'][key]['nonce'] = devent['nonce']
                        config[chainid]['InboundEvent'][key]['message'] = devent['message']
                        config[chainid]['InboundEvent'][key]['result'] = False
                        config[chainid]['InboundEvent'][key]['returned'] = ""
                        print(f"Error Chain {devent['chainId']} doesnt exist\n\t Error Inbound Event {key} type={devent['message'][0]} len={len(devent['message'][1])} result={devent['result']} len_returned={len(devent['returned'])}")

                        continue
                    key = str(chainid) + "/" + str(devent['nonce'])
                    if not key in config[devent['chainId']]['In']:
                        config[devent['chainId']]['In'][key]= {'chainId': chainid ,'nonce': devent['nonce'],'src': devent['src'], 'message': devent['message']}
                        print(f"\tOut to In {key}->{devent['chainId']} src={devent['src']} type={devent['message'][0]} len={len(devent['message'][1])}") 

            ## event Inbound(uint56 indexed chainId, uint256 indexed nonce, Message message, bool result, bytes returned);
            if len(config[chainid]['InboundEvent']):
                ##print(f"\nDispatching OutBound Event {chainid} {web3.eth.block_number}")
                for key in config[chainid]['InboundEvent']:
                    devent = config[chainid]['InboundEvent'][key]

                    assert(devent['chainId'] in config)

                    if not devent['nonce'] in config[devent['chainId']]['OutCompleted']:
                        config[devent['chainId']]['OutCompleted'][ devent['nonce']]= {'chainId': chainid ,'nonce': devent['nonce'],'src': devent['src'], 'remainer': devent['remainer'], 'result': devent['result'], 'returned': devent['returned']}
                        print(f"\tInbound to OutCompleted {key} src={devent['src']} type={devent['remainer'][0]} len_remainer={len(devent['remainer'][1])} result={devent['result']} len_returned={len(devent['returned'])}") 


            ## event OutboundCompleted(uint256 indexed nonce,bool result, bytes returned);
            if len(config[chainid]['OutboundCompletedEvent']):
                ##print(f"\nDispatching OutBound Event {chainid} {web3.eth.block_number} len={len(config[chainid]['OutboundCompletedEvent'])}")
                for nonce in config[chainid]['OutboundCompletedEvent']:
                    devent = config[chainid]['OutboundEvent'].pop(nonce)
                    key = str(chainid) + "/" + str(nonce)
                    assert(config[devent['chainId']]['In'].pop(key)!=KeyError)
                    assert(config[devent['chainId']]['InboundEvent'].pop(key)!=KeyError)
                    assert(config[chainid]['OutCompleted'].pop(nonce)!=KeyError)
                    print(f"\tEnded {chainid}->{nonce}->{devent['chainId']}") 
                config[chainid]['OutboundCompletedEvent'] = dict()
                ##print(config)

            ## ['In'][chainId/nonce] (uint56 indexed chainId, uint256 indexed nonce, Message message)
            if len(config[chainid]['In']):
                inlist = []
                for key in config[chainid]['In']:
                    devent = config[chainid]['In'][key]
                    if Gate.functions.validIn(devent['chainId'],devent['nonce']).call():
                        item = [devent['chainId'],devent['nonce'],devent['src'],devent['message']]
                        print(f"\tIn to process {key} src={devent['src']} type={devent['message'][0]} len={len(devent['message'][1])}")
                        inlist.append(item)
                    else:
                        print(f"\tIn allready processed {key} type={devent['message'][0]} len={len(devent['message'][1])}")

                        filter = Gate.events.Inbound.createFilter(fromBlock=0, argument_filters={'chainId':devent['chainId'],'nonce':devent['nonce']}) ##
                        filterevents = web3.eth.get_filter_logs(filter.filter_id)
                        assert(len(filterevents)==1)
                        filterevent = filterevents[0]
                        filtereventreceipt = web3.eth.get_transaction_receipt(filterevent['transactionHash'])
                        ##print(f"filtereventreceipt = {filtereventreceipt}")
                        filteredevents = Gate.events.Inbound().processReceipt(filtereventreceipt)                    
                        ##print(f"filteredevents = {filteredevents}")
                        ##exit(0)
                        for filteredevent in filteredevents:
                            filteredevent = filteredevent['args']
                            if filteredevent['chainId']==devent['chainId'] and filteredevent['nonce']==devent['nonce']:
                                key = str(filteredevent['chainId']) + "/" + str(filteredevent['nonce'])
                                if not key in config[chainid]['InboundEvent']:
                                    config[chainid]['InboundEvent'][key] = filteredevent
                                    print(f"Inbound Event (reinjected) {key} src={filteredevent['src']} type={filteredevent['remainer'][0]} len_remainer={len(filteredevent['remainer'][1])} result={filteredevent['result']} len_returned={len(filteredevent['returned'])}")
                                break
                if len(inlist) > 0:
                    print(f"\nProcessing In {chainid} {web3.eth.block_number}")

                    ##tokeninfo = []
                    ##for msg in inlist:
                    ##    getTokenInfo(config,chainid,msg[3],tokeninfo)

                    ##exit(0)
                    config[chainid]['Tx'] = In(web3,Gate,inlist)
                    continue

            if len(config[chainid]['OutCompleted']):
                outcompletedlist = []
                for key in config[chainid]['OutCompleted']:
                    devent = config[chainid]['OutCompleted'][key]
                    if Gate.functions.validOut(devent['nonce']).call():
                        item = [devent['nonce'],devent['src'],devent['remainer'],devent['result'],devent['returned']]
                        print(f"\tOutCompleted to process {key} src={devent['src']} type={devent['remainer'][0]} len_remainer={len(devent['remainer'][1])} result={devent['result']} len_returned={len(devent['returned'])}")
                        outcompletedlist.append(item)
                    else:
                        ##print(f"\tIn allready processed {key} type={devent['message'][0]} len={len(devent['message'][1])}")
                        if not devent['nonce'] in config[chainid]['OutboundCompletedEvent']:
                            config[chainid]['OutboundCompletedEvent'][devent['nonce']] = {'nonce': devent['nonce'], 'result': devent['result'], 'returned': devent['returned'], 'remainer': devent['remainer']}
                            print(f"OutboundCompleted Event (reinjected) {devent['nonce']} result={devent['result']} len_returned={len(devent['returned'])} len_remainer={len(devent['remainer'])}")
                if len(outcompletedlist) > 0:
                    print(f"\nProcessing OutCompleted {chainid} {web3.eth.block_number}")
                    config[chainid]['Tx'] = OutCompleted(web3,Gate,outcompletedlist)
                    continue

        except KeyboardInterrupt:
            raise
        finally:
            pass
    sys.stdout.flush()   
    

