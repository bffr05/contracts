import { Falsy } from "../model/types";
import { useContractCall } from "@usedapp/core";
import { BigNumber } from "@ethersproject/bignumber";
import { constants, utils } from "ethers";
import { useEthers } from "@usedapp/core";
import networkMapping from "../chain-info/deployments/map.json";

export function useStackAddress(): string {
    const { chainId } = useEthers();
    const numChainId: string = "1337";
    return numChainId ? networkMapping["1337"]["Stack"][0] : constants.AddressZero;
}
export function useOrderAddress(): string {
    const { chainId } = useEthers();
    const numChainId: number = chainId!;
    return chainId ? networkMapping["1337"]["Order"][0] : constants.AddressZero;
}
export function useOrderStorageAddress(): string {
    const { chainId } = useEthers();
    const numChainId: number = chainId!;
    return chainId ? networkMapping["1337"]["OrderStorage"][0] : constants.AddressZero;
}
export function useOrderViewAddress(): string {
    const { chainId } = useEthers();
    const numChainId: number = chainId!;
    return chainId ? networkMapping["1337"]["OrderView"][0] : constants.AddressZero;
}

/*
export function useMarketAddress(): string {
  const { chainId } = useEthers();
  const numChainId: number = chainId!;
  return chainId ? networkMapping["1337"]["Market"][0] : constants.AddressZero;
}

export function useMarketViewAddress(): string {
  const { chainId } = useEthers();
  const numChainId: number = chainId!;
  return chainId ? networkMapping["1337"]["MarketView"][0] : constants.AddressZero;
}*/
