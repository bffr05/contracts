import React, { useState, useEffect } from "react";
import {
  useEthers,
  useEtherBalance,
  useNotifications,
  Token,
  Currency,
  NativeCurrency
} from "@usedapp/core";
import {
  useStackList,
  useStackImages,
  useErc20Balances,
  useErc20Names,
  useErc20Symbols,
  useErc20Decimals,
} from "../hooks";
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


import Select from "@mui/material/Select";
import MenuItem from "@mui/material/MenuItem";


export interface MarketProps {}

export const Market = ({}: MarketProps) => {

    return (<>
        <Box sx={{ flexGrow: 1 }}>
            <Select fullWidth>
                <MenuItem>
                </MenuItem>
            </Select>
        </Box>
    
    
    </>);
}