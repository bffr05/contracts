import React from 'react';
import { DAppProvider, ChainId } from "@usedapp/core"
import { Header } from "./components/Header"
import { Container } from "@material-ui/core"
import { Main } from "./components/Main"
import { useEthers } from "@usedapp/core"

function App() {
  return (
    <DAppProvider config={{
      notifications: {
        expirationPeriod: 1000,
        checkInterval: 1000
      }
    }}>
      <Header />
      <Container maxWidth="md">
      <Main />
      </Container>
    </DAppProvider>
  )
}

export default App