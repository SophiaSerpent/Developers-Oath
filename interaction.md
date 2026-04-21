
🌌 Overview
The Developer's Oath is an ownerless, perpetual smart contract. To sustain the terminal and etch your name upon the Mural of Integrity, you must interact with the protocol via the Base Mainnet. This guide outlines the manual and programmatic methods for sustaining the pulse.

🛠️ Technical Specifications
Network: Base (Layer 2)

USDC Address: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913

Contract Address: [DEPLOYED_ADDRESS_HERE]

Minimum Tribute: $1.00 USDC (1,000,000 units)

🏗️ Interaction Flow
1. The Approval (Handshake)
Before the Oath can accept your USDC, you must grant the contract permission to move the funds. This is a security standard of the ERC-20 protocol.

Navigate to the USDC Contract on BaseScan.

Call the approve function.

Spender: [THE_OATH_CONTRACT_ADDRESS]

Value: The amount you wish to contribute (e.g., 1000000 for $1).

2. The Sustain (Vow)
Once approved, you call the sustain function on the Developer's Oath contract.

_name: Your handle (Max 20 characters). This will be etched onto the Mural.

_amount: The exact amount you approved in Step 1.

3. The Claim (Redistribution)
After the 90-day cycle completes, you may retrieve your share.

Call claim(cycleId).

Your USDC is returned to your wallet. The terminal is reset.

🛡️ Integrity & Security
The contract has been architected by _beautifulDATA with a "Build and Destroy" rigor:

Non-Reentrant: Protected against recursive withdrawal attacks.

Pull-Payment: Ensures the contract never fails due to gas limits.

Immutable: No owner, no backdoors, no kill-switch.
