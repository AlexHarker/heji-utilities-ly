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

heji-relative =
#(define-music-function (note ratio) (pitch-event? rational?)
    (let*
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (* ratio (pitch-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch)))))
         #{ \heji-render #note #heji-pitch #} ))

heji-relative-normalised =
#(define-music-function (octave note ratio) ((integer? #f) pitch-event? rational?)
    (let*
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (* (expt 2 (if octave octave 0)) (normalise-ratio
                      (* ratio
                      (pitch-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch)))))))
         #{ \heji-render #note #heji-pitch #} ))

heji-alteration =
#(define-music-function (note alteration) (pitch-event? string?)
    (let*
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (pitch-and-alteration-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch) alteration)))
         #{ \heji-render #note #heji-pitch #} ))

heji-alteration-normalised =
#(define-music-function (octave note alteration) ((integer? #f) pitch-event? string?)
    (let*
        ((pitch (ly:music-property note 'pitch))
         (heji-pitch (* (expt 2 (if octave octave 0)) (normalise-ratio
                      (pitch-and-alteration-to-ratio (ly:pitch-notename pitch) (ly:pitch-octave pitch) (ly:pitch-alteration pitch) alteration)))))
         #{ \heji-render #note #heji-pitch #} ))

heji =
#(define-music-function (octave note ratio-or-alteration) ((integer? #f) pitch-event? rational-or-string?)
    (if (string? ratio-or-alteration)
        (if octave
            #{ \heji-alteration-normalised #octave #note #ratio-or-alteration #}
            #{ \heji-alteration #note #ratio-or-alteration #}
        )
        (if octave
            #{ \heji-relative-normalised #octave #note #ratio-or-alteration #}
            #{ \heji-relative #note #ratio-or-alteration #} )))