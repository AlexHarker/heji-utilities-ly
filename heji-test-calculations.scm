
;; N.B. current-filename is #f when evaluated in a REPL, so fall back to the working directory.
(add-to-load-path (if (current-filename) (dirname (current-filename)) (getcwd)))
(use-modules (heji-pitch-conversions) (heji-alterations))

(pitch-and-alteration-to-ratio 4 1 0 "u11o13+7^3")

(alteration-to-harmonic-space "u11 o13 +7^3")

(alteration-to-harmonic-space "u11o19+7")

(pitch-to-ratio 5 0 0)

(ratio-and-reference-to-pitch 1 5 0 0)
(ratio-and-reference-to-pitch 1 5 1 0)
(ratio-and-reference-to-pitch 1 5 2 0)
(ratio-and-reference-to-pitch 2 5 1 0)
(ratio-and-reference-to-pitch 3/2 5 2 0)
(ratio-and-reference-to-pitch 3/2 2 2 0)
(ratio-and-reference-to-pitch 81/80 5 2 0)
(ratio-and-reference-to-pitch 70805/41067 5 2 0)
(ratio-and-reference-to-pitch 212415/5537792 5 2 0)
(ratio-and-reference-to-pitch 10460353203/8589934592 5 2 0)
(ratio-and-reference-to-pitch 8589934592/10460353203 5 2 0)