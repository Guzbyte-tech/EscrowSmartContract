// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    
    enum EscrowState { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, DISPUTED }
    
    EscrowState public currentState;
    
    address payable public buyer;
    address payable public seller;
    address public escrowAgent; // Mediator in case of dispute
    
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this.");
        _;
    }
    
    modifier onlyEscrowAgent() {
        require(msg.sender == escrowAgent, "Only the escrow agent can call this.");
        _;
    }
    
    constructor(address payable _seller, address _escrowAgent) {
        buyer = payable(msg.sender); // Sender of the contract is the buyer
        seller = _seller;
        escrowAgent = _escrowAgent;
        currentState = EscrowState.AWAITING_PAYMENT;
    }

    // Buyer sends funds
    function depositFunds() external payable onlyBuyer {
        require(currentState == EscrowState.AWAITING_PAYMENT, "Already paid.");
        require(msg.value > 0, "Funds must be greater than 0.");
        
        currentState = EscrowState.AWAITING_DELIVERY;
    }

    // Buyer confirms item delivery
    function confirmDelivery() external onlyBuyer {
        require(currentState == EscrowState.AWAITING_DELIVERY, "Cannot confirm delivery yet.");
        
        currentState = EscrowState.COMPLETE;
        seller.transfer(address(this).balance); // Send funds to the seller
    }
    
    // Buyer or seller can raise a dispute
    function raiseDispute() external {
        require(currentState == EscrowState.AWAITING_DELIVERY, "Cannot raise dispute at this stage.");
        require(msg.sender == buyer || msg.sender == seller, "Only buyer or seller can raise a dispute.");
        
        currentState = EscrowState.DISPUTED;
    }

    // Escrow Agent resolves the dispute
    function resolveDispute(bool refundBuyer) external onlyEscrowAgent {
        require(currentState == EscrowState.DISPUTED, "No dispute to resolve.");
        
        if (refundBuyer) {
            buyer.transfer(address(this).balance); // Refund the buyer
        } else {
            seller.transfer(address(this).balance); // Pay the seller
        }
        
        currentState = EscrowState.COMPLETE;
    }
}
