(define-module (heji-core)
    #:export (heji-primes heji-ratios heji-otonal note-ratios sum-of-ratios))

;; A list of valid primes for the heji system.
(define heji-primes '(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47))

;; A list of ratios corresponding to the heji accidentals/commas.
(define heji-ratios '(2 2187/2048 81/80 64/63 33/32 27/26 2187/2176 513/512 736/729 261/256 32/31 37/36 82/81 129/128 48/47))

;; A list of otonal/utonal values corresponding to the directon of alteration for the otonal series
(define heji-otonal '(1 1 -1 -1 1 -1 -1 1 1 1 -1 1 1 1 -1))

;; A list of ratios corresponding to the seven diatonic pitches in the heji system.
(define note-ratios '(1 9/8 81/64 4/3 3/2 27/16 243/128))

;; Helper function to sum ratios for a given list of ratios and exponents,
;; This is most like to be used for summing exponents of the heji-primes or heji-ratios.
(define (sum-of-ratios ratios exponents)
    (if (null? ratios)
        1
        (* (expt (car ratios) (car exponents)) (sum-of-ratios (cdr ratios) (cdr exponents)))))