

import { useEthers } from "@usedapp/core"
import networkMapping from "../chain-info/deployments/map.json"
import { constants, utils } from "ethers"
import tok from "./dapp.png"
/*
//import { useTokenFarmTokens,useTokenFarmInternalToken,useTokenFarmTokensList,useTokenFarmTokensIn } from "./hooks"
//import { ERC20name,ERC20symbol,ERC20decimal } from "./hooks/useERC20"

export type Token = {
    image: string
    address: string
    name: string
    decimal: number
    owner: boolean
}
export const Tokens : Array<Token> = []
*/

export const erc20LocalList: string[] = [];
