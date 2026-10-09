
(define heji-primes '(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47))
(define heji-ratios '(2 2187/2048 81/80 64/63 33/32 27/26 2187/2176 513/512 736/729 261/256 32/31 37/36 82/81 129/128 48/47))
(define heji-otonal '(1 1 -1 -1 1 -1 -1 1 1 1 -1 1 1 1 -1))
(define note-ratios '(1 9/8 81/64 4/3 3/2 27/16 243/128))

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

(define (ratio-to-harmonic-space ratio)
    (define n-factors (integer-to-prime-factorization (numerator ratio)))
    (define d-factors (integer-to-prime-factorization (denominator ratio)))
    (map (lambda (n d) (- n d)) n-factors d-factors))

(define (harmonic-space-to-ratio factors)
    (define (product-of-ratios ratios exponents)
        (if (null? ratios)
            1
            (* (expt (car ratios) (car exponents))
               (product-of-ratios (cdr ratios) (cdr exponents)))))
    (product-of-ratios heji-ratios factors))

;; Regex for an alteration token
;; the token must be at the start of the string.
;; It consists of u/o/+/- followed by an integer,
;; optionally followed by ^ and a second integer.
(define alteration-regex (make-regexp "^([uo+\\-])([0-9]+)(\\^[0-9]+)?"))

;; Split a string into a list of alteration tokens. Returns #f if the string does not match in its entirety.
(define (split-alteration str tokens)
    (let* ((trimmed (string-trim str))
           (m (regexp-exec alteration-regex trimmed)))
        (cond
            ((= (string-length trimmed) 0) (reverse tokens))
            (m (split-alteration
                (substring trimmed (match:end m) (string-length trimmed))
                (cons (match:substring m) tokens)))
            (else #f))))

;; Find the index of a numerical value in a list. 
;; Returns #f if the value is not found.
(define (find-value ls val idx)
    (cond 
        ((null? ls) #f) 
        ((= (car ls) val) idx)
        (else (find-value (cdr ls) val (+ idx 1)))))

;; Determine the multiplication factor for a given prefix and prime index.
(define (mul-factor prefix prime-index)
    (cond
        ((string=? prefix "+") 1)
        ((string=? prefix "-") -1)
        ((string=? prefix "u") (* (list-ref heji-otonal prime-index) -1))
        ((string=? prefix "o") (list-ref heji-otonal prime-index))
        (else 1)))

;; Convert an alteration string to a list of factors corresponding to the heji factors
(define (alteration-to-factors alteration)
    (define (parse-ex ex) (if ex (string->number (substring ex 1)) 1))
    (define elements (split-alteration alteration '()))
    (define factors (make-list (length heji-primes) 0))
    (if elements
        (for-each (lambda (token)
            (let* 
                ((matched (regexp-exec alteration-regex token))
                 (prefix (match:substring matched 1))
                 (prime (string->number (match:substring matched 2)))
                 (ex (parse-ex (match:substring matched 3)))
                 (prime-index (find-value heji-primes prime 0)))
                (if (and prime-index (>= prime-index 1))
                    (let 
                        ((mul (mul-factor prefix prime-index)))
                        (list-set! factors prime-index (+ (list-ref factors prime-index) (* mul ex))))
                    #f)))
                elements)) 
            factors)

; Take a pitch (0-6), an octave (0-6), and an alter factior (in wholetones) and return a ratio.
(define (pitch-to-ratio pitch octave alter)
    (if (and (and (>= pitch 0) (<= pitch 6) (integer? (* alter 2))))
        (* (expt 2 octave) (list-ref note-ratios pitch) (expt 2187/2048 (* alter 2)))
        #f))

; Take a pitch (0-6), an octave (0-6), and an alter factior (in wholetones) plus an algeration and return a ratio.
(define (pitch-and-alteration-to-ratio pitch octave alter alteration)
    (define factors (alteration-to-factors alteration))
    (if (and (and (>= pitch 0) (<= pitch 6) (integer? (* alter 2)) factors))
        (begin
            (list-set! factors 0 (+ (list-ref factors 0) octave))
            (list-set! factors 1 (+ (list-ref factors 1) (* alter 2)))
            (* (list-ref note-ratios pitch) (harmonic-space-to-ratio factors)))
        #f))

(define (ratio-and-reference-to-pitch ratio pitch octave alter)
    (define num-fifths-per-prime '(0 1 4 -2 -1 3 7 -3 6 -2 0 2 4 -1 1))
    (let* 
        ((final-ratio (* ratio (pitch-to-ratio pitch octave alter)))
         (factors (ratio-to-harmonic-space final-ratio))
         (fifths (map * factors num-fifths-per-prime))
         (fifths-sum (apply + fifths))
         (pitch (modulo (* fifths-sum 4) 7))
         (octave (inexact->exact (floor (/ (log final-ratio) (log 2)))))
         (alter (/ (floor (/ (+ fifths-sum 1) 7)) 2))) ;; Need to check the offset
        (cons pitch (list octave alter))))
    
(pitch-and-alteration-to-ratio 4 1 0 "u11o13+7^3")

(alteration-to-factors "u11 o13 +7^3")

(alteration-to-factors "u11o19+7")

(ratio-and-reference-to-pitch 1 5 0 0)
(ratio-and-reference-to-pitch 1 5 1 0)
(ratio-and-reference-to-pitch 1 5 2 0)
(ratio-and-reference-to-pitch 2 5 1 0)
(ratio-and-reference-to-pitch 3/2 5 2 0)
(ratio-and-reference-to-pitch 81/80 5 2 0)
(ratio-and-reference-to-pitch 70805/41067 5 2 0)
(ratio-and-reference-to-pitch 212415/5537792 5 2 0)
(ratio-and-reference-to-pitch 10460353203/8589934592 5 2 0)
(ratio-and-reference-to-pitch 8589934592/10460353203 5 2 0)
