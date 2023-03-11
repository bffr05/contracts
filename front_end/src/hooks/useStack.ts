import Stack from "../chain-info/contracts/Stack.json";
import { Falsy } from "../model/types";
import { ERC20Interface, useContractCall, useContractCalls, useContractFunction } from "@usedapp/core";
import { BigNumber } from "@ethersproject/bignumber";
import { constants, utils } from "ethers";
import { useEthers } from "@usedapp/core";
import networkMapping from "../chain-info/deployments/map.json";
import { useStackAddress } from ".";
import { Contract } from "@ethersproject/contracts";
import React, { useState, useEffect } from "react";
import { StringLiteral } from "typescript";

export enum TokenType {
    Unknown,
    Cur,
    Erc20,
    Max,
}

export function useStackList(): string[] {
    const stackAddress = useStackAddress();
    const [list] =
        useContractCall(
            stackAddress && {
                abi: new utils.Interface(Stack.abi),
                address: stackAddress,
                method: "list",
                args: [],
            }
        ) ?? [];
    return list ? list : [];
}
export function useStackListByType(type: TokenType): string[] {
    const stackAddress = useStackAddress();
    const [list] =
        useContractCall(
            stackAddress && {
                abi: new utils.Interface(Stack.abi),
                address: stackAddress,
                method: "listByType",
                args: [type],
            }
        ) ?? [];
    return list ? list : [];
}
export function useStackImages(tokenlist: string[]) {
    const stackAddress = useStackAddress();
    const list =
        useContractCalls(
            tokenlist
                ? tokenlist.map((token: string) => ({
                      abi: new utils.Interface(Stack.abi),
                      address: stackAddress,
                      method: "image",
                      args: [token],
                  }))
                : []
        ) ?? [];
    return list ? list : [];
}
export function useStackBalance(token: string): BigNumber | undefined {
    const stackAddress = useStackAddress();
    const { account } = useEthers();
    const [ret] =
        useContractCall(
            token && {
                abi: new utils.Interface(Stack.abi),
                address: stackAddress,
                method: "available",
                args: [token, account],
            }
        ) ?? [];
    return ret;
}

export function useStackImage(token: string) {
    const stackAddress = useStackAddress();
    const [list] =
        useContractCall(
            token && {
                abi: new utils.Interface(Stack.abi),
                address: stackAddress,
                method: "image",
                args: [token],
            }
        ) ?? [];
    return list;
}
export function useStackGetType(token: string) {
    const stackAddress = useStackAddress();
    const [list] =
        useContractCall(
            token && {
                abi: new utils.Interface(Stack.abi),
                address: stackAddress,
                method: "getType",
                args: [token],
            }
        ) ?? [];
    return list;
}
/*export function useCurStake() {

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
  }*/
export function useStackStake(token: string) {
    const stackAddress = useStackAddress();
    const type = useStackGetType(token);
    const stackContract = new Contract(stackAddress, new utils.Interface(Stack.abi));
    const erc20Contract = new Contract(token, ERC20Interface);

    const [amountToStake, setAmountToStake] = useState("0");

    // approve
    const { send: approveErc20Send, state: approveState } = useContractFunction(erc20Contract, "approve", {
        transactionName: "approve",
    });
    // stake
    const { send: stakeSend, state: stakeState } = useContractFunction(stackContract, "stake", {
        transactionName: "stake",
    });
    const stake = (amount: string) => {
        if (type == TokenType.Cur) {
            stakeState.status = "Mining";
            return stakeSend(token, 0, { value: amount });
        } else if (type == TokenType.Erc20) {
            setAmountToStake(amount);
            approveState.status = "Mining";
            stakeState.status = "None";
            return approveErc20Send(stackAddress, amount);
        }
        stakeState.status = "Exception";
    };

    //useEffect
    useEffect(() => {
        if (approveState.status === "Success" && stakeState.status === "None") {
            stakeState.status = "Mining";
            stakeSend(token, amountToStake);
        }
    }, [approveState]);
    return { stake, approveState, stakeState };
}
export function useStackUnstake(token: string) {
    const stackAddress = useStackAddress();
    const stackContract = new Contract(stackAddress, new utils.Interface(Stack.abi));

    const { send: unstakeSend, state: unstakeState } = useContractFunction(stackContract, "unstake", {
        transactionName: "unstake",
    });
    const unstake = (amount: string) => {
        console.log("unstake=", amount);
        unstakeState.status = "Mining";

        return unstakeSend(token, amount);
    };

    // stake
    return { unstake, unstakeState };
}
export function useStackTestUnstake(token: string) {
    const { account } = useEthers();
    const stackAddress = useStackAddress();
    const stackContract = new Contract(stackAddress, new utils.Interface(Stack.abi));

    const { send: testUnstakeSend, state: testUnstakeState } = useContractFunction(stackContract, "testUnstake", {
        transactionName: "testunstake",
    });
    const testUnstake = (amount: string) => {
        testUnstakeState.status = "Mining";
        return testUnstakeSend(token, account, amount);
    };

    // stake
    return { testUnstake, testUnstakeState };
}
export function useStackTestStake(token: string) {
    const { account } = useEthers();
    const stackAddress = useStackAddress();
    const stackContract = new Contract(stackAddress, new utils.Interface(Stack.abi));

    const { send: testStakeSend, state: testStakeState } = useContractFunction(stackContract, "testStake", {
        transactionName: "teststake",
    });
    const testStake = (amount: string) => {
        testStakeState.status = "Mining";
        return testStakeSend(token, account, amount);
    };

    // stake
    return { testStake, testStakeState };
}

export function useStackIsModeTest(): boolean {
    const stackAddress = useStackAddress();
    const [test] =
        useContractCall({
            abi: new utils.Interface(Stack.abi),
            address: stackAddress,
            method: "MODETEST",
            args: [],
        }) ?? [];
    return test;
}
