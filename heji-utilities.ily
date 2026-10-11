\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-to-heji-ly) (heji-pitch-conversions))

#(define (pitch-event? x)
    (and (ly:music? x) (eq? (ly:music-property x 'name) 'NoteEvent)))

heji-core =
#(define-music-function (note heji-pitch) (pitch-event? rational?)
    (let* 
        ((heji-ly (ratio-to-heji-ly heji-pitch))
         (alteration (cdr heji-ly)))
        (begin
            (ly:music-set-property! note 'pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
            #{ \ji #alteration #note #} )))

heji-relative =
#(define-music-function (note ratio) (pitch-event? rational?)
    (let* 
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch)))))
         #{ \heji-core #note #heji-pitch #} ))

heji =
#(define-music-function (note alteration) (pitch-event? string?)
    (let* 
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (pitch-and-alteration-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch) alteration)))
         #{ \heji-core #note #heji-pitch #} ))




