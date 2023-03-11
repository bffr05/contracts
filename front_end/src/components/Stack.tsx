import React, { useState, useEffect } from "react";
import { useEthers, useEtherBalance, useNotifications, Token, Currency, NativeCurrency } from "@usedapp/core";
import { TokenType,useStackList,useStackListByType, useStackImages,useStackImage, useErc20Balances, useErc20Names, useErc20Symbols, useErc20Decimals, useStackGetType } from "../hooks";
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
import { Erc20Info } from "./Erc20Info";
import { CurrencyInfo } from "./CurrencyInfo";

declare const window: any;

function addTokenMetaMask(token: string, symbol: string, decimals: number, image: string) {
    const addToken = (params: any) =>
        window.ethereum
            .request({ method: "wallet_watchAsset", params })
            .then(() => {
                //setLog("Success, Token added!")
                //setAddSuccess(true)
            })
            .catch((error: Error) => {
                //setLog("Error: ${error.message}")
                //setAddSuccess(true)
            });

    addToken({
        type: "ERC20",
        options: {
            address: token,
            symbol: symbol,
            decimals: decimals,
            image: image,
        },
    });
}

export interface StackProps {}

export const Stack = ({}: StackProps) => {
    const erc20List: string[] = useStackListByType(TokenType.Erc20);

    let list: string[] = erc20LocalList.concat(erc20List.filter((item) => !erc20LocalList.includes(item)));
    const erc20Images = useStackImages(list);
    const erc20Names = useErc20Names(list);
    const erc20Symbols = useErc20Symbols(list);
    const erc20Decimals = useErc20Decimals(list);

    const curAddress = "0x0000000000000000000000000000000000000000";
    const curImage = useStackImage(curAddress);
    const curName = "Ethereum";
    const curSymbol = "ETH";
    const curDecimal = 18;

    /*console.log("local list:", erc20LocalList);
  console.log("remote list:", erc20List);
  console.log("list:", list);
  console.log("images:", erc20Images);
  console.log("balances:", erc20Balances);
  console.log("names:", erc20Names);
  console.log("symbols:", erc20Symbols);
  console.log("decimals:", erc20Decimals);
    */
    const { notifications } = useNotifications();
    const [panel, setPanel] = useState(0);
    const [listEntry, setListEntry] = useState(0);
    const [addressAdd, setAddressAdd] = useState<string>();
    //const [refresh, setRefresh] = useState<number>();
    /*const handleAddressAddChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setAddressAdd(event.target.value);
    };*/

    const handleAddClick = () => () => {
        setPanel(2);
    };
    const handleCurrencyClick = () => () => {
        //setListEntry(value);
        setPanel(0);
        //console.log(value!);
    };
    const handleTokenClick = (value: number) => () => {
        setListEntry(value);
        setPanel(1);
        //console.log(value!);
    };
    const handleAdd = (addressAdd:string) => {
        const addr: string = ethers.utils.getAddress(addressAdd!);
        //if (!useErc20Name(addr))
        //    return;
        if (!erc20LocalList.includes(addr)) erc20LocalList.push(addr);
        //setRefresh(refresh! + 1);
        setListEntry(erc20LocalList.indexOf(addr));
        setPanel(1);
    };
    const handleAddMetaMaskClick = (value: number) => () => {
        list[value] && erc20Symbols[value] && erc20Decimals[value] && erc20Images[value] && addTokenMetaMask(list[value], erc20Symbols[value]![0], erc20Decimals[value]![0], erc20Images[value]![0]);
    };

    return (
        <>
            <Box sx={{ flexGrow: 1 }}>
                <Grid container spacing={2}>
                    <Grid item xs={2}>
                        <List>
                            <ListItem
                                disablePadding
                                onClick={() => {
                                  console.log("currency click");
                                    setPanel(0);
                                }}
                            >
                                <ListItemButton>
                                    <ListItemText primary={curName} />
                                </ListItemButton>
                            </ListItem>
                            <Divider />
                            {list &&
                                list.map((token, idx) => {
                                    return (
                                        erc20Symbols[idx] && (
                                            <ListItem
                                                key={idx}
                                                disablePadding
                                                onClick={() => {
                                                    setListEntry(idx);
                                                    setPanel(1);
                                                }}
                                                disableGutters
                                            >
                                                <ListItemButton>
                                                    <ListItemText primary={`${erc20Symbols[idx]![0]}`} />
                                                    <ListItemSecondaryAction
                                                        onClick={() => {
                                                          addTokenMetaMask(list[idx], erc20Symbols[idx]![0], erc20Decimals[idx]![0], erc20Images[idx]![0])}}
                                                    >
                                                        <IconButton>
                                                            <AddBoxIcon />
                                                        </IconButton>
                                                    </ListItemSecondaryAction>
                                                </ListItemButton>
                                            </ListItem>
                                        )
                                    );
                                })}
                            <ListItem
                                disablePadding
                                onClick={() => {
                                    setPanel(2);
                                }}
                            >
                                <ListItemButton>
                                    <ListItemText primary="Add ERC20" />
                                </ListItemButton>
                            </ListItem>
                        </List>
                    </Grid>
                    <Grid item xs={10}>
                        <TabContext value={panel.toString()}>
                            <TabPanel value="0">
                                <CurrencyInfo address={curAddress} type={TokenType.Cur} symbol={curSymbol} name={curName} decimals={curDecimal} image={curImage} />
                            </TabPanel>
                            <TabPanel value="1">
                                {erc20Symbols[listEntry] && (
                                    <Erc20Info
                                        address={list[listEntry]}
                                        type={TokenType.Erc20}
                                        symbol={erc20Symbols[listEntry]![0]}
                                        name={erc20Names[listEntry]![0]}
                                        decimals={Number(erc20Decimals[listEntry]![0])}
                                        image={erc20Images[listEntry]![0]}
                                    />
                                )}
                            </TabPanel>
                            <TabPanel value="2">
                                <Grid container spacing={2}>
                                    <Grid item xs={9}>
                                        <TextField
                                            value={addressAdd}
                                            fullWidth
                                            label="Token Address"
                                            InputProps={{
                                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                                            }}
                                            onChange={(event) => {
                                                setAddressAdd(event.target.value);
                                                
                                            }}
                                        />
                                    </Grid>
                                    <Grid item xs={3}>
                                        <Button
                                            variant="contained"
                                            onClick={() => {
                                                handleAdd(addressAdd!);
                                                
                                            }}
                                        >
                                            Add
                                        </Button>
                                    </Grid>
                                </Grid>
                            </TabPanel>
                        </TabContext>
                    </Grid>
                </Grid>
            </Box>
        </>
    );
};
