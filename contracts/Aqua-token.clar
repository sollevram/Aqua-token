;; rainwater-credits.clar

;; ---------------------------------
;; Metadata
;; ---------------------------------
(define-constant TOKEN-NAME "Rainwater Credit")
(define-constant TOKEN-SYMBOL "RAIN")
(define-constant TOKEN-DECIMALS u2) ;; 2 decimals = centiliters
(define-fungible-token RAIN)
(define-data-var total-supply uint u0)

;; ---------------------------------
;; Admin
;; ---------------------------------
(define-data-var paused bool false)

(define-public (set-paused (flag bool))
  (begin
    (asserts! (is-eq tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) (err u100))
    (var-set paused flag)
    (ok flag)
  )
)

;; ---------------------------------
;; Provider Registry
;; ---------------------------------
(define-map providers
  { who: principal }
  { active: bool, region: (string-ascii 32) }
)

(define-public (add-provider (who principal) (region (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM) (err u100))
    (map-set providers { who: who } { active: true, region: region })
    (ok who)
  )
)

;; ---------------------------------
;; Issuance
;; ---------------------------------
(define-data-var next-batch-id uint u0)

(define-map batches
  { id: uint }
  {
    provider: principal,
    user: principal,
    volume: uint,
    region: (string-ascii 32),
    timestamp: uint
  }
)

(define-public (issue-credits (user principal) (volume uint))
  (let (
    (prov (map-get? providers { who: tx-sender }))
    (batch-id (+ (var-get next-batch-id) u1))
  )
    (begin
      (asserts! (is-some prov) (err u101))
      (asserts! (> volume u0) (err u102))
      (asserts! (is-ok (ft-mint? RAIN volume user)) (err u103))
      (var-set total-supply (+ (var-get total-supply) volume))
      (map-set batches { id: batch-id }
        {
          provider: tx-sender,
          user: user,
          volume: volume,
          region: (get region (unwrap! prov (err u101))),
          timestamp: stacks-block-height
        }
      )
      (var-set next-batch-id batch-id)
      (ok batch-id)
    )
  )
)

;; ---------------------------------
;; Retirement
;; ---------------------------------
(define-data-var next-retire-id uint u0)
(define-map retirements
  { id: uint }
  { user: principal, volume: uint, note: (string-ascii 48), timestamp: uint }
)

(define-public (retire-credits (volume uint) (note (string-ascii 48)))
  (let ((rid (+ (var-get next-retire-id) u1)))
    (begin
      (asserts! (> volume u0) (err u102))
      (asserts! (is-ok (ft-burn? RAIN volume tx-sender)) (err u104))
      (var-set total-supply (- (var-get total-supply) volume))
      (map-set retirements { id: rid }
        { user: tx-sender, volume: volume, note: note, timestamp: stacks-block-height })
      (var-set next-retire-id rid)
      (ok rid)
    )
  )
)

;; ---------------------------------
;; Views
;; ---------------------------------
(define-read-only (get-total-supply) (ok (var-get total-supply)))
(define-read-only (get-provider (who principal)) (map-get? providers { who: who }))
(define-read-only (get-batch (id uint)) (map-get? batches { id: id }))
(define-read-only (get-retirement (id uint)) (map-get? retirements { id: id }))
