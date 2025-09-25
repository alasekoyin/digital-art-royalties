;; NFT Royalty System Smart Contract
;; Mint NFTs with embedded royalties and distribute payments on secondary sales

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u104))
(define-constant ERR_INVALID_ROYALTY (err u105))
(define-constant ERR_NOT_FOR_SALE (err u106))
(define-constant ERR_SELF_PURCHASE (err u107))
(define-constant ERR_INVALID_PERCENTAGE (err u108))
(define-constant MAX_ROYALTY_PERCENTAGE u2000) ;; 20%
(define-constant PLATFORM_FEE_PERCENTAGE u250) ;; 2.5%
(define-constant PERCENTAGE_SCALE u10000) ;; 100%

;; Data Variables
(define-data-var next-token-id uint u1)
(define-data-var contract-admin principal tx-sender)
(define-data-var platform-fee-recipient principal tx-sender)

;; Data Maps

;; NFT Metadata and Ownership
(define-map nfts
  { token-id: uint }
  {
    owner: principal,
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    image-uri: (string-ascii 200),
    royalty-percentage: uint,
    royalty-recipient: principal,
    mint-timestamp: uint
  }
)

;; Marketplace Listings
(define-map marketplace-listings
  { token-id: uint }
  {
    seller: principal,
    price-ustx: uint,
    listed-at: uint,
    active: bool
  }
)

;; Royalty Balances
(define-map royalty-balances
  { recipient: principal }
  { balance-ustx: uint }
)

;; Sale History
(define-map sale-history
  { token-id: uint, sale-index: uint }
  {
    seller: principal,
    buyer: principal,
    price-ustx: uint,
    royalty-paid: uint,
    platform-fee-paid: uint,
    sale-timestamp: uint
  }
)

;; Sale Counters
(define-map sale-counters
  { token-id: uint }
  { count: uint }
)

;; Artist Profiles
(define-map artist-profiles
  { artist: principal }
  {
    name: (string-ascii 100),
    bio: (string-ascii 500),
    verified: bool,
    total-minted: uint,
    total-royalties: uint
  }
)

;; Private Functions

;; Check if caller is contract admin
(define-private (is-admin (caller principal))
  (is-eq caller (var-get contract-admin))
)

;; Get next token ID and increment
(define-private (get-next-token-id)
  (let ((current-id (var-get next-token-id)))
    (var-set next-token-id (+ current-id u1))
    current-id
  )
)

;; Validate royalty percentage
(define-private (is-valid-royalty (percentage uint))
  (<= percentage MAX_ROYALTY_PERCENTAGE)
)

;; Calculate royalty amount
(define-private (calculate-royalty (price uint) (percentage uint))
  (/ (* price percentage) PERCENTAGE_SCALE)
)

;; Calculate platform fee
(define-private (calculate-platform-fee (price uint))
  (/ (* price PLATFORM_FEE_PERCENTAGE) PERCENTAGE_SCALE)
)

;; Add to royalty balance
(define-private (add-to-royalty-balance (recipient principal) (amount uint))
  (let ((current-balance (default-to u0 (get balance-ustx (map-get? royalty-balances { recipient: recipient })))))
    (map-set royalty-balances
      { recipient: recipient }
      { balance-ustx: (+ current-balance amount) }
    )
  )
)

;; Get next sale index for token
(define-private (get-next-sale-index (token-id uint))
  (let ((current-count (default-to u0 (get count (map-get? sale-counters { token-id: token-id })))))
    (map-set sale-counters { token-id: token-id } { count: (+ current-count u1) })
    current-count
  )
)

;; Public Functions

;; Set artist profile
(define-public (set-artist-profile 
  (name (string-ascii 100))
  (bio (string-ascii 500))
)
  (let ((existing-profile (map-get? artist-profiles { artist: tx-sender })))
    (map-set artist-profiles
      { artist: tx-sender }
      (merge 
        (default-to 
          { name: name, bio: bio, verified: false, total-minted: u0, total-royalties: u0 }
          existing-profile
        )
        { name: name, bio: bio }
      )
    )
    (ok true)
  )
)

;; Verify artist (admin only)
(define-public (verify-artist (artist principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_UNAUTHORIZED)
    (let ((profile (unwrap! (map-get? artist-profiles { artist: artist }) ERR_NOT_FOUND)))
      (map-set artist-profiles
        { artist: artist }
        (merge profile { verified: true })
      )
    )
    (ok true)
  )
)

