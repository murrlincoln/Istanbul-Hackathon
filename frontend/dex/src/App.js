import "./App.css";
import Header from "./components/Header";
import Swap from "./components/Swap";
import Tokens from "./components/Tokens";
import { Routes, Route } from "react-router-dom";
import { createWeb3Modal, defaultConfig } from '@web3modal/ethers5/react'

// 1. Get projectId
const projectId = '6a6b8cba9a686837f256bfecc86a96af'

// 2. Set chains
const sepolia_scroll = {
  chainId: 534351,
  name: 'Sepolia Scroll',
  currency: 'ETH',
  explorerUrl: 'https://sepolia.scrollscan.dev/',
  rpcUrl: 'https://scroll-sepolia.chainstacklabs.com'
}

// 3. Create modal
const metadata = {
  name: 'ParkSwap',
  description: 'A cool DEX with a unique governance design',
  url: 'https://mywebsite.com',
  icons: ['https://avatars.mywebsite.com/']
}

createWeb3Modal({
  ethersConfig: defaultConfig({ metadata }),
  chains: [sepolia_scroll],
  projectId
})

function App() {
  return (<div className="App">
    <Header />
    <div className="mainWindow">
      <Routes>
        <Route path="/" element={<Swap />} />
        <Route path="/tokens" element={<Tokens />} />
      </Routes>
    </div>

  </div>
  )
}

export default App;
