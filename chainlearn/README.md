# EduCred: Blockchain-Powered Educational Credentials

EduCred is a decentralized educational credential system built on the Stacks blockchain. It allows educational institutions to issue, manage, and verify academic credentials using NFT-based tokens.

## Overview

The EduCred system implements a secure and verifiable way to manage educational credentials through blockchain technology. It provides:
- Credential issuance by authorized institutions
- Token-based achievement tracking
- Time-based credential expiration
- Verification system for employers
- Hierarchical access control

## Project Structure

```
educred-stacks/
├── contracts/
│   └── education-token.clar       # Main smart contract
├── tests/                         # Test files (to be implemented)
│   └── education-token_test.ts
├── scripts/                       # Deployment scripts (to be implemented)
│   └── deploy.ts
└── README.md
```

## Smart Contract Features

### Core Functionality
- NFT-based credential tokens (SIP-009 compliant)
- Institution registration and management
- Credential minting with expiration dates
- Token transfer restrictions
- Revocation capability

### Security Features
- Contract pause mechanism
- Access control for institutions
- Input validation
- Expiration enforcement
- Revocation tracking

## Getting Started

### Prerequisites
- Clarity CLI
- Node.js and npm (for testing and deployment)
- A Stacks blockchain wallet

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/educred-stacks.git
cd educred-stacks
```

2. Install dependencies
```bash
npm install
```

### Testing
To run the tests (once implemented):
```bash
npm test
```

### Deployment
To deploy the contract (once scripts are implemented):
```bash
npm run deploy
```

## Usage

### Register an Institution
```clarity
(contract-call? .education-token register-institution "institution.name")
```

### Mint a Credential
```clarity
(contract-call? .education-token mint-credential 
    recipient-address 
    "Blockchain Certificate" 
    u31536000  ;; 1 year validity
    u1         ;; Level 1 credential
)
```

### Verify a Credential
```clarity
(contract-call? .education-token get-credential-info token-id)
```

## Contract Functions

### Administrative Functions
- `register-institution`: Register a new educational institution
- `toggle-contract-pause`: Emergency pause mechanism
- `revoke-credential`: Revoke an issued credential

### Token Operations
- `mint-credential`: Issue a new credential token
- `transfer`: Transfer a credential token
- `get-credential-info`: Get credential details
- `is-revoked`: Check if a credential is revoked
- `is-expired`: Check if a credential has expired

## Security Considerations
- All input data is validated
- Access control restrictions
- Non-transferable until conditions are met
- Expiration dates enforced
- Revocation capability