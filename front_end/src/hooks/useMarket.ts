//import Market from "../chain-info/contracts/Market.json"
import { Falsy } from '../model/types'
import { ERC20Interface, useContractCall,useContractCalls,useContractFunction } from "@usedapp/core"
import { BigNumber } from '@ethersproject/bignumber'
import { constants, utils } from "ethers"
import { useEthers } from "@usedapp/core"
import   networkMapping from "../chain-info/deployments/map.json"
//import { useMarketAddress } from "."
import { Contract } from "@ethersproject/contracts"
import React, { useState, useEffect } from "react";
import { StringLiteral } from "typescript"

/*
export function useMarketIsModeTest(): boolean {
    const Address = useMarketAddress()
    const [test] =
      useContractCall(
          {
            abi: new utils.Interface(Market.abi),
            address: Address,
            method: 'MODETEST',
            args: [],
          }
      )?? [];
    return test;
  }
*/