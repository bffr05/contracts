import React, { useState, useEffect } from "react";
import { TokenType, useErc20Balance, useStackBalance, useStackStake, useStackUnstake, useStackIsModeTest, useStackTestStake, useStackTestUnstake,useStackGetType } from "../hooks";
import { useNotifications,useEtherBalance,useEthers } from "@usedapp/core";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Slider from "@mui/material/Slider";
import TextField from "@mui/material/TextField";
import { BigNumber } from "@ethersproject/bignumber";
import { formatUnits, formatEther } from "@ethersproject/units";
import Grid from "@mui/material/Grid";
import InputAdornment from "@mui/material/InputAdornment";
import Avatar from "@mui/material/Avatar";
import Snackbar from "@mui/material/Snackbar";
import Alert from "@mui/material/Alert";
import CircularProgress from "@mui/material/CircularProgress";
import { utils } from "ethers";

export interface Erc20InfoProps {
    address: string;
    type: TokenType;
    symbol: string;
    name: string;
    decimals: number;
    image: string;
}

export const Erc20Info = ({ address, type, symbol, name, decimals, image }: Erc20InfoProps) => {
    const { notifications } = useNotifications();

    const formatBalance = (balance: BigNumber | undefined) => parseFloat(formatEther(balance ?? BigNumber.from("0")));
    const { account } = useEthers();
    const isModeTest = useStackIsModeTest();
    const walletBalance = useErc20Balance(address);
    const stackBalance = useStackBalance(address);
    const [amount, setAmount] = useState<String>(formatBalance(stackBalance).toString());
    
    useEffect(() => {
        setAmount(formatBalance(stackBalance).toString());
      }, [stackBalance]);

    //console.log("address=", address, " symbol=", symbol, " name=", name, " current=", current);
    console.log("wallet=", formatBalance(walletBalance), " stack=", formatBalance(stackBalance), " amount=", amount, " amountNumber=", Number(amount));
    
    const handleSlideChange = (event: Event, value: number | Array<number>, activeThumb: number) => {
        if (typeof value === "number") setAmount(value.toString());
    };
    const handleStackBalanceChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const numamount = Number(amount);

        setAmount(event.target.value);
    };
    const { stake, approveState, stakeState } = useStackStake(address);
    const { unstake, unstakeState } = useStackUnstake(address);
    const { testStake, testStakeState } = useStackTestStake(address);
    const { testUnstake, testUnstakeState } = useStackTestUnstake(address);

    const handleTransfer = () => {
        if (isModeTest) {
            console.log("test transfer=", amount);
            if (Number(amount) > formatBalance(stackBalance)) {
                const amountAsWei = utils.parseEther((Number(amount) - formatBalance(stackBalance)).toString());
                return testStake(amountAsWei.toString());
            } else {
                const amountAsWei = utils.parseEther((formatBalance(stackBalance) - Number(amount)).toString());
                return testUnstake(amountAsWei.toString());
            }
        } else {
            console.log("transfer=", amount);

            if (Number(amount) > formatBalance(stackBalance)) {
                const amountAsWei = utils.parseEther((Number(amount) - formatBalance(stackBalance)).toString());
                return stake(amountAsWei.toString());
            } else {
                const amountAsWei = utils.parseEther((formatBalance(stackBalance) - Number(amount)).toString());
                return unstake(amountAsWei.toString());
            }
        }
    };

    
    useEffect(() => {
        if (
            notifications.filter((notification) => (notification.type === "transactionSucceed" || notification.type === "transactionFailed") && notification.transactionName === "approve").length > 0
        ) {
            approveState.status = "None";
        }
        if (notifications.filter((notification) => (notification.type === "transactionSucceed" || notification.type === "transactionFailed") && notification.transactionName === "stake").length > 0) {
            stakeState.status = "None";
        }
        if (
            notifications.filter((notification) => (notification.type === "transactionSucceed" || notification.type === "transactionFailed") && notification.transactionName === "unstake").length > 0
        ) {
            unstakeState.status = "None";
        }
        if (
            notifications.filter((notification) => (notification.type === "transactionSucceed" || notification.type === "transactionFailed") && notification.transactionName === "teststake").length > 0
        ) {
            testStakeState.status = "None";
        }
        if (
            notifications.filter((notification) => (notification.type === "transactionSucceed" || notification.type === "transactionFailed") && notification.transactionName === "testunstake").length >
            0
        ) {
            testUnstakeState.status = "None";
        }
    }, [notifications]);


    
    return (
        <>
            <Box sx={{ flexGrow: 1 }}>
                {isModeTest ? (
                    <Alert severity="warning" sx={{ width: 1, margin: 2 }}>
                        Test Mode
                    </Alert>
                ) : (
                    <></>
                )}
                <Grid container spacing={2}>
                    <Grid item xs={1}>
                        <Avatar src={image} sx={{ width: 52, height: 52 }} />
                    </Grid>
                    <Grid item xs={2}>
                        <TextField
                            value={symbol}
                            fullWidth
                            label="Symbol"
                            InputProps={{
                                readOnly: true,
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                        />
                    </Grid>
                    <Grid item xs={5}>
                        <TextField
                            value={name}
                            fullWidth
                            label="Name"
                            InputProps={{
                                readOnly: true,
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                        />
                    </Grid>
                    <Grid item xs={12} />
                </Grid>
                <Grid container spacing={1}>
                    <Grid item xs={3}>
                        <TextField
                            value={
                                isModeTest
                                    ? formatBalance(walletBalance)
                                    : isNaN(Number(amount)) || Number(amount) < 0 || Number(amount) > formatBalance(walletBalance) + formatBalance(stackBalance)
                                    ? ""
                                    : formatBalance(walletBalance) + formatBalance(stackBalance) - Number(amount)
                            }
                            fullWidth
                            label="Wallet"
                            InputProps={{
                                readOnly: true,
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                        />
                    </Grid>
                    <Grid item xs={4}>
                        <Slider
                            track={false}
                            value={Number(amount)}
                            min={0}
                            max={isModeTest ? 1000000 : formatBalance(walletBalance) + formatBalance(stackBalance)}
                            step={0.00001}
                            valueLabelDisplay="auto"
                            onChange={handleSlideChange}
                            sx={{ width: 0.87, margin: 2 }}
                        />
                    </Grid>
                    <Grid item xs={3}>
                        <TextField
                            value={amount}
                            fullWidth
                            label="Stack"
                            InputProps={{
                                startAdornment: <InputAdornment position="start"></InputAdornment>,
                            }}
                            color="secondary"
                            onChange={handleStackBalanceChange}
                            disabled={
                                approveState.status !== "None" ||
                                stakeState.status !== "None" ||
                                testStakeState.status !== "None" ||
                                unstakeState.status !== "None" ||
                                testUnstakeState.status !== "None"
                            }                            
                        />
                    </Grid>
                    <Grid item xs={2}>
                        <Button
                            variant="contained"
                            disabled={
                                approveState.status !== "None" ||
                                stakeState.status !== "None" ||
                                testStakeState.status !== "None" ||
                                unstakeState.status !== "None" ||
                                testUnstakeState.status !== "None" ||
                                isNaN(Number(amount)) ||
                                Number(amount) == formatBalance(stackBalance)
                            }
                            onClick={handleTransfer}
                            sx={{ margin: 1 }}
                        >
                            {approveState.status !== "None" ||
                            stakeState.status !== "None" ||
                            testStakeState.status !== "None" ||
                            unstakeState.status !== "None" ||
                            testUnstakeState.status !== "None" ? (
                                <CircularProgress size={26} />
                            ) : isModeTest ? (
                                "Fake"
                            ) : (
                                "Transfer"
                            )}
                        </Button>
                    </Grid>
                </Grid>
            </Box>
            <Snackbar open={approveState.status === "Success"} autoHideDuration={5000} >
                <Alert  severity="success">
                    Tokens transfer approved!
                </Alert>
            </Snackbar>
            <Snackbar open={stakeState.status === "Success"} autoHideDuration={5000} >
                <Alert  severity="success">
                    Tokens Staked!
                </Alert>
            </Snackbar>
            <Snackbar open={testStakeState.status === "Mining"} autoHideDuration={5000} >
                <Alert  severity="info">
                    Tokens TestStake Mining...
                </Alert>
            </Snackbar>
            <Snackbar open={testStakeState.status === "Success"} autoHideDuration={5000} >
                <Alert  severity="success">
                    Tokens TestStake Succeeded !
                </Alert>
            </Snackbar>
            <Snackbar open={testStakeState.status === "Exception"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens TestStake Exception !
                </Alert>
            </Snackbar>
            <Snackbar open={testStakeState.status === "Fail"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens TestStake Failed!
                </Alert>
            </Snackbar>
            <Snackbar open={testStakeState.status === "Mining"} autoHideDuration={5000} >
                <Alert  severity="info">
                    Tokens TestStake Mining...
                </Alert>
            </Snackbar>
            <Snackbar open={unstakeState.status === "Success"} autoHideDuration={5000} >
                <Alert  severity="success">
                    Tokens Unstake Succeeded !
                </Alert>
            </Snackbar>
            <Snackbar open={unstakeState.status === "Exception"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens Unstake Exception !
                </Alert>
            </Snackbar>
            <Snackbar open={unstakeState.status === "Fail"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens Unstake Failed!
                </Alert>
            </Snackbar>
            <Snackbar open={testUnstakeState.status === "Mining"} autoHideDuration={5000} >
                <Alert  severity="info">
                    Tokens TestUnstake Mining...
                </Alert>
            </Snackbar>
            <Snackbar open={testUnstakeState.status === "Success"} autoHideDuration={5000} >
                <Alert  severity="success">
                    Tokens TestUnstake Succeeded !
                </Alert>
            </Snackbar>
            <Snackbar open={testUnstakeState.status === "Exception"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens TestUnstake Exception !
                </Alert>
            </Snackbar>
            <Snackbar open={testUnstakeState.status === "Fail"} autoHideDuration={5000} >
                <Alert  severity="error">
                    Tokens TestUnstake Failed!
                </Alert>
            </Snackbar>
        </>
    );
};
