//import MarketView from "../chain-info/contracts/MarketView.json";
import { Falsy } from "../model/types";
import { ERC20Interface, useContractCall, useContractCalls, useContractFunction } from "@usedapp/core";
import { BigNumber } from "@ethersproject/bignumber";
import { constants, utils } from "ethers";
import { useEthers } from "@usedapp/core";
import networkMapping from "../chain-info/deployments/map.json";
//import { useMarketViewAddress } from ".";
import { Contract } from "@ethersproject/contracts";
import React, { useState, useEffect } from "react";
import { StringLiteral } from "typescript";

/*
function getBuyOrders(address left_, address right_)
        external
        view
        virtual
        returns (OrderInfoPublic[] memory res_)
        */

//export function useMarketViewGetSellOrders(left: string, right: string) /*: BigNumber | undefined*/ {
/*    const mvAddress = useMarketViewAddress();
    const [ret] =
        useContractCall(
            mvAddress && {
                abi: new utils.Interface(MarketView.abi),
                address: mvAddress,
                method: "getSellOrders",
                args: [left, right],
            }
        ) ?? [];
    console.log(ret);
    return ret;
}*/
