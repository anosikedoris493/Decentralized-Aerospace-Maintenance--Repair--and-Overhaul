;; MRO Provider Verification Contract
;; Validates aerospace MRO providers

(define-data-var last-provider-id uint u0)

(define-map providers
  { provider-id: uint }
  {
    name: (string-ascii 100),
    address: (string-ascii 100),
    certification-expiry: uint,
    is-verified: bool,
    verification-date: uint,
    rating: uint
  }
)

(define-public (register-provider
                (name (string-ascii 100))
                (address (string-ascii 100))
                (certification-expiry uint))
  (let ((new-id (+ (var-get last-provider-id) u1)))
    (var-set last-provider-id new-id)
    (map-set providers
      { provider-id: new-id }
      {
        name: name,
        address: address,
        certification-expiry: certification-expiry,
        is-verified: false,
        verification-date: u0,
        rating: u0
      }
    )
    (ok new-id)
  )
)

(define-public (verify-provider (provider-id uint) (is-verified bool))
  (let ((provider (unwrap! (map-get? providers { provider-id: provider-id }) (err u404))))
    (map-set providers
      { provider-id: provider-id }
      (merge provider {
        is-verified: is-verified,
        verification-date: block-height
      })
    )
    (ok true)
  )
)

(define-public (update-provider-rating (provider-id uint) (rating uint))
  (let ((provider (unwrap! (map-get? providers { provider-id: provider-id }) (err u404))))
    (asserts! (<= rating u5) (err u400))
    (map-set providers
      { provider-id: provider-id }
      (merge provider { rating: rating })
    )
    (ok true)
  )
)

(define-read-only (get-provider (provider-id uint))
  (map-get? providers { provider-id: provider-id })
)

(define-read-only (is-provider-verified (provider-id uint))
  (default-to false (get is-verified (map-get? providers { provider-id: provider-id })))
)

(define-read-only (is-provider-certification-valid (provider-id uint))
  (let ((provider (map-get? providers { provider-id: provider-id })))
    (if (is-some provider)
      (> (default-to u0 (get certification-expiry provider)) block-height)
      false
    )
  )
)