;; Mint NFT with royalty terms
(define-public (mint-nft
  (title (string-ascii 100))
  (description (string-ascii 500))
  (image-uri (string-ascii 200))
  (royalty-percentage uint)
  (royalty-recipient principal)
)
  (let ((token-id (get-next-token-id)))
    (asserts! (is-valid-royalty royalty-percentage) ERR_INVALID_ROYALTY)
    
    ;; Create NFT
    (map-set nfts
      { token-id: token-id }
      {
        owner: tx-sender,
        creator: tx-sender,
        title: title,
        description: description,
        image-uri: image-uri,
        royalty-percentage: royalty-percentage,
        royalty-recipient: royalty-recipient,
        mint-timestamp: stacks-block-height
      }
    )
    
    ;; Update artist profile
    (let ((profile (default-to 
      { name: "", bio: "", verified: false, total-minted: u0, total-royalties: u0 }
      (map-get? artist-profiles { artist: tx-sender }))))
      (map-set artist-profiles
        { artist: tx-sender }
        (merge profile { total-minted: (+ (get total-minted profile) u1) })
      )
    )
    
    (ok token-id)
  )
)

;; List NFT for sale
(define-public (list-nft-for-sale (token-id uint) (price-ustx uint))
  (let ((nft (unwrap! (map-get? nfts { token-id: token-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (get owner nft) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (> price-ustx u0) ERR_INVALID_AMOUNT)
    
    (map-set marketplace-listings
      { token-id: token-id }
      {
        seller: tx-sender,
        price-ustx: price-ustx,
        listed-at: stacks-block-height,
        active: true
      }
    )
    (ok true)
  )
)

;; Remove NFT from sale
(define-public (remove-from-sale (token-id uint))
  (let 
    (
      (nft (unwrap! (map-get? nfts { token-id: token-id }) ERR_NOT_FOUND))
      (listing (unwrap! (map-get? marketplace-listings { token-id: token-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq (get owner nft) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (get active listing) ERR_NOT_FOR_SALE)
    
    (map-set marketplace-listings
      { token-id: token-id }
      (merge listing { active: false })
    )
    (ok true)
  )
)

;; Purchase NFT with automatic royalty distribution
(define-public (purchase-nft (token-id uint))
  (let 
    (
      (nft (unwrap! (map-get? nfts { token-id: token-id }) ERR_NOT_FOUND))
      (listing (unwrap! (map-get? marketplace-listings { token-id: token-id }) ERR_NOT_FOUND))
      (price (get price-ustx listing))
      (royalty-amount (calculate-royalty price (get royalty-percentage nft)))
      (platform-fee (calculate-platform-fee price))
      (seller-amount (- (- price royalty-amount) platform-fee))
      (sale-index (get-next-sale-index token-id))
    )
    (asserts! (get active listing) ERR_NOT_FOR_SALE)
    (asserts! (not (is-eq (get seller listing) tx-sender)) ERR_SELF_PURCHASE)
    
    ;; Transfer payment to seller
    (try! (stx-transfer? seller-amount tx-sender (get seller listing)))
    
    ;; Pay royalty if it's a secondary sale (creator is not the seller)
    (if (not (is-eq (get creator nft) (get seller listing)))
      (begin
        (try! (stx-transfer? royalty-amount tx-sender (get royalty-recipient nft)))
        (add-to-royalty-balance (get royalty-recipient nft) royalty-amount)
        ;; Update artist profile royalties
        (let ((profile (default-to 
          { name: "", bio: "", verified: false, total-minted: u0, total-royalties: u0 }
          (map-get? artist-profiles { artist: (get creator nft) }))))
          (map-set artist-profiles
            { artist: (get creator nft) }
            (merge profile { total-royalties: (+ (get total-royalties profile) royalty-amount) })
          )
        )
        true
      )
      true ;; No royalty for primary sales
    )
    
    ;; Pay platform fee
    (try! (stx-transfer? platform-fee tx-sender (var-get platform-fee-recipient)))
    
    ;; Transfer NFT ownership
    (map-set nfts
      { token-id: token-id }
      (merge nft { owner: tx-sender })
    )
    
    ;; Deactivate listing
    (map-set marketplace-listings
      { token-id: token-id }
      (merge listing { active: false })
    )
    
    ;; Record sale history
    (map-set sale-history
      { token-id: token-id, sale-index: sale-index }
      {
        seller: (get seller listing),
        buyer: tx-sender,
        price-ustx: price,
        royalty-paid: royalty-amount,
        platform-fee-paid: platform-fee,
        sale-timestamp: stacks-block-height
      }
    )
    
    (ok true)
  )
)

;; Transfer NFT directly (gift/private transfer)
(define-public (transfer-nft (token-id uint) (recipient principal))
  (let ((nft (unwrap! (map-get? nfts { token-id: token-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (get owner nft) tx-sender) ERR_UNAUTHORIZED)
    
    ;; Deactivate any active listing
    (match (map-get? marketplace-listings { token-id: token-id })
      listing (if (get active listing)
        (map-set marketplace-listings
          { token-id: token-id }
          (merge listing { active: false })
        )
        true
      )
      true
    )
    
    ;; Transfer ownership
    (map-set nfts
      { token-id: token-id }
      (merge nft { owner: recipient })
    )
    
    (ok true)
  )
)

;; Update royalty recipient (creator only)
(define-public (update-royalty-recipient (token-id uint) (new-recipient principal))
  (let ((nft (unwrap! (map-get? nfts { token-id: token-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (get creator nft) tx-sender) ERR_UNAUTHORIZED)
    
    (map-set nfts
      { token-id: token-id }
      (merge nft { royalty-recipient: new-recipient })
    )
    (ok true)
  )
)

;; Withdraw accumulated royalties
(define-public (withdraw-royalties)
  (let 
    (
      (balance-entry (unwrap! (map-get? royalty-balances { recipient: tx-sender }) ERR_NOT_FOUND))
      (balance (get balance-ustx balance-entry))
    )
    (asserts! (> balance u0) ERR_INVALID_AMOUNT)
    
    ;; Reset balance
    (map-set royalty-balances
      { recipient: tx-sender }
      { balance-ustx: u0 }
    )
    
    ;; Transfer balance to recipient
    (try! (as-contract (stx-transfer? balance tx-sender tx-sender)))
    
    (ok balance)
  )
)

;; Batch mint for collections
(define-public (batch-mint
  (base-title (string-ascii 50))
  (base-description (string-ascii 300))
  (base-uri (string-ascii 150))
  (count uint)
  (royalty-percentage uint)
  (royalty-recipient principal)
)
  (begin
    (asserts! (<= count u10) ERR_INVALID_AMOUNT) ;; Max 10 NFTs per batch
    (asserts! (is-valid-royalty royalty-percentage) ERR_INVALID_ROYALTY)
    
    (fold mint-single
      (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10)
      {
        remaining: count,
        base-title: base-title,
        base-description: base-description,
        base-uri: base-uri,
        royalty-percentage: royalty-percentage,
        royalty-recipient: royalty-recipient,
        results: (list )
      }
    )
    (ok true)
  )
)

;; Helper function for batch minting
(define-private (mint-single (index uint) (context {remaining: uint, base-title: (string-ascii 50), base-description: (string-ascii 300), base-uri: (string-ascii 150), royalty-percentage: uint, royalty-recipient: principal, results: (list 10 uint)}))
  (if (> (get remaining context) u0)
    (let ((token-id (get-next-token-id)))
      (map-set nfts
        { token-id: token-id }
        {
          owner: tx-sender,
          creator: tx-sender,
          title: (get base-title context),
          description: (get base-description context),
          image-uri: (get base-uri context),
          royalty-percentage: (get royalty-percentage context),
          royalty-recipient: (get royalty-recipient context),
          mint-timestamp: stacks-block-height
        }
      )
      {
        remaining: (- (get remaining context) u1),
        base-title: (get base-title context),
        base-description: (get base-description context),
        base-uri: (get base-uri context),
        royalty-percentage: (get royalty-percentage context),
        royalty-recipient: (get royalty-recipient context),
        results: (unwrap-panic (as-max-len? (append (get results context) token-id) u10))
      }
    )
    context
  )
)

;; Read-only functions

;; Get NFT details
(define-read-only (get-nft (token-id uint))
  (map-get? nfts { token-id: token-id })
)

;; Get marketplace listing
(define-read-only (get-listing (token-id uint))
  (map-get? marketplace-listings { token-id: token-id })
)

;; Get royalty balance
(define-read-only (get-royalty-balance (recipient principal))
  (default-to u0 (get balance-ustx (map-get? royalty-balances { recipient: recipient })))
)

;; Get sale history
(define-read-only (get-sale-history (token-id uint) (sale-index uint))
  (map-get? sale-history { token-id: token-id, sale-index: sale-index })
)

;; Get artist profile
(define-read-only (get-artist-profile (artist principal))
  (map-get? artist-profiles { artist: artist })
)

;; Get total NFT count
(define-read-only (get-total-nft-count)
  (- (var-get next-token-id) u1)
)

;; Get sale count for NFT
(define-read-only (get-sale-count (token-id uint))
  (default-to u0 (get count (map-get? sale-counters { token-id: token-id })))
)

;; Check if NFT exists
(define-read-only (nft-exists (token-id uint))
  (is-some (map-get? nfts { token-id: token-id }))
)

;; Get NFT owner
(define-read-only (get-owner (token-id uint))
  (match (map-get? nfts { token-id: token-id })
    nft (some (get owner nft))
    none
  )
)

;; Calculate fees for a given price
(define-read-only (calculate-fees (price uint) (royalty-percentage uint))
  {
    royalty: (calculate-royalty price royalty-percentage),
    platform-fee: (calculate-platform-fee price),
    seller-amount: (- (- price (calculate-royalty price royalty-percentage)) (calculate-platform-fee price))
  }
)

