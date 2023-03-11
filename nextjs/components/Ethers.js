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
      deactivate,
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
    async function disconnect() {
      if (typeof window.ethereum !== "undefined") {
        try {
          await deactivate();
          setHasMetamask(false);
        } catch (e) {
          console.log(e);
        }
      }
    }
    
    return (
      <Box sx={{ display:'flex', justifyContent:'flex-end' }}>
          {hasMetamask ? (
              active ? (
                <div>
                    <TextField label={""} InputProps={{ readOnly: true }}/> 
                    
                    <Button variant="contained" onClick={() => disconnect()} >
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
          ) : (
            "Please install metamask"
          )
        }
      </Box>
  )
/*
    return (
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
    );
*/    
}

export default Ethers