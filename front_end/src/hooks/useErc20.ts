import { Falsy } from '../model/types'
import { ERC20Interface, useContractCall,useContractCalls,useContractFunction } from "@usedapp/core"
import { BigNumber } from '@ethersproject/bignumber'
import { constants, utils } from "ethers"
import { useEthers } from "@usedapp/core"
import   networkMapping from "../chain-info/deployments/map.json"
import { Contract } from "@ethersproject/contracts"


export function useErc20Balances(tokenlist: string[]) {
    const { account } = useEthers();
    const list =useContractCalls(
        tokenlist 
            ? tokenlist.map((token: string ) => ({
                abi: ERC20Interface,
                address: token,
                method: 'balanceOf',
                args: [account]
                }))
            : []
    ) ?? [];
    return list? list :[];
}
export function useErc20Balance(token: string): BigNumber | undefined {
    const { account } = useEthers();
    const [ret] =
      useContractCall(
        token && {
            abi: ERC20Interface,
            address: token,
            method: 'balanceOf',
            args: [account],
          }
      ) ?? [];
    return ret;
}  

export function useErc20Decimal(token: string) {
    const [list] =
      useContractCall(
        token && {
            abi: ERC20Interface,
            address: token,
            method: 'decimals',
            args: [],
          }
      ) ?? [];
    return list ? list :[];
}  
export function useErc20Name(token: string) {
    const [list] =
      useContractCall(
        token && {
            abi: ERC20Interface,
            address: token,
            method: 'name',
            args: [],
          }
      ) ?? [];
    return list ? list :[];
}  
export function useErc20Symbol(token: string) {
    const [list] =
      useContractCall(
        token && {
            abi: ERC20Interface,
            address: token,
            method: 'symbol',
            args: [],
          }
      ) ?? [];
    return list ? list :[];
}  
export function useErc20Names(tokenlist: string[]) {
    const list =useContractCalls(
    tokenlist 
        ? tokenlist.map((token: string ) => ({
            abi: ERC20Interface,
            address: token,
            method: 'name',
            args: []
            }))
        : []
    ) ?? [];
    return list? list :[];
}  
export function useErc20Decimals(tokenlist: string[]) {
    const list =useContractCalls(
    tokenlist 
        ? tokenlist.map((token: string ) => ({
            abi: ERC20Interface,
            address: token,
            method: 'decimals',
            args: []
            }))
        : []
    ) ?? [];
    return list? list :[];
}  
export function useErc20Symbols(tokenlist: string[]) {
    const list =useContractCalls(
    tokenlist 
        ? tokenlist.map((token: string ) => ({
            abi: ERC20Interface,
            address: token,
            method: 'symbol',
            args: []
            }))
        : []
    ) ?? [];
    return list? list :[];
}  

