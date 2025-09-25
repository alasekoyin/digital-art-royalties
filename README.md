# Digital Art Royalties Platform

## Overview

A next-generation NFT marketplace with perpetual royalty payments to artists on secondary sales, revolutionizing how digital creators are compensated for their work throughout the lifecycle of their art pieces.

## Features

### Core Functionality
- **NFT Minting with Embedded Royalties**: Create NFTs with built-in royalty mechanisms
- **Perpetual Royalty System**: Automatic royalty payments on every secondary sale
- **Marketplace Integration**: Seamless trading with automatic royalty distribution
- **Artist Protection**: Immutable royalty terms protect creator rights
- **Transparent Payment Trail**: Complete audit trail of all royalty payments

### Smart Contract Structure

**Main Contract: `nft-royalty-system`**

**Primary Functions:**
1. `mint-nft` - Create NFTs with embedded royalty percentages
2. `list-for-sale` - List NFTs in the marketplace with royalty preservation
3. `purchase-nft` - Buy NFTs with automatic royalty distribution
4. `transfer-nft` - Transfer NFTs while maintaining royalty obligations
5. `withdraw-royalties` - Allow artists to claim accumulated royalties
6. `update-royalty-recipient` - Change royalty recipient address

**Data Maps:**
- NFT registry with metadata and royalty information
- Marketplace listings with price and availability
- Royalty balances and payment history
- Artist verification and reputation system

## Business Benefits

### For Digital Artists
- **Perpetual Income Stream**: Earn from every resale of your artwork
- **Creator Rights Protection**: Immutable royalty terms cannot be bypassed
- **Global Market Access**: Reach collectors worldwide
- **Transparent Payments**: Real-time royalty tracking and distribution
- **Brand Building**: Verified artist profiles and reputation system

### For Art Collectors
- **Authentic Ownership**: Blockchain-verified provenance and ownership
- **Investment Transparency**: Clear royalty obligations upfront
- **Supporting Artists**: Direct contribution to creator economy
- **Liquid Market**: Easy trading with built-in royalty handling

### For the Art Market
- **Sustainable Creator Economy**: Long-term artist compensation model
- **Reduced Transaction Friction**: Automated royalty calculations
- **Market Integrity**: Transparent pricing and fee structure
- **Innovation Incentive**: Encourages high-quality digital art creation

## Technical Features

### Royalty Management
- **Flexible Royalty Rates**: Customizable percentages (0-20%)
- **Multi-Recipient Support**: Split royalties between multiple parties
- **Automatic Distribution**: Instant royalty payments on sales
- **Accumulated Balance Tracking**: Track unpaid royalties over time

### NFT Standards Compliance
- **SIP-009 Compatible**: Standard NFT interface implementation
- **Metadata Standards**: Rich metadata with IPFS integration
- **Transfer Restrictions**: Optional transfer limitations for exclusive pieces
- **Burn Functionality**: Permanent NFT destruction when needed

### Security Features
- **Access Control**: Role-based permissions for marketplace operations
- **Reentrancy Protection**: Secure against common attack vectors
- **Overflow Protection**: Safe arithmetic operations
- **Royalty Validation**: Ensures royalty percentages are within bounds

## Use Cases

### Primary Art Sales
1. Artist mints NFT with 10% royalty rate
2. Lists artwork for initial sale
3. Collector purchases, full payment goes to artist
4. Royalty terms embedded for all future sales

### Secondary Market Trading
1. Collector lists owned NFT for resale
2. New buyer purchases at market price
3. Artist automatically receives royalty percentage
4. Remaining payment goes to seller
5. Ownership transfers to new buyer with same royalty terms

### Royalty Management
1. Artists can check accumulated royalty balances
2. Withdraw payments at any time
3. Update recipient address if needed
4. Track payment history and analytics

## Getting Started

### For Artists
1. **Mint Your Art**: Create NFTs with desired royalty percentage
2. **Set Pricing**: List your artwork in the marketplace
3. **Promote**: Share your collection with potential collectors
4. **Earn Royalties**: Receive payments from every resale automatically

### For Collectors
1. **Browse Marketplace**: Discover unique digital artworks
2. **Check Royalty Terms**: Review royalty obligations before purchase
3. **Buy with Confidence**: Secure blockchain-verified transactions
4. **Trade Freely**: Resell with automatic royalty handling

### For Developers
```bash
# Clone repository
git clone <repository-url>
cd digital-art-royalties

# Install dependencies
npm install

# Check contracts
clarinet check

# Run tests
clarinet test
```

## Contract Specifications

### NFT Properties
- **Unique Token IDs**: Sequential numbering system
- **Rich Metadata**: Title, description, image URI, attributes
- **Creator Information**: Original artist verification
- **Royalty Terms**: Percentage and recipient address
- **Transfer History**: Complete ownership trail

### Marketplace Features
- **Active Listings**: Current NFTs available for purchase
- **Price Discovery**: Market-driven pricing mechanism
- **Sale History**: Historical transaction data
- **Royalty Tracking**: Real-time royalty calculations

## Economic Model

### Revenue Streams
- **Primary Sales**: 100% to artist (minus platform fee)
- **Royalty Payments**: Percentage of every secondary sale
- **Platform Fees**: Small percentage for marketplace operations

### Fee Structure
- **Listing Fee**: Free to list NFTs
- **Transaction Fee**: 2.5% platform fee on sales
- **Royalty Range**: 0-20% set by artist
- **Gas Costs**: Standard blockchain transaction fees

This implementation creates a sustainable digital art ecosystem where artists maintain long-term value capture from their creative work while providing collectors with transparent, liquid market access.