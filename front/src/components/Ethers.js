import React from 'react';
import { ethers } from "ethers";
import { useWeb3React } from "@web3-react/core";
import { InjectedConnector } from "@web3-react/injected-connector";

import { useEffect, useState } from "react";
import Button from '@mui/material/Button'
import Box from '@mui/material/Box'
import TextField from '@mui/material/TextField'

export const injected = new InjectedConnector();

const Ethers = () => {

    const [hasMetamask, setHasMetamask] = useState(false);

    const [isConnected, setIsConnected] = useState(false);
    const [signer, setSigner] = useState(undefined);
    const [address, setAddress] = useState(undefined);
    const [balance, setBalance] = useState("");

    useEffect(() => {
      if (typeof window.ethereum !== "undefined") {
        setHasMetamask(true);
      }
    })

    const {
      active,
      activate,
      chainId,
      account,
      library: provider,
    } = useWeb3React();


    async function connect() {
      if (typeof window.ethereum !== "undefined") {
        try {
          await activate(injected);
          setHasMetamask(true);
        } catch (e) {
          console.log(e);
        }
      }
    }

  /*  
    async function checksigner() {
        if (signer !== undefined) {
          console.log(await signer.getAddress());
        }
          
      }
    //useEffect(checksigner())
    async function account() {
      //console.log(`account signer=${signer}`)
      if (signer !== undefined) {
        let addr =await signer.getAddress()
        setAddress(addr)
        setBalance((await signer.provider.getBalance(addr)).toString())
      }
      else {
        setAddress(undefined)
      }
    }
    useEffect(() => {account()})
    async function addr() {
      return await signer.getAddress()
    }
    async function connect() {
      if (typeof window.ethereum !== "undefined") {
        try {
          await  window.ethereum.request({ method: "eth_requestAccounts" });
          setIsConnected(true);
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          setSigner(provider.getSigner());
          //setAddress(await provider.getSigner().getAddress())
          console.log()        
        } catch (e) {
          console.log(e);
        }
      } else {
        setIsConnected(false);
      }
    }
    async function disconnect() {
      setIsConnected(false);
      setSigner(undefined);
    }
  
    return (
      <Box sx={{ display:'flex', justifyContent:'flex-end' }}>
          {
            hasMetamask ?
              isConnected ? (
                <div>
                    <TextField label={address} InputProps={{ readOnly: true }}/> 
                    <TextField label={balance} InputProps={{ readOnly: true }}/> 
                    
                    <Button variant="contained" onClick={disconnect}>
                        Disconnect
                    </Button>
                </div>
            ) : (
                <div>
                    <Button
                        color="primary"
                        variant="contained"
                        onClick={() => connect()}
                    >
                        Connect
                    </Button>

                </div>
            )
            : 
            "Please install metamask"
          }
      </Box>
  )
  */
  async function execute() {
    if (active) {
      /*const signer = provider.getSigner();
      const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
      const contract = new ethers.Contract(contractAddress, abi, signer);
      try {
        await contract.store(42);
      } catch (error) {
        console.log(error);
      }*/
    } else {
      console.log("Please install MetaMask");
    }
  }
  return (
    <div>
      {hasMetamask ? (
        active ? (
          "Connected! "
        ) : (
          <button onClick={() => connect()}>Connect</button>
        )
      ) : (
        "Please install metamask"
      )}

      {active ? <button onClick={() => execute()}>Execute</button> : ""}
    </div>
  );

  /*return (
      <div>
        {hasMetamask ? (
          isConnected ? (
            "Connected! "
          ) : (
            <button onClick={() => connect()}>Connect</button>
          )
        ) : (
          "Please install metamask"
        )}
  
        {isConnected ? <button onClick={() => execute()}>Execute</button> : ""}
      </div>
    );*/
}

export default Ethers