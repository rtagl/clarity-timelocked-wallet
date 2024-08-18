
;; title: timelocked-wallet
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant contract-owner tx-sender)

;; errors
(define-constant ERR_NOT_OWNER (err u100))
(define-constant ERR_ALREADY_LOCKED (err u101))
(define-constant ERR_UNLOCK_IN_PAST (err u102))
(define-constant ERR_NO_VALUE (err u103))
(define-constant ERR_BENEFICIARY_ONLY (err u104))
(define-constant ERR_UNLOCK_HEIGHT_NOT_REACHED (err u105))

;; data
(define-data-var beneficiary (optional principal) none)
(define-data-var unlock-height uint u0)


;; data vars
;;

;; data maps
;;

;; public functions
;;

(define-public (lock (new-beneficiary principal) (unlock-at uint) (amount uint))
    (begin
        (asserts! (is-eq contract-caller contract-owner) ERR_NOT_OWNER)
        (asserts! (is-none (var-get beneficiary)) ERR_ALREADY_LOCKED)
        (asserts! (> unlock-at block-height) ERR_UNLOCK_IN_PAST)
        (asserts! (> amount u0) ERR_NO_VALUE)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set beneficiary (some new-beneficiary))
        (var-set unlock-height unlock-at)
        (ok true)
    )
)

(define-public (bestow (new-beneficiary principal))
    (begin
        (asserts! (is-eq (some contract-caller) (var-get beneficiary)) ERR_BENEFICIARY_ONLY)
        (var-set beneficiary (some new-beneficiary))
        (ok true)
    )
)

(define-public (claim)
    (begin
        (asserts! (is-eq (some contract-caller) (var-get beneficiary)) ERR_BENEFICIARY_ONLY)
        (asserts! (>= block-height (var-get unlock-height)) ERR_UNLOCK_HEIGHT_NOT_REACHED)
        (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (unwrap-panic (var-get beneficiary))))
    )
)


;; read only functions
;;

;; private functions
;;

