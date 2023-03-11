import helperConfig from "../helper-config.json"
import networkMapping from "../chain-info/deployments/map.json"
import { constants, utils } from "ethers"
import brownieConfig from "../brownie-config.json"
import { makeStyles } from "@material-ui/core"

import React, { useState } from "react"
import Tab from '@mui/material/Tab';
import Box from '@mui/material/Box';
import List from '@mui/material/List';
import Button from '@mui/material/Button';
//import ListItemText from '@mui/material/ListItemText';
import TabContext from '@mui/lab/TabContext';
import TabList from '@mui/lab/TabList';
import TabPanel from '@mui/lab/TabPanel';
import { Stack } from "./Stack"
import { Market } from "./Market"
import { MarketSwap } from "./MarketSwap"


const useStyles = makeStyles((theme) => ({

}))

export const Main = () => {
    const classes = useStyles()

    const [value, setValue] = React.useState(1);

    const handleChange = (event: React.ChangeEvent<{}>, newValue: string) => {
        setValue(parseInt(newValue))
    }
//<h2 className={classes.title}>Dapp Token App</h2>
        
    return (<>
        
        <Box sx={{ width: '100%' }}>
            <TabContext value={value.toString()}>
                <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                    <TabList onChange={handleChange}>
                        <Tab label="Stack" value="0" />
                        <Tab label="Swap" value="1" />
                        <Tab label="Market" value="2" />
                    </TabList>
                </Box>
                <TabPanel value="0">
                    <Stack />
                </TabPanel>
                <TabPanel value="1">
                    <MarketSwap />
                </TabPanel>
                <TabPanel value="2">
                    <Market />
                </TabPanel>
            </TabContext>
        </Box>
    </>)
}