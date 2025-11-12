;; Genomic Data Marketplace
;; Implements a decentralized marketplace for genomic data

(define-constant error-not-authorized (err u1))
(define-constant error-invalid-dataset (err u2))
(define-constant error-already-processed (err u3))
(define-constant error-payment-failed (err u4))
(define-constant error-invalid-params (err u5))
(define-constant error-invalid-price (err u6))
(define-constant error-invalid-request (err u7))
(define-constant error-researcher-not-found (err u8))
(define-constant error-invalid-score (err u9))

(define-constant maximum-price u1000000000000)
(define-constant maximum-request-id u1000000)

(define-data-var next-dataset-id uint u0)

(define-map dataset-registry
    uint
    {
        dataset-owner: principal,
        encrypted-data-hash: (string-utf8 256),
        metadata-hash: (string-utf8 256),
        dataset-price: uint,
        is-available: bool
    }
)

(define-map dataset-access-registry {dataset-id: uint, researcher-principal: principal} bool)

(define-map researcher-registry
    principal
    {
        researcher-name: (string-utf8 100),
        institution: (string-utf8 100),
        credentials: (string-utf8 256),
        is-verified: bool,
        reputation-score: uint
    }
)

(define-map access-request-registry
    {dataset-id: uint, request-id: uint}
    {
        researcher-principal: principal,
        is-approved: bool,
        is-processed: bool
    }
)

(define-map researcher-contribution-registry principal uint)

(define-data-var contract-owner-address principal tx-sender)

(define-private (validate-price (price uint))
    (and (> price u0) (<= price maximum-price)))

(define-private (validate-request-id (request-id uint))
    (<= request-id maximum-request-id))

(define-private (validate-researcher (researcher-principal principal))
    (is-some (map-get? researcher-registry researcher-principal)))

(define-private (validate-score (score uint))
    (<= score u100))

(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner-address)))

(define-public (register-dataset 
    (encrypted-data-hash (string-utf8 256))
    (metadata-hash (string-utf8 256))
    (dataset-price uint))
    (let
        ((dataset-id (var-get next-dataset-id)))
        (asserts! (validate-price dataset-price) error-invalid-price)
        (asserts! (and
            (> (len encrypted-data-hash) u0)
            (> (len metadata-hash) u0))
            error-invalid-params)
        
        (begin
            (map-set dataset-registry dataset-id
                {
                    dataset-owner: tx-sender,
                    encrypted-data-hash: encrypted-data-hash,
                    metadata-hash: metadata-hash,
                    dataset-price: dataset-price,
                    is-available: true
                })
            (var-set next-dataset-id (+ dataset-id u1))
            (ok dataset-id))))

(define-public (register-researcher 
    (researcher-name (string-utf8 100))
    (institution (string-utf8 100))
    (credentials (string-utf8 256)))
    (if (and
            (> (len researcher-name) u0)
            (> (len institution) u0)
            (> (len credentials) u0))
        (begin
            (map-set researcher-registry tx-sender
                {
                    researcher-name: researcher-name,
                    institution: institution,
                    credentials: credentials,
                    is-verified: false,
                    reputation-score: u0
                })
            (ok true))
        error-invalid-params))

(define-public (request-access (dataset-id uint))
    (let ((dataset (unwrap! (map-get? dataset-registry dataset-id) error-invalid-dataset)))
        (if (get is-available dataset)
            (begin
                (map-set access-request-registry 
                    {dataset-id: dataset-id, request-id: u0}
                    {
                        researcher-principal: tx-sender,
                        is-approved: false,
                        is-processed: false
                    })
                (ok true))
            error-invalid-dataset)))

(define-public (approve-access (dataset-id uint) (request-id uint))
    (let
        (
            (dataset (unwrap! (map-get? dataset-registry dataset-id) error-invalid-dataset))
            (request (unwrap! (map-get? access-request-registry {dataset-id: dataset-id, request-id: request-id}) error-invalid-dataset))
        )
        (asserts! (validate-request-id request-id) error-invalid-request)
        (asserts! (and
            (is-eq (get dataset-owner dataset) tx-sender)
            (not (get is-processed request)))
            error-not-authorized)
        
        (begin
            (map-set access-request-registry
                {dataset-id: dataset-id, request-id: request-id}
                {
                    researcher-principal: (get researcher-principal request),
                    is-approved: true,
                    is-processed: true
                })
            (map-set dataset-access-registry
                {dataset-id: dataset-id, researcher-principal: (get researcher-principal request)}
                true)
            (ok true))))

(define-public (verify-researcher (researcher-principal principal))
    (begin
        (asserts! (is-contract-owner) error-not-authorized)
        (asserts! (validate-researcher researcher-principal) error-researcher-not-found)
        
        (match (map-get? researcher-registry researcher-principal)
            researcher-data (begin
                (map-set researcher-registry researcher-principal
                    (merge researcher-data {is-verified: true}))
                (ok true))
            error-invalid-params)))

(define-public (update-reputation (researcher-principal principal) (score uint))
    (begin
        (asserts! (is-contract-owner) error-not-authorized)
        (asserts! (validate-researcher researcher-principal) error-researcher-not-found)
        (asserts! (validate-score score) error-invalid-score)
        
        (match (map-get? researcher-registry researcher-principal)
            researcher-data (begin
                (map-set researcher-registry researcher-principal
                    (merge researcher-data {reputation-score: score}))
                (ok true))
            error-invalid-params)))

(define-read-only (get-dataset-details (dataset-id uint))
    (map-get? dataset-registry dataset-id))

(define-read-only (get-researcher-profile (researcher-principal principal))
    (map-get? researcher-registry researcher-principal))

(define-read-only (get-access-status (dataset-id uint) (researcher-principal principal))
    (default-to false
        (map-get? dataset-access-registry {dataset-id: dataset-id, researcher-principal: researcher-principal})))