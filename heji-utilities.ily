\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-to-heji-ly) (heji-pitch-conversions))

#(define heji-duration #f)
#(define last-default-duration #f)

heji-makenote =
#(define-music-function (note) (ly:music?)
    #{ $note #} )

#(define (duration-or-false? obj)
    (or (not obj) (ly:duration? obj)))

#(define (rational-or-string? obj)
    (or (rational? obj) (string? obj)))

heji-render =
#(define-music-function (heji-pitch-as-ratio duration) (rational? duration-or-false?)
    (let*
        ((heji-ly (ratio-to-heji-ly heji-pitch-as-ratio))
         (alteration (cdr heji-ly))
         (pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
         (current-duration (ly:music-property #{ \heji-makenote $pitch #} 'duration))
         (this-duration (if duration duration (if (equal? current-duration last-default-duration) heji-duration current-duration)))
         (event (make-music 'NoteEvent 'pitch pitch 'duration this-duration)))
        (begin
            (set! heji-duration this-duration)
            (set! last-default-duration current-duration)
            #{ \ji #alteration #event #} )))

heji-relative =
#(define-music-function (note duration ratio) (ly:pitch? (ly:duration? #f) rational?)
    (let*
        ((heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note)))))
         (begin
            #{ \heji-render #heji-pitch #duration #} )))

heji-alteration =
#(define-music-function (note duration alteration) (ly:pitch? (ly:duration? #f) string?)
    (let*
        ((heji-pitch (pitch-and-alteration-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note) alteration)))
        (begin
            #{ \heji-render #heji-pitch #duration #} )))

heji =
#(define-music-function (note duration ratio-or-alteration) (ly:pitch? (ly:duration? #f) rational-or-string?)
    (if (string? ratio-or-alteration)
        (if duration
            #{ \heji-alteration #note #duration #ratio-or-alteration #}
            #{ \heji-alteration #note #ratio-or-alteration #})
        (if duration
            #{ \heji-relative #note #duration #ratio-or-alteration #}
            #{ \heji-relative #note #ratio-or-alteration #})))