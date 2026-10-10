\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-to-heji-ly) (heji-pitch-conversions))

heji =
#(define-music-function (note alteration) (ly:music? string?)
    #{ \ji #alteration $note #} )

makenote =
#(define-music-function (note) (ly:music?)
    #{ $note #} )

#(define heji-duration #f)
#(define last-default-duration #f)

heji-relative =
#(define-music-function (note duration ratio) (ly:pitch?  (ly:duration? #f) rational?)
    (let*
        ((heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename note) (ly:pitch-octave note) (ly:pitch-alteration note))))
         (heji-ly (ratio-to-heji-ly heji-pitch))
         (alteration (cdr heji-ly))
         (pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
         (current-duration (ly:music-property #{ \makenote $pitch #} 'duration))
         (this-duration (if duration duration (if (equal? current-duration last-default-duration) heji-duration current-duration)))
         (event (make-music 'NoteEvent 'pitch pitch 'duration this-duration)))
        (begin 
            (set! heji-duration this-duration)
            (set! last-default-duration current-duration)
            #{ \heji #event #alteration #} )))



