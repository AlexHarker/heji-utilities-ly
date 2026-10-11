\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-core) (heji-to-heji-ly) (heji-pitch-conversions))

#(define (pitch-event? x)
    (and (ly:music? x) (eq? (ly:music-property x 'name) 'NoteEvent)))

#(define (heji-note-event? x)
    (and (pitch-event? x) (ly:music-property x 'alteration #f)))

#(define (rational-or-string? x)
    (or (rational? x) (string? x)))

heji-direct =
#(define-music-function (note) (heji-note-event?)
    (let*
        ((alteration (ly:music-property note 'alteration)))
        ( begin
            (ly:music-set-property! note 'tweaks #f)
            #{ \ji #alteration #note #} )))

heji-render =
#(define-music-function (note heji-pitch) (pitch-event? rational?)
    (let*
        ((heji-ly (ratio-to-heji-ly heji-pitch))
         (alteration (cdr heji-ly)))
        (begin
            (ly:music-set-property! note 'pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
            (ly:music-set-property! note 'alteration alteration)
            #{ \ji #alteration #note #} )))

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
         #{ \heji-render #heji-pitch #duration #} ))

heji-alteration =
#(define-music-function (note duration alteration) (ly:pitch? (ly:duration? #f) string?)
    (let*
        ((heji-pitch (pitch-and-alteration-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note) alteration)))
         #{ \heji-render #heji-pitch #duration #} ))

heji =
#(define-music-function (pitch duration ratio-or-alteration) (ly:pitch? (ly:duration? #f) rational-or-string?)
    (if (string? ratio-or-alteration)
        (if duration
            #{ \heji-alteration #pitch #duration #ratio-or-alteration #}
            #{ \heji-alteration #pitch #ratio-or-alteration #})
        (if duration
            #{ \heji-relative #pitch #duration #ratio-or-alteration #}
            #{ \heji-relative #pitch #ratio-or-alteration #})))

heji-n =
#(define-music-function (pitch duration ratio) (ly:pitch? (ly:duration? #f) rational?)
    (let*
         ((heji-pitch (normalise-ratio (* ratio (pitch-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch))))))
         #{ \heji-render #heji-pitch #duration #} ))