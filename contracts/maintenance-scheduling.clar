;; Maintenance Scheduling Contract
;; Schedules aerospace maintenance

(define-data-var last-maintenance-id uint u0)

(define-map maintenance-schedules
  { maintenance-id: uint }
  {
    aircraft-id: (string-ascii 50),
    provider-id: uint,
    scheduled-date: uint,
    completion-date: uint,
    status: (string-ascii 20),
    description: (string-ascii 200),
    priority: uint
  }
)

(define-public (schedule-maintenance
                (aircraft-id (string-ascii 50))
                (provider-id uint)
                (scheduled-date uint)
                (description (string-ascii 200))
                (priority uint))
  (let ((new-id (+ (var-get last-maintenance-id) u1)))
    (var-set last-maintenance-id new-id)
    (map-set maintenance-schedules
      { maintenance-id: new-id }
      {
        aircraft-id: aircraft-id,
        provider-id: provider-id,
        scheduled-date: scheduled-date,
        completion-date: u0,
        status: "scheduled",
        description: description,
        priority: priority
      }
    )
    (ok new-id)
  )
)

(define-public (update-maintenance-status
                (maintenance-id uint)
                (status (string-ascii 20))
                (completion-date uint))
  (let ((maintenance (unwrap! (map-get? maintenance-schedules { maintenance-id: maintenance-id }) (err u404))))
    (map-set maintenance-schedules
      { maintenance-id: maintenance-id }
      (merge maintenance {
        status: status,
        completion-date: completion-date
      })
    )
    (ok true)
  )
)

(define-read-only (get-maintenance (maintenance-id uint))
  (map-get? maintenance-schedules { maintenance-id: maintenance-id })
)

(define-read-only (get-maintenance-status (maintenance-id uint))
  (default-to "unknown" (get status (map-get? maintenance-schedules { maintenance-id: maintenance-id })))
)

(define-read-only (is-maintenance-overdue (maintenance-id uint))
  (let ((maintenance (map-get? maintenance-schedules { maintenance-id: maintenance-id })))
    (if (is-some maintenance)
      (and
        (> block-height (default-to u0 (get scheduled-date maintenance)))
        (not (is-eq (default-to "unknown" (get status maintenance)) "completed"))
      )
      false
    )
  )
)
