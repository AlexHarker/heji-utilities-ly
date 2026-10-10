(define-module (heji-alterations)
    #:export (alteration-to-harmonic-space))

(add-to-load-path (dirname (current-filename)))

(use-modules (ice-9 regex) (heji-constants) (heji-harmonic-space))

;; Find the index for a prime number in the heji-primes list.
;; The search starts from the supplied index. 
;; Returns #f if the value is not found.
(define (find-prime val idx)
    (cond 
        ((>= idx (length heji-primes)) #f) 
        ((= (list-ref heji-primes idx) val) idx)
        (else (find-prime val (+ idx 1)))))

;; Determine the direction factor (1 or -1) for a given prefix and prime index.
;; This function will resolve the direction of otonal/utonal prefixes based on the heji-otonal list.
;; If the prefix is unrecognized, it defaults to 1, but prefixes are validated in the code below.
(define (direction-factor prefix prime-index)
    (cond
        ((string=? prefix "+") 1)
        ((string=? prefix "-") -1)
        ((string=? prefix "u") (* (list-ref heji-otonal prime-index) -1))
        ((string=? prefix "o") (list-ref heji-otonal prime-index))
        (else 1)))

;; Regex for idenitifying alteration tokens and splitting an alteration string.
;; Tokens must be at the start of the string, which helps ensure the whole string is valid.
;; A token consists of u/o/+/- followed by an integer, which should be a prime number.
;; Optionally this can be followed by ^ and a second integer to indicate the exponent.
(define alteration-regex (make-regexp "^([uo+\\-])([0-9]+)(\\^[0-9]+)?"))

;; Split a string into a list of alteration tokens. 
;; Returns #f if the string cannot be matched in its entirety.
;; This function doesn't validate the numbers within tokens.
(define (split-alteration str tokens)
    (let* ((trimmed (string-trim str))
           (m (regexp-exec alteration-regex trimmed)))
        (cond
            ((= (string-length trimmed) 0) (reverse tokens))
            (m (split-alteration
                (substring trimmed (match:end m) (string-length trimmed))
                (cons (match:substring m) tokens)))
            (else #f))))

;; Convert an alteration string to a list of factors corresponding to the Tenney harmonic space as covered by the heji-primes
;; Returns the factors list if successful, or #f if the alteration string is invalid.
(define (alteration-to-harmonic-space alteration)
    (define (parse-ex ex) (if ex (string->number (substring ex 1)) 1))
    (define elements (split-alteration alteration '()))
    (define factors (make-list (length heji-primes) 0))
    (if elements
        (for-each (lambda (token)
            (let* 
                ((matched (regexp-exec alteration-regex token))
                 (prefix (match:substring matched 1))
                 (prime (string->number (match:substring matched 2)))
                 (exponent (parse-ex (match:substring matched 3)))
                 (prime-index (find-prime  prime 0)))
                (if (and prime-index (>= prime-index 1))
                    (let 
                        ((direction (direction-factor prefix prime-index)))
                        (list-set! factors prime-index (+ (list-ref factors prime-index) (* direction exponent))))
                    #f)))
                elements)) 
            factors)
