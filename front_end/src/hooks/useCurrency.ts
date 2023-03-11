//import Currency from "../chain-info/contracts/Currency.json"
import { Falsy } from '../model/types'
import { useContractCall,useContractFunction } from "@usedapp/core"
import { BigNumber } from '@ethersproject/bignumber'
import { constants, utils } from "ethers"
import { useEthers } from "@usedapp/core"
import   networkMapping from "../chain-info/deployments/map.json"
import { useStackAddress } from "."
import { Contract } from "@ethersproject/contracts"

/*
export function useCurIsModeTest(): boolean {
  const curAddress = useStackAddress()
  const [test] =
    useContractCall(
        {
          abi: new utils.Interface(Currency.abi),
          address: curAddress,
          method: 'MODETEST',
          args: [],
        }
    )?? [];
  return test;
}


export function useCurBalance(): BigNumber | undefined {
  const currencyAddress = useStackAddress()
  const { account } = useEthers();
  const [balance] =
    useContractCall(
      {
          abi: new utils.Interface(Currency.abi),
          address: currencyAddress,
          method: 'available',
          args: [account],
        }
    ) ?? []
  return balance
}

export function useCurUnstake() {

  const stackAddress = useStackAddress();
  const stackContract = new Contract(stackAddress, new utils.Interface(Currency.abi));

  const { send: unstakeSend, state: unstakeState } =
  useContractFunction(stackContract, "unstake", {
      transactionName: "unstake",
  });
  const unstake = (amount: string) => {
      console.log("unstake=",amount);
      unstakeState.status = "Mining";

      return unstakeSend(amount)
  };

  // stake
  return { unstake, unstakeState };
}
export function useCurTestUnstake() {

  const stackAddress = useStackAddress();
  const stackContract = new Contract(stackAddress, new utils.Interface(Currency.abi));

  const { send: testUnstakeSend, state: testUnstakeState } =
  useContractFunction(stackContract, "unstake", {
      transactionName: "testunstake",
  });
  const testUnstake = (amount: string) => {
      testUnstakeState.status = "Mining";
      return testUnstakeSend(amount)
  };

  // stake
  return { testUnstake, testUnstakeState };
}
export function useCurTestStake() {

  const stackAddress = useStackAddress();
  const stackContract = new Contract(stackAddress, new utils.Interface(Currency.abi));

  const { send: testStakeSend, state: testStakeState } =
  useContractFunction(stackContract, "testStake", {
      transactionName: "teststake",
  });
  const testStake = (amount: string) => {
      testStakeState.status = "Mining";
      return testStakeSend(amount)
  };

  // stake
  return { testStake, testStakeState };
}
export function useCurStake() {

  const { account } = useEthers();
  const stackAddress = useStackAddress();
  const stackContract = new Contract(stackAddress, new utils.Interface(Currency.abi));

  const { send: stakeSend, state: stakeState } =
  useContractFunction(stackContract, "stake", {
      transactionName: "stake",
  });
  const stake = (amount: string) => {
      stakeState.status = "Mining";
      return stakeSend({value: amount})
  };

  // stake
  return { stake, stakeState };
}
/*
export const useStake = () => {
  const currencyAddress = useCurrencyAddress()
  const currencyContract = new Contract(currencyAddress, new utils.Interface(Currency.abi))

  const { send: request, state } = useContractFunction(currencyContract, "stake", {transactionName: "stake"})

  return { request, state }
}

export const useUnstake = () => {
  const currencyAddress = useCurrencyAddress()
  const currencyContract = new Contract(currencyAddress, new utils.Interface(Currency.abi))

  const { send: request, state } = useContractFunction(currencyContract, "unstake", {transactionName: "unstake"})

  return { request, state }
}
*/