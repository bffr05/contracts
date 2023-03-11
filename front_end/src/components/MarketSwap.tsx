import React, { useState, useEffect } from "react";
import { useEthers, useEtherBalance, useNotifications, Token, Currency, NativeCurrency } from "@usedapp/core";
import { TokenType, useStackListByType, useStackImage, useStackImages, useErc20Balances, useErc20Names, useErc20Symbols, useErc20Decimals, useOVFromTo,useOVGetOrders } from "../hooks";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Input from "@mui/material/Input";
import Slider from "@mui/material/Slider";
import TextField from "@mui/material/TextField";
import { BigNumber } from "@ethersproject/bignumber";
import { formatUnits, formatEther } from "@ethersproject/units";
import Snackbar from "@mui/material/Snackbar";
import Alert from "@mui/material/Alert";
import { utils } from "ethers";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemSecondaryAction from "@mui/material/ListItemSecondaryAction";
import ListItemText from "@mui/material/ListItemText";
import Divider from "@mui/material/Divider";
import TabContext from "@mui/lab/TabContext";
import TabList from "@mui/lab/TabList";
import TabPanel from "@mui/lab/TabPanel";
import Grid from "@mui/material/Grid";
import InputLabel from "@mui/material/InputLabel";
import FormControl from "@mui/material/FormControl";
import InputAdornment from "@mui/material/InputAdornment";
import { erc20LocalList } from "./Token";
import { ethers } from "ethers";
import IconButton from "@mui/material/IconButton";
import AddBoxIcon from "@mui/icons-material/AddBox";

import Select, { SelectChangeEvent } from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";
import SwapVertIcon from "@mui/icons-material/SwapVert";
import NativeSelect from "@mui/material/NativeSelect";
import Autocomplete from "@mui/material/Autocomplete";
import { DataGrid } from "@mui/x-data-grid";
import web3 from 'web3';

export interface MarketSwapProps {}

const columns = [
    { field: "type", headerName: "Type", width: 90 },
    {
        field: "quote",
        headerName: "Quote",
        width: 150,
        editable: true,
    },
    {
        field: "qty",
        headerName: "Quantity",
        width: 150,
        editable: true,
    },
];

