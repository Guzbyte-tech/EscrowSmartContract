import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from 'ethers';
import hre from "hardhat";

const EscrowModule =  buildModule("EscrowModule", (m) => {

  async function setupSigners() {
    const [buyer, seller, escrowAgent] = await hre.ethers.getSigners();
    return { buyer, seller, escrowAgent };
  }

  const seller = { address: "0x37A7610c8A62F1CB7d3b80fF5ADD8953d106E6a0" }; 
  const escrowAgent = { address: "0x51816a1b29569fbB1a56825C375C254742a9c5e1" }; 

  const Escrow = m.contract("Escrow", [seller.address, escrowAgent.address]);

  return { Escrow };
});

export default EscrowModule;
