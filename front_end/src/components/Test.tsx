import { utils } from "ethers"
//import IERC20 from "../chain-info/contracts/IERC20.json"
import { BigNumber } from '@ethersproject/bignumber'
import { useContractCall, } from "@usedapp/core"
/*
export type Falsy = false | 0 | '' | null | undefined
export function useTokenBalance(tokenAddress: string | Falsy, address: string | Falsy): BigNumber | undefined {
    const [tokenBalance] =
      useContractCall(
        address &&
          tokenAddress && {
            abi: new utils.Interface(IERC20.abi),
            address: tokenAddress,
            method: 'balanceOf',
            args: [address],
          }
      ) ?? []
    return tokenBalance
  }*/