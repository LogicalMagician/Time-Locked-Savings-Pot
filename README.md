This Solidity smart contract allows users to lock their ETH, ERC20, and ERC721 tokens for a predetermined amount of time. After the timer is up, the contract automatically sends all the assets back to the wallet that deposited them or a predetermined wallet that can be set after the contract is deployed.

Getting Started
These instructions will help you to deploy the smart contract on the Ethereum blockchain.

Prerequisites
Ethereum wallet like Metamask
Some Ethereum or testnet tokens to pay for gas fees
Remix IDE or any other Solidity IDE
Deployment Steps
Open Remix IDE and create a new Solidity file.
Copy and paste the code from the provided Solidity file into the new file.
Compile the code by selecting the appropriate compiler version.
Deploy the contract by selecting the appropriate network and using a wallet like Metamask to pay for the gas fees.
After deployment, you can interact with the contract using the provided functions.
Functions
The following functions are available in this smart contract:

addDeposit(uint256 amount, uint256 unlockTime, address tokenAddress): Allows users to add a new deposit to the contract. The amount parameter specifies the amount of tokens to be locked, unlockTime specifies the timestamp when the deposit can be withdrawn, and tokenAddress specifies the address of the token to be locked. If tokenAddress is set to 0x0000000000000000000000000000000000000000, it means ETH is being locked.
withdrawDeposit(uint256 depositIndex): Allows users to withdraw a deposit after the unlock time has passed. The depositIndex parameter specifies the index of the deposit to be withdrawn.
changeOwner(address newOwner): Allows the contract owner to transfer ownership to a new address. The newOwner parameter specifies the address of the new owner.
changeLockTime(uint256 newLockTime): Allows the contract owner to change the default lock time. The newLockTime parameter specifies the new default lock time in seconds.
getDeposits(address user): Allows users to view their deposits.
getTokenBalance(address tokenAddress): Allows users to view the contract balance of a specific token.
Testing
