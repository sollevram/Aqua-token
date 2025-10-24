# Rainwater Credit Token (RAIN)

This smart contract implements the **Rainwater Credit Token (RAIN)** for tracking and managing rainwater credits on the Stacks blockchain. It provides mechanisms for provider registration, credit issuance, retirement, and metadata queries.

## Features

- **Fungible Token:** RAIN token with 2 decimals (centiliters).
- **Admin Controls:** Pause/unpause contract, add providers.
- **Provider Registry:** Track active providers and their regions.
- **Credit Issuance:** Registered providers can issue credits to users, with batch tracking.
- **Retirement:** Users can retire (burn) credits with notes for traceability.
- **Views:** Query total supply, provider info, batch details, and retirement records.

## Contract Metadata

- **Token Name:** Rainwater Credit
- **Symbol:** RAIN
- **Decimals:** 2

## Usage

### Admin Functions

- `set-paused(flag)`  
  Pause or unpause the contract (admin only).

- `add-provider(who, region)`  
  Register a new provider with a region (admin only).

### Provider Functions

- `issue-credits(user, volume)`  
  Issue RAIN credits to a user. Only active providers can call this.

### User Functions

- `retire-credits(volume, note)`  
  Retire (burn) RAIN credits with an optional note.

### Read-Only Functions

- `get-total-supply()`  
  Returns the total supply of RAIN tokens.

- `get-provider(who)`  
  Returns provider details for a given principal.

- `get-batch(id)`  
  Returns batch issuance details by batch ID.

- `get-retirement(id)`  
  Returns retirement details by retirement ID.

## Error Codes

- `u100`: Unauthorized (admin only)
- `u101`: Provider not found
- `u102`: Invalid volume
- `u103`: Minting failed
- `u104`: Burning failed

## Deployment

Deploy the contract on the Stacks blockchain using Clarity-compatible tools.  
Set the admin principal in the contract as needed.
