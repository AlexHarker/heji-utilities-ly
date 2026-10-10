(define-module (heji-harmonic-space)
    #:export (ratio-to-harmonic-space harmonic-space-to-ratio))

(add-to-load-path (dirname (current-filename)))

(use-modules (heji-constants))

;; Factorise an integer into its constituent prime factors;
;; Returns a list of the exponents of the primes in heji-primes.
(define (integer-to-prime-factorization n)
    (define (factorize n primes factors)
        (cond
            ((and (= n 1) (null? primes)) (cdr factors))
            ((null? primes) (error "Ran out of primes before fully factorizing"))
            (else
                (let ((p (car primes)))
                    (if (= (modulo n p) 0)
                        (factorize (/ n p) primes (cons (+ (car factors) 1) (cdr factors)))
                        (factorize n (cdr primes) (cons 0 factors)))))))
    (reverse (factorize n heji-primes '(0))))

;; Convert a ratio to a list of factors corresponding to the Tenney harmonic space as covered by the heji-primes
(define (ratio-to-harmonic-space ratio)
    (define n-factors (integer-to-prime-factorization (numerator ratio)))
    (define d-factors (integer-to-prime-factorization (denominator ratio)))
    (map (lambda (n d) (- n d)) n-factors d-factors))

;; Convert a list of factors corresponding to the Tenney harmonic space as covered by the heji-primes to a ratio
(define (harmonic-space-to-ratio factors)
    (define (product-of-ratios ratios exponents)
        (if (null? ratios)
            1
            (* (expt (car ratios) (car exponents))
               (product-of-ratios (cdr ratios) (cdr exponents)))))
    (product-of-ratios heji-ratios factors))



