import { useEthers, useEtherBalance, useBlockMeta } from "@usedapp/core"
import { formatUnits, formatEther } from "@ethersproject/units"
import { BigNumber } from "@ethersproject/bignumber"
import Button from '@mui/material/Button'
import Box from '@mui/material/Box'
import TextField from '@mui/material/TextField'

const formatBalance = (balance: BigNumber | undefined) => parseFloat(formatEther(balance ?? BigNumber.from('0')))


export const Header = () => {

    const { account, activateBrowserWallet, deactivate } = useEthers()
    const isConnected = account !== undefined
     const etherBalance = useEtherBalance(account);

    return (
        <Box sx={{ display:'flex', justifyContent:'flex-end' }}>
            {isConnected ? (
                <div>
                    <TextField label={formatBalance(etherBalance!)} InputProps={{ readOnly: true }}/> 
                    
                    <Button variant="contained" onClick={deactivate}>
                        Disconnect
                    </Button>
                </div>
            ) : (
                <div>
                    <Button
                        color="primary"
                        variant="contained"
                        onClick={() => activateBrowserWallet()}
                    >
                        Connect
                    </Button>

                </div>
            )}
        </Box>
    )
}

