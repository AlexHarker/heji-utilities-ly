\version "2.24.1"

\include "../heji-ly/src/heji.ily"

#(add-to-load-path (dirname (current-filename)))
#(use-modules (heji-to-heji-ly) (heji-pitch-conversions))

heji-relative =
#(define-music-function (ratio note) (rational? ly:music?)
    (let* 
        ((event (if (eq? (ly:music-property note 'name) 'NoteEvent) note #f)))
        (if (not event)
            (begin
                (ly:music-warning note "heji-relative: expected a note event")
                (make-music 'Music 'void #t))
            (let* 
                ((pitch (ly:music-property event 'pitch))
                 (heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch))))
                 (heji-ly (ratio-to-heji-ly heji-pitch))
                 (alteration (cdr heji-ly)))
                (begin
                    (ly:music-set-property! note 'pitch (ly:make-pitch (cdar heji-ly) (caar heji-ly) 0))
                    #{ \ji #alteration #note #} )))))