export const MarketSwap = ({}: MarketSwapProps) => {
    const formatBalance = (balance: BigNumber | undefined) => parseFloat(formatEther(balance ?? BigNumber.from("0")));
    const erc20List: string[] = useStackListByType(TokenType.Erc20);
    let list: string[] = erc20LocalList.concat(erc20List.filter((item) => !erc20LocalList.includes(item)));
    const erc20Images = useStackImages(list);
    const erc20Names = useErc20Names(list);
    const erc20Symbols = useErc20Symbols(list);
    const erc20Decimals = useErc20Decimals(list);
    const offsetERC20 = 1000000;

    const curAddress = "0x0000000000000000000000000000000000000000";
    const curImage = useStackImage(curAddress);
    const curName = "Ethereum";
    const curSymbol = "ETH";
    const curDecimal = 18;

    const tagCurrency = "Currency";
    const tagErc20 = "Erc20";

    const optionCur = { address: curAddress, name: curName, symbol: curSymbol, type: tagCurrency, image: curImage, key: 0 };

    const [swapfrom, setSwapFrom] = React.useState<{ address: string; name: string; symbol: string; type: string; image: string; key: number } | null>(optionCur);
    const [swapto, setSwapTo] = React.useState<{ address: string; name: string; symbol: string; type: string; image: string; key: number } | null>(null);
    const [amountfrom, setAmountFrom] = useState<String>();
    const [amountto, setAmountTo] = useState<String>();


    let optionlist = [optionCur];
    //console.log(erc20Symbols);
    const optionERC20 =
        list &&
        erc20Symbols[0] &&
        list.map((token, idx) => {
            return { address: list[idx], name: String(erc20Names[idx]![0]), symbol: String(erc20Symbols[idx]![0]), type: tagErc20, image: String(erc20Images[idx]![0]), key: offsetERC20 + idx };
        });
    if (optionERC20) optionlist = optionlist.concat(optionERC20);

    const fromto: number[] = useOVFromTo(swapto?.address!, swapfrom?.address!);
    const orders = useOVGetOrders(fromto!);
    /*const helperFrom = () => {
        if (swapfrom!.type === TokenType.Cur.toString()) return "Cur";
        else if (swapfrom!.type === TokenType.Erc20.toString()) {
            return "ERC20";
        }
        return " ";
    };*/

    /*const Orders = BigNumber.from(swapfrom!.address).lte(BigNumber.from(swapto!.address)) ? useMarketViewGetSellOrders(swapto!.address,swapfrom!.address) : useMarketViewGetBuyOrders(swapfrom!.address,swapto!.address);
     */
    
    const rows = orders ? orders.map((order) => {
        return {
            id: order.id,
            type: "Direct",
            quote: formatBalance(order.quote),
            qty: formatBalance(order.qty.sub(order.qtydone))
        };
    }):[];
    /*[
        { id: 1, lastName: "Snow", firstName: "Jon", age: 35 },
        { id: 2, lastName: "Lannister", firstName: "Cersei", age: 42 },
        { id: 3, lastName: "Lannister", firstName: "Jaime", age: 45 },
        { id: 4, lastName: "Stark", firstName: "Arya", age: 16 },
        { id: 5, lastName: "Targaryen", firstName: "Daenerys", age: null },
        { id: 6, lastName: "Melisandre", firstName: null, age: 150 },
        { id: 7, lastName: "Clifford", firstName: "Ferrara", age: 44 },
        { id: 8, lastName: "Frances", firstName: "Rossini", age: 36 },
        { id: 9, lastName: "Roxie", firstName: "Harvey", age: 65 },
    ];*/
    //const [swaptosize, setSwapToSize] = React.useState('100%');
    return (
        <>
            <Box sx={{ flexGrow: 1 }}>
                <Grid container spacing={2}>
                    <Grid item xs={2}></Grid>
                    <Grid item xs={5}>
                        <Autocomplete
                            value={swapfrom}
                            onChange={(event, value) => {
                                if (value) {
                                    setSwapFrom(value);
                                    if (value!.key == swapto!.key) setSwapTo(null);
                                }
                            }}
                            disablePortal
                            options={optionlist}
                            getOptionLabel={(option) => option.symbol}
                            autoHighlight
                            groupBy={(option) => option.type}
                            isOptionEqualToValue={(option, value) => option.key === value.key}
                            renderInput={(params) => (
                                <div>
                                    {" "}
                                    <TextField {...params} label="From" />
                                </div>
                            )}
                            onOpen={(event) => {
                                //setSwapToSize('150%');
                            }}
                            onClose={(event) => {
                                //setSwapToSize('100%');
                            }}
                            renderOption={(props, option) => (
                                <Box component="li" sx={{ "& > img": { mr: 2, flexShrink: 0 } }} {...props}>
                                    <img loading="lazy" width="20" src={option.image} />
                                    {option.symbol} - {option.name} ({option.type})
                                </Box>
                            )}
                            //sx={{ width: swaptosize }}
                        />
                    </Grid>

                    <Grid item xs={3}>
                        <TextField
                            value={amountfrom}
                            fullWidth
                            label="Amount"
                            InputProps={{
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                            color="secondary"
                            disabled={false}
                            //helperText={""helperFrom""}
                        />
                    </Grid>
                    <Grid item xs={1}></Grid>
                </Grid>
                <Grid container spacing={2}>
                    <Grid item xs={4} />
                    <Grid item xs={2} sx={{ width: 1 }}>
                        <IconButton
                            color="primary"
                            onClick={() => {
                                setSwapFrom(swapto);
                                setSwapTo(swapfrom);
                                setAmountFrom(amountto);
                                setAmountTo(amountfrom);
                            }}
                        >
                            <SwapVertIcon />
                        </IconButton>
                    </Grid>
                </Grid>
                <Grid container spacing={2}>
                    <Grid item xs={2}></Grid>
                    <Grid item xs={5}>
                        <Autocomplete
                            value={swapto}
                            onChange={(event, value) => {
                                setSwapTo(value);
                            }}
                            disablePortal
                            options={optionlist}
                            getOptionLabel={(option) => option.symbol}
                            autoHighlight
                            groupBy={(option) => option.type}
                            isOptionEqualToValue={(option, value) => option.key === value.key}
                            renderInput={(params) => (
                                <div>
                                    {" "}
                                    <TextField {...params} label="To" />
                                </div>
                            )}
                            onOpen={(event) => {
                                //setSwapToSize('150%');
                            }}
                            onClose={(event) => {
                                //setSwapToSize('100%');
                            }}
                            renderOption={(props, option) => (
                                <Box component="li" sx={{ "& > img": { mr: 2, flexShrink: 0 } }} {...props}>
                                    <img loading="lazy" width="20" src={option.image} />
                                    {option.symbol} - {option.name} ({option.type})
                                </Box>
                            )}
                            filterOptions={(options, state) => {
                                return options.filter(({ key }) => key != swapfrom!.key);
                            }}
                            //sx={{ width: swaptosize }}
                        />
                    </Grid>

                    <Grid item xs={3}>
                        <TextField
                            fullWidth
                            label="Amount"
                            InputProps={{
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                            color="secondary"
                            disabled={false}
                            //helperText="Helper"
                        />
                    </Grid>
                    <Grid item xs={1}></Grid>
                </Grid>

                <Grid container spacing={2}>
                    <Grid item xs={1}></Grid>
                    <Grid item xs={10}>
                        <div style={{ height: 400, width: "100%" }}>
                            <DataGrid rows={rows} columns={columns} pageSize={5} rowsPerPageOptions={[5]} disableSelectionOnClick />
                        </div>
                    </Grid>
                    <Grid item xs={1}></Grid>
                </Grid>
            </Box>
        </>
    );
};
