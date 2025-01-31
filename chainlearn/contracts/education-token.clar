;; Define trait
(define-trait nft-trait
    (
        ;; Last token ID, start with zero
        (get-last-token-id () (response uint uint))

        ;; URI for metadata
        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))

        ;; Owner of a token
        (get-owner (uint) (response (optional principal) uint))

        ;; Transfer token
        (transfer (uint principal principal) (response bool uint))
    )
)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-CREDENTIAL (err u101))
(define-constant ERR-EXPIRED (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-INVALID-EXPIRY (err u104))

;; Define NFT
(define-non-fungible-token educational-credential uint)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var contract-paused bool false)

;; Data Maps
(define-map institutions
    principal
    {
        name: (string-ascii 50),
        active: bool,
        registration-date: uint
    }
)

(define-map credentials
    uint
    {
        institution: principal,
        credential-type: (string-ascii 50),
        issue-date: uint,
        expiry-date: uint,
        level: uint,
        revoked: bool
    }
)

;; Private Functions
(define-private (is-owner (token-id uint))
    (let ((token-owner (unwrap! (nft-get-owner? educational-credential token-id) false)))
        (is-eq token-owner tx-sender)
    )
)

(define-private (is-active-institution (institution principal))
    (let ((inst-data (unwrap! (map-get? institutions institution) false)))
        (get active inst-data)
    )
)

;; NFT Trait Implementation Functions
(define-public (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-public (get-token-uri (token-id uint))
    (ok none)
)

(define-public (get-owner (token-id uint))
    (ok (nft-get-owner? educational-credential token-id))
)

;; Institution Management
(define-public (register-institution (name (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (is-none (map-get? institutions tx-sender)) ERR-ALREADY-EXISTS)
        (ok (map-set institutions tx-sender {
            name: name,
            active: true,
            registration-date: block-height
        }))
    )
)

;; Credential Management
(define-public (mint-credential 
    (recipient principal)
    (credential-type (string-ascii 50))
    (validity-period uint)
    (level uint)
)
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
            (institution tx-sender)
        )
        (asserts! (not (var-get contract-paused)) ERR-NOT-AUTHORIZED)
        (asserts! (is-active-institution institution) ERR-NOT-AUTHORIZED)
        (asserts! (> validity-period u0) ERR-INVALID-EXPIRY)
        
        ;; Update state
        (try! (nft-mint? educational-credential token-id recipient))
        (var-set last-token-id token-id)
        (map-set credentials token-id {
            institution: institution,
            credential-type: credential-type,
            issue-date: block-height,
            expiry-date: (+ block-height validity-period),
            level: level,
            revoked: false
        })
        (ok token-id)
    )
)

;; Token Queries
(define-read-only (get-credential-info (token-id uint))
    (map-get? credentials token-id)
)

(define-read-only (is-revoked (token-id uint))
    (let ((credential-data (unwrap! (map-get? credentials token-id) false)))
        (get revoked credential-data)
    )
)

(define-read-only (is-expired (token-id uint))
    (let ((credential-data (unwrap! (map-get? credentials token-id) false)))
        (> block-height (get expiry-date credential-data))
    )
)

;; Admin Functions
(define-public (toggle-contract-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
        (ok (var-set contract-paused (not (var-get contract-paused))))
    )
)

(define-public (revoke-credential (token-id uint))
    (let ((credential-data (unwrap! (map-get? credentials token-id) ERR-INVALID-CREDENTIAL)))
        (asserts! (is-eq tx-sender (get institution credential-data)) ERR-NOT-AUTHORIZED)
        (ok (map-set credentials token-id 
            (merge credential-data { revoked: true })))
    )
)

;; Transfer Function
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (is-revoked token-id)) ERR-INVALID-CREDENTIAL)
        (asserts! (not (is-expired token-id)) ERR-EXPIRED)
        (try! (nft-transfer? educational-credential token-id sender recipient))
        (ok true)
    )
)

;; Initialize contract
(try! (register-institution "Contract Admin"))