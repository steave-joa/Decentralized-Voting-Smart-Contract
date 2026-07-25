# 🗳️ Decentralized Voting Smart Contract

A blockchain-based decentralized voting smart contract built with Solidity. This project demonstrates how blockchain technology can be used to create a transparent, tamper-resistant, and controlled voting system.

The smart contract allows an administrator to register voters, add candidates, manage the voting lifecycle, and determine the winner after voting ends.

---

## 🚀 Project Overview

This project implements a decentralized voting system using a Solidity smart contract.

The contract follows a controlled voting lifecycle:

**Deployment → Voter Registration → Candidate Registration → Voting Started → Voting → Voting Ended → Winner Declaration**

The voting process is stored on the blockchain, making the voting records transparent and preventing registered voters from voting more than once.

---

## ✨ Features

- Admin-controlled voting system
- Register eligible voters
- Prevent duplicate voter registration
- Add candidates before voting starts
- Prevent empty candidate names
- Start and end the voting process
- Allow only registered voters to vote
- Allow each registered voter to vote only once
- Validate candidate IDs
- Track candidate vote counts
- Retrieve individual candidate details
- Retrieve all candidates
- Detect voting ties
- Determine the winner after voting ends
- Emit events for important voting activities
- Three-state voting lifecycle management

---

## 🛠️ Technologies Used

- Solidity `^0.8.18`
- Remix IDE
- Ethereum / EVM-compatible Blockchain
- MetaMask

---

## 📂 Project Structure

```text
decentralized-voting-solidity/
│
├── Voting.sol
└── README.md
