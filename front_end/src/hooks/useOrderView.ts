import OrderView from "../chain-info/contracts/OrderView.json"
import { Falsy } from '../model/types'
import { ERC20Interface, useContractCall,useContractCalls,useContractFunction } from "@usedapp/core"
import { BigNumber } from '@ethersproject/bignumber'
import { constants, utils } from "ethers"
import { useEthers } from "@usedapp/core"
import   networkMapping from "../chain-info/deployments/map.json"
import { useOrderViewAddress,TokenType } from "."
import { Contract } from "@ethersproject/contracts"
import React, { useState, useEffect } from "react";
import { StringLiteral } from "typescript"



export function useOVFromTo(from: string,to: string): number[] {
    const orderAddress = useOrderViewAddress();
    const [list] =
        useContractCall(
            orderAddress && from && to && {
                abi: new utils.Interface(OrderView.abi),
                address: orderAddress,
                method: "fromto",
                args: [from,to],
            }
        ) ?? [];
    return list ? list : [];
}
export enum OrderState {
    Unknown,
    Cancelled,      // -> Order cancelled by user
    Reverted,       // -> Order cancelled by the machine
    Completed,      // -> Order completed
                    // -> Values under active will be deleted ASAP

    Active,         // -> Order active
    Suspended       // -> Order pending liquidities
}

export type Order = {
    account:string; // the user/account/client/customer
    from:string; 
    to:string; 

    id:number; //   // id of the order
    qty:BigNumber; // active qty
    qtydone:BigNumber; // qty bought or sold
    originalqty:BigNumber; // original qty when the order was placed (qty and quote can be ajusted)
    quote:BigNumber; // current quote
    originalquote:BigNumber; // original quote when the order was placed (qty and quote can be ajusted)
    originalbasedquote:BigNumber; // original market quote when the order was placed (qty and quote can be ajusted)
    state:OrderState; // uint8    // state of the order
    typefrom:TokenType; // uint8
    typeto:TokenType; // uint8
    options:Number; // order options    image: string

}

export function useOVGetOrder(id: number):Order {
    const orderAddress = useOrderViewAddress();
    const [list] =
        useContractCall(
            orderAddress && id && {
                abi: new utils.Interface(OrderView.abi),
                address: orderAddress,
                method: "order",
                args: [id],
            }
        ) ?? [];
    return list ? list : [];
}
export function useOVGetOrders(ids: number[]):Order[]|undefined {
    const orderAddress = useOrderViewAddress();
    const list =
        useContractCalls(
            ids
                ? ids.map((id: number) => ({
                      abi: new utils.Interface(OrderView.abi),
                      address: orderAddress,
                      method: "order",
                      args: [id],
                }))
                : []
        ) ?? [];
    return (list ? list[0] && list[0].map((item)=> ({
        account: item![0],
        from: item![1],
        to: item![2],
        id: item![3],
        qty: item![4],
        qtydone: item![5],
        originalqty: item![6],
        quote: item![7],
        originalquote: item![8],
        originalbasedquote: item![9],
        state: item![10],
        typefrom: item![11],
        typeto: item![12],
        options: item![13],})) : []);
}