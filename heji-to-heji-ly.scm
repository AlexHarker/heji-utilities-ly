(define-module (heji-to-heji-ly)
    #:export (harmonic-space-to-heji-ly-alteration ratio-to-heji-ly))

(add-to-load-path (dirname (current-filename)))

(use-modules (heji-constants)(heji-harmonic-space) (heji-pitch-conversions))

(define (harmonic-space-to-heji-ly-alteration factors)
    (define tokens '())
    (for-each 
        (lambda (factor prime)
            (if (and (> prime 3) (not (= factor 0)))
                (let ((prefix (if (> factor 0) "o" "u"))
                      (exponent (abs factor)))
                    (set! tokens 
                        (cons 
                            (string-append prefix 
                                (number->string prime) 
                                (if (> exponent 1) 
                                    (string-append "^" (number->string exponent)) 
                                    ""))
                            tokens)))))
        factors heji-primes)
    (let ((ts (reverse tokens)))
        (if (null? ts)
            ""
            (apply string-append
                   (cons (car ts)
                         (map (lambda (token)
                                (string-append " " token))
                              (cdr ts)))))))

(define (harmonic-space-to-heji-ly factors)
    (let*
        ((pitch-info (ratio-and-reference-to-pitch (harmonic-space-to-ratio factors) 0 0 0))
         (pitch (car pitch-info))
         (octave (cadr pitch-info))
         (alter (caddr pitch-info))
         (tertial (inexact->exact (round (* 2 alter))))
         (tertial-alteration
            (if (= tertial 0)
                ""
                (string-append
                    (if (> tertial 0) "o" "u")
                    "3"
                    (if (> (abs tertial) 1)
                        (string-append "^" (number->string (abs tertial)))
                        ""))))
         (factor-alteration (harmonic-space-to-heji-ly-alteration factors))
         (alteration (string-append tertial-alteration " " factor-alteration)))
         (cons (cons pitch octave) alteration)))

(define (ratio-to-heji-ly ratio)
    (harmonic-space-to-heji-ly (ratio-to-harmonic-space ratio)))
