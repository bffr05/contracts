import logo from './logo.svg';
import './App.css';
import Ethers from './components/Ethers'

import { Web3ReactProvider } from "@web3-react/core";
import { Web3Provider } from "@ethersproject/providers";

const getLibrary = (provider) => {
  return new Web3Provider(provider);
};

function App() {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>

    <div className="App">
      <Ethers />
    </div>
    </Web3ReactProvider>

  );
}

export default App;
