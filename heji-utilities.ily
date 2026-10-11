\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-to-heji-ly) (heji-pitch-conversions))

#(define heji-duration #f)
#(define last-default-duration #f)

makenote =
#(define-music-function (note) (ly:music?)
    #{ $note #} )

#(define (duration-or-false? obj)
  (or (not obj) (ly:duration? obj)))

heji-core =
#(define-music-function (heji-pitch-as-ratio duration) (rational? duration-or-false?)
    (let*
        ((heji-ly (ratio-to-heji-ly heji-pitch-as-ratio))
         (alteration (cdr heji-ly))
         (pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
         (current-duration (ly:music-property #{ \makenote $pitch #} 'duration))
         (this-duration (if duration duration (if (equal? current-duration last-default-duration) heji-duration current-duration)))
         (event (make-music 'NoteEvent 'pitch pitch 'duration this-duration)))
        (begin
            (display (list this-duration current-duration last-default-duration heji-duration))(newline)
            (set! heji-duration this-duration)
            (set! last-default-duration current-duration)
            #{ \ji #alteration #event #} )))

heji =
#(define-music-function (note duration alteration) (ly:pitch? (ly:duration? #f) string?)
    (let*
        ((heji-pitch (pitch-and-alteration-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note) alteration)))
        (begin
            #{ \heji-core #heji-pitch #duration #} )))

heji-relative =
#(define-music-function (note duration ratio) (ly:pitch? (ly:duration? #f) rational?)
    (let*
        ((heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note)))))
         (begin
            #{ \heji-core #heji-pitch #duration #} )))
