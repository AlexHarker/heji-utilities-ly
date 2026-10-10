(define-module (heji-pitch-conversions)
    #:export (pitch-to-ratio pitch-and-alteration-to-ratio ratio-and-reference-to-pitch))

(add-to-load-path (dirname (current-filename)))

(use-modules (heji-constants) (heji-harmonic-space) (heji-alterations))

;; This file contains functions for converting between pitch and ratio representations of notes.

; Take a pitch (0-6), an octave (0-6), and an alter factior (in wholetones) and return a ratio.
(define (pitch-to-ratio pitch octave alter)
    (if (and (and (>= pitch 0) (<= pitch 6) (integer? (* alter 2))))
        (* (expt 2 octave) (list-ref note-ratios pitch) (expt 2187/2048 (* alter 2)))
        #f))

; Take a pitch (0-6), an octave (0-6), and an alter factior (in wholetones) plus an algeration and return a ratio.
(define (pitch-and-alteration-to-ratio pitch octave alter alteration)
    (define factors (alteration-to-harmonic-space alteration))
    (if (and (and (>= pitch 0) (<= pitch 6) (integer? (* alter 2)) factors))
        (begin
            (list-set! factors 0 (+ (list-ref factors 0) octave))
            (list-set! factors 1 (+ (list-ref factors 1) (* alter 2)))
            (* (list-ref note-ratios pitch) (harmonic-space-to-ratio factors)))
        #f))

;; Note that num-octaves-per-prime keeps factors of 2 and 3 separate and we evaluate both to get the final octave. 
(define (ratio-and-reference-to-pitch ratio pitch octave alter)
    (define num-fifths-per-prime '(0 1 4 -2 -1 3 7 -3 6 -2 0 2 4 -1 1))
    (define num-octaves-per-prime '(1 0 -4 6 5 -1 -7 9 -5 8 5 4 -1 7 4))    
    (let* 
        ((final-ratio (* ratio (pitch-to-ratio pitch octave alter)))
         (factors (ratio-to-harmonic-space final-ratio))
         (fifths-sum (apply + (map * factors num-fifths-per-prime)))
         (octaves-sum (apply + (map * factors num-octaves-per-prime)))
         (pitch (modulo (* fifths-sum 4) 7))
         (octave (+ octaves-sum (inexact->exact (floor (/ (log (expt 3 fifths-sum)) (log 2))))))
         (alter (/ (floor (/ (+ fifths-sum 1) 7)) 2))) ;; Need to check the offset
        (cons pitch (list octave alter))))