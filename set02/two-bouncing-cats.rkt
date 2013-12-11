;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname two-bouncing-cats) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; two bouncing cats.
;; like draggable cats, but there are TWO cats.  They are individually
;; draggable.  But space pauses or unpauses the entire system.

;; draggable cat.
;; like falling cat, but user can drag the cat with the mouse.
;; button-down to select, drag to move, button-up to release.

;; falling cat.  
;; A cat falls from the top of the scene.
;; The user can pause/unpause the cat with the space bar.

;; start with (main 0)

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")

(provide initial-world)
(provide world-after-key-event)
(provide world-after-mouse-event)
(provide cat-north?)
(provide cat-south?)
(provide cat-east?)
(provide cat-west?)
(provide world-cat1)
(provide world-cat2)
(provide world-paused?)
(provide cat-x-pos)
(provide cat-y-pos)
(provide cat-selected?)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; MAIN FUNCTION.

;; main : Number -> World
;; GIVEN: the initial y-position of the cats
;; EFFECT: runs the simulation, starting with the cats falling
;; RETURNS: the final state of the world
(define (main initial-pos)
  (big-bang (initial-world initial-pos)
            (on-tick world-after-tick 0.5)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

(define CAT-IMAGE (bitmap "cat.png"))
(define BOUNCE-PADDING 1)

;; how fast the cat falls, in pixels/tick
(define CATSPEED 8)

;; dimensions of the canvas
(define CANVAS-WIDTH 450)
(define CANVAS-HEIGHT 400)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define CAT1-X-COORD (/ CANVAS-WIDTH 3))
(define CAT2-X-COORD (* 2 CAT1-X-COORD))

;; dimensions of the cat
(define HALF-CAT-WIDTH  (/ (image-width  CAT-IMAGE) 2))
(define HALF-CAT-HEIGHT (/ (image-height CAT-IMAGE) 2))

;; MAGIC CONSTANTS
;; Image dimensions check
(define IMAGE-HEIGHT-CHECK (- CANVAS-HEIGHT HALF-CAT-HEIGHT))
(define IMAGE-WIDTH-CHECK (- CANVAS-WIDTH HALF-CAT-WIDTH))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS

; Direcion is one of
; --NORTH : The North direction
; --SOUTH : The South direction
; --EAST  : The East direction
; --WEST  : The South direction

; TEMPLATE
;(define (direction-fn direction)
;  (cond
;    [(string=? direction NORTH ...)]
;    [(string=? direction SOUTH ...)]
;    [(string=? direction EAST ...)]
;    [(string=? direction WEST ...)]))


(define-struct world (cat1 cat2 paused?))
;; A World is a (make-world Cat Cat Boolean)
;; cat1 and cat2 are the two cats
;; paused? describes whether or not the world is paused

;; template:
;; world-fn : World -> ??
;; (define (world-fn w)
;;   (... (world-cat1 w) (world-cat2 w) (world-paused? w)))


(define-struct cat (x-pos y-pos selected? dir))
;; A Cat is a (make-cat Number Number Boolean)
;; Interpretation: 
;; x-pos, y-pos give the position of the cat. 
;; selected? describes whether or not the cat is selected.

;; template:
;; cat-fn : Cat -> ??
;(define (cat-fn c)
; (... (cat-x-pos w) (cat-y-pos w) (cat-selected? w)))


;; A BouncingCatKeyEvents is a KeyEvent, which is one of
;; -- " "                (interp: pause/unpause)
;; -- any other KeyEvent (interp: ignore)
;; -- "left"             (interp: turn left)
;; -- "right"            (interp: turn right)
;; -- "down"             (interp: turn down)
;; -- "up"               (interp: turn up)

;; template:
;; falling-cat-kev-fn : BouncingCatKeyEvents -> ??
;(define (falling-cat-kev-fn kev)
;  (cond
;    [(key=? kev "left")...]
;    [(key=? kev "right")...]
;    [(key=? kev "up")...]
;    [(key=? kev "down")...]
;    [(key=? kev " ")...]
;    [else w])

;; examples for testing
(define pause-key-event " ")
(define non-pause-key-event "q")   


;; A BouncingCatMouseEvents is a MouseEvent that is one of:
;; -- "button-down"   (interp: maybe select the cat)
;; -- "drag"          (interp: maybe drag the cat)
;; -- "button-up"     (interp: unselect the cat)
;; -- any other mouse event (interp: ignored)

;(define (mev-fn mev)
;  (cond
;    [(mouse=? mev "button-down") ...]
;    [(mouse=? mev "drag") ...]
;    [(mouse=? mev "button-up") ...]
;    [else ...]))

;;; END DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-tick : World -> World
;; GIVEN: a world w
;; RETURNS: the world that should follow w after a tick.
;; STRATEGY: structural decomposition on w : World
(define (world-after-tick w)
  (cond
    [(world-paused? w) w]
    [else (make-world
           (cat-after-tick (world-cat1 w))
           (cat-after-tick (world-cat2 w))
           (world-paused? w))]))


;; cat-after-tick : Cat -> Cat
;; GIVEN: a cat c
;; RETURNS: the state of the given cat after a tick if it were in an
;; unpaused world.

;; examples: 
;; cat selected
;; (cat-after-tick selected-cat-at-20) = selected-cat-at-20
;; cat paused:
;; (cat-after-tick unselected-cat-at-20) = unselected-cat-at-28

;; STRATEGY: structural decomposition on c : Cat

(define (cat-after-tick c)
  (if (cat-selected? c) 
      (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) (cat-dir c))
      (cat-after-tick-helper (cat-x-pos c) (cat-y-pos c) (cat-selected? c) (cat-dir c))))

;; tests: tests follow help function.

;; cat-after-tick-helper : Number Number Boolean -> Cat
;; GIVEN    : a position and a value for selected?
;; RETURNS  : the cat that should follow one in the given position in an
;;            unpaused world 
;; EXAMPLES : (cat-after-tick-helper 200 393 false "SOUTH")-> (make-cat 200 681/2 false "NORTH") 
;; STRATEGY: function composition
;; TESTS : presented at the end
(define (cat-after-tick-helper x-pos y-pos selected? dir)
  (cond
   [(string=? dir "SOUTH")(check-south-boundary  x-pos y-pos selected? dir)]
   [(string=? dir "NORTH")(check-north-boundary  x-pos y-pos selected? dir)]
   [(string=? dir "EAST")(check-east-boundary  x-pos y-pos selected? dir)]
   [(string=? dir "WEST")(check-west-boundary  x-pos y-pos selected? dir)]))


;; check-south-boundary : Number Number Boolean Direction -> Cat
;; GIVEN    : the x-coordinate, y-coordinate selected? and the direction of the cat
;; RETURNS  : the same cat with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : (check-south-boundary 460 300 true "SOUTH") ->(make-cat 460 308 true "SOUTH")
;; TESTS    : In the test suite
(define(check-south-boundary x-pos y-pos selected? dir)
  (if (or (> (+ y-pos CATSPEED) IMAGE-HEIGHT-CHECK) (> y-pos IMAGE-HEIGHT-CHECK))
      (make-cat x-pos (- IMAGE-HEIGHT-CHECK BOUNCE-PADDING) selected? "NORTH")
      (make-cat x-pos (+ y-pos CATSPEED) selected? dir)))

;; check-north-boundary : Number Number Boolean Direction -> Cat
;; GIVEN    : the x-coordinate, y-coordinate selected? and the direction of the cat
;; RETURNS  : the same cat with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : (check-north-boundary 10 40 true "NORTH")-> (make-cat 10 119/2 true "SOUTH")
;; TESTS    : In the test suite
(define(check-north-boundary x-pos y-pos selected? dir)
  (if (or (< y-pos HALF-CAT-HEIGHT) (< (- y-pos CATSPEED) HALF-CAT-HEIGHT))
      (make-cat x-pos (+ HALF-CAT-HEIGHT BOUNCE-PADDING) selected? "SOUTH")
      (make-cat x-pos (- y-pos CATSPEED) selected? dir)))

;; check-east-boundary : Number Number Boolean Direction -> Cat
;; GIVEN    : the x-coordinate, y-coordinate selected? and the direction of the cat
;; RETURNS  : the same cat with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : (check-east-boundary 400 300 true "EAST") -> (make-cat 408 300 true "EAST")
;; TESTS    : In the test suite
(define(check-east-boundary x-pos y-pos selected? dir)
  (if (or (> (+ x-pos CATSPEED) IMAGE-WIDTH-CHECK) (> x-pos IMAGE-WIDTH-CHECK))
      (make-cat (- IMAGE-WIDTH-CHECK BOUNCE-PADDING) y-pos  selected? "WEST")
      (make-cat (+ x-pos CATSPEED) y-pos selected? dir)))

;; check-west-boundary : Number Number Boolean Direction -> Cat
;; GIVEN    : the x-coordinate, y-coordinate selected? and the direction of the cat
;; RETURNS  : the same cat with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : (check-west-boundary 10 300 true "WEST")-> (make-cat 77/2 300 true "EAST")
;; TESTS    : In the test suite
(define(check-west-boundary x-pos y-pos selected? dir)
  (if (or (< x-pos HALF-CAT-WIDTH) (< (- x-pos CATSPEED) HALF-CAT-WIDTH))
      (make-cat (+ HALF-CAT-WIDTH BOUNCE-PADDING) y-pos  selected? "EAST")
      (make-cat (- x-pos CATSPEED) y-pos selected? dir)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-to-scene : World -> Scene
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world->scene (make-world 20 ??))
;;          = (place-image CAT-IMAGE CAT-X-COORD 20 EMPTY-CANVAS)
;; STRATEGY: structural decomposition w : World
(define (world-to-scene w)
  (place-cat
    (world-cat1 w)
    (place-cat
      (world-cat2 w)
      EMPTY-CANVAS)))

;; place-cat : Cat Scene -> Scene
;; GIVEN : a cat and a scene
;; RETURNS: a scene like the given one, but with the given cat painted
;; on it.
;; STRATEGY : FUNCTIONAL COMPOSITION
(define (place-cat c s)
  (place-image
    CAT-IMAGE
    (cat-x-pos c) (cat-y-pos c)
    s))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-key-event : World BouncingCatKeyEvents -> World
;; GIVEN: a world w
;; RETURNS: the world that should follow the given world
;; after the given key event.
;; on space, toggle paused?-- ignore all others
;; EXAMPLES: see tests below
;; STRATEGY: structural decomposition on kev : BouncingCatKeyEvents
(define (world-after-key-event w kev)
  (cond
    [(and (key=? kev "left") (not (world-paused? w)))
      (on-key-event-helper-for-left (world-cat1 w) (world-cat2 w))]
    [(and (key=? kev "right") (not (world-paused? w)))
      (on-key-event-helper-for-right (world-cat1 w) (world-cat2 w))]
    [(and (key=? kev "up") (not (world-paused? w)))
      (on-key-event-helper-for-up (world-cat1 w) (world-cat2 w))]
    [(and (key=? kev "down") (not (world-paused? w))) 
      (on-key-event-helper-for-down (world-cat1 w) (world-cat2 w))]
     [(key=? kev " ") (world-with-paused-toggled w)]
    [else w]))

;; world-with-paused-toggled : World -> World
;; GIVEN : a World 
;; RETURNS: a world just like the given one, but with paused? toggled
;; EXAMPLES : (world-with-paused-toggled (world-after-mouse-event 
;;                                         (make-world (make-cat 440 350 false "EAST")
;;                                                     (make-cat 440 350 false "SOUTH")
;;                                                     true) 50 50 "button-up")
;;                                         (make-world (make-cat 440 350 false "EAST")
;;                                         (make-cat 440 350 false "SOUTH")
;;                                         true)
;; STRATEGY: structural decomposition on w : World
(define (world-with-paused-toggled w)
  (make-world
   (world-cat1 w)
   (world-cat2 w)
   (not (world-paused? w))))

 
;; on-key-event-helper-for-left : Cat Cat -> World
;; GIVEN    : two cats moving in some directions
;; RETURNS  : a World with the selected cat moving in left direction
;; EXAMPLES : (on-key-event-helper-for-left (make-cat 100 100 true "SOUTH")
;;                                          (make-cat 300 10 false "WEST"))
;;                                          (make-world (make-cat 100 100 true "WEST") 
;;                                            (make-cat 300 10 false "WEST") false)
;; STRATEGY : FUNCTIONAL COMPOSITION
(define(on-key-event-helper-for-left c1 c2)
  (cond
  [(cat-selected? c1) (make-world (transformed-cat-left c1) c2 false)]
  [(cat-selected? c2) (make-world c1 (transformed-cat-left c2) false)]
  [else (make-world c1 c2 false)]))

;; on-key-event-helper-for-right : Cat Cat -> World
;; GIVEN    : two cats moving in some directions
;; RETURNS  : a World with the selected cat moving in right direction
;; EXAMPLES : (on-key-event-helper-for-left (make-cat 100 100 true "SOUTH") 
;;                                          (make-cat 300 10 false "WEST"))
;;                                          (make-world (make-cat 100 100 true "EAST")
;;                                          (make-cat 300 10 false "WEST") false)
;; STRATEGY : FUNCTIONAL COMPOSITION
(define(on-key-event-helper-for-right c1 c2)
  (cond
  [(cat-selected? c1) (make-world (transformed-cat-right c1) c2 false)]
  [(cat-selected? c2) (make-world c1 (transformed-cat-right c2) false)]
  [else (make-world c1 c2 false)]))

;; on-key-event-helper-for-up : Cat Cat -> World
;; GIVEN    : two cats moving in some directions
;; RETURNS  : a World with the selected cat moving in north direction
;; EXAMPLES : (on-key-event-helper-for-left (make-cat 100 100 true "SOUTH")
;;                                          (make-cat 300 10 false "WEST"))
;;                                          (make-world (make-cat 100 100 true "NORTH")
;;                                          (make-cat 300 10 false "WEST") false)
;; STRATEGY : FUNCTIONAL COMPOSITION
(define(on-key-event-helper-for-up c1 c2)
  (cond
  [(cat-selected? c1) (make-world (transformed-cat-up c1) c2 false)]
  [(cat-selected? c2) (make-world c1 (transformed-cat-up c2) false)]
  [else (make-world c1 c2 false)]))

;; on-key-event-helper-for-down : Cat Cat -> World
;; GIVEN    : two cats moving in some directions
;; RETURNS  : a World with the selected cat moving in south direction
;; EXAMPLES : (on-key-event-helper-for-left (make-cat 100 100 true "SOUTH") 
;;                                          (make-cat 300 10 false "WEST"))
;;                                          (make-world (make-cat 100 100 true "NORTH")
;;                                          (make-cat 300 10 false "WEST") false)
;; STRATEGY : FUNCTIONAL COMPOSITION
(define(on-key-event-helper-for-down c1 c2)
  (cond
  [(cat-selected? c1) (make-world (transformed-cat-down c1) c2 false)]
  [(cat-selected? c2) (make-world c1 (transformed-cat-down c2) false)]
  [else (make-world c1 c2 false)]))


;; transformed-cat-left : Cat -> Cat
;; GIVEN    : A selected cat
;; RETURNS  : The same cat but now having direction as WEST
;; EXAMPLES : (transformed-cat-left(make-cat 20 20 true "SOUTH"))
;;            -> (make-cat 20 20 true "WEST")
;; STRATEGY : STRUCTURAL DECOMPOSITION ON CAT
(define (transformed-cat-left c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "WEST"))

;; transformed-cat-right : Cat -> Cat
;; GIVEN    : A selected cat
;; RETURNS  : The same cat but now having direction as EAST
;; EXAMPLES : (transformed-cat-right(make-cat 20 20 true "SOUTH"))
;;            -> (make-cat 20 20 true "EAST")
;; STRATEGY : STRUCTURAL DECOMPOSITION ON CAT
(define (transformed-cat-right c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "EAST"))

;; transformed-cat-up : Cat -> Cat
;; GIVEN    : A selected cat
;; RETURNS  : The same cat but now having direction as NORTH
;; EXAMPLES : (transformed-cat-up(make-cat 20 20 true "SOUTH"))
;;            -> (make-cat 20 20 true "NORTH")
;; STRATEGY : STRUCTURAL DECOMPOSITION ON CAT
(define (transformed-cat-up c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "NORTH"))

;; transformed-cat-down : Cat -> Cat
;; GIVEN    : A selected cat
;; RETURNS  : The same cat but now having direction as SOUTH
;; EXAMPLES : (transformed-cat-down(make-cat 20 20 true "SOUTH"))
;;            -> (make-cat 20 20 true "SOUTH")
;; STRATEGY : STRUCTURAL DECOMPOSITION ON CAT
(define (transformed-cat-down c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "SOUTH"))

;; for world-after-key-event, we need 4 tests: a paused world, and an
;; unpaused world, and a pause-key-event and a non-pause key event/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-mouse-event : World Number Number BouncingCatMouseEvents -> World
;; GIVEN    : a world and a description of a mouse event
;; RETURNS  : the world that should follow the given mouse event
;; STRATEGY : FUNCTIONAL COMPOSITION
(define (world-after-mouse-event w mx my mev)
  (make-world
    (cat-after-mouse-event (world-cat1 w) mx my mev)
    (cat-after-mouse-event (world-cat2 w) mx my mev)
    (world-paused? w)))

;; cat-after-mouse-event : Cat Number Number BouncingCatMouseEvents -> Cat
;; GIVEN: a cat and a description of a mouse event
;; RETURNS: the cat that should follow the given mouse event
;; examples:  See slide on life cycle of dragged cat
;; strategy: struct decomp on mouse events
(define (cat-after-mouse-event c mx my mev)
  (cond    
    [(mouse=? mev "button-down") (cat-after-button-down c mx my)]
    [(mouse=? mev "drag") (cat-after-drag c mx my)]
    [(mouse=? mev "button-up")(cat-after-button-up c mx my)]
    [else c]))

;; cat-north? : Cat -> Boolean
;; GIVEN: some cat
;; RETURNS: true if the cat is moving in the NORTH direction else false
;; examples:  (cat-north? (make-cat 20 30 true "NORTH"))-> true
;; strategy: struct decomp on c : Cat
(define(cat-north? c)
  (if (string=? (cat-dir c) "NORTH") true false))

;; cat-south? : Cat -> Boolean
;; GIVEN: some cat
;; RETURNS: true if the cat is moving in the SOUTH direction else false
;; examples:  (cat-south? (make-cat 20 30 true "SOUTH"))-> true
;; strategy: struct decomp on c : Cat
(define(cat-south? c)
  (if (string=? (cat-dir c) "SOUTH") true false))

;; cat-east? : Cat -> Boolean
;; GIVEN: some cat
;; RETURNS: true if the cat is moving in the EAST direction else false
;; examples:  (cat-east? (make-cat 20 30 true "EAST"))-> true
;; strategy: struct decomp on c : Cat
(define(cat-east? c)
  (if (string=? (cat-dir c) "EAST") true false))

;; cat-west? : Cat -> Boolean
;; GIVEN: some cat
;; RETURNS: true if the cat is moving in the WEST direction else false
;; examples:  (cat-west? (make-cat 20 30 true "WEST"))-> true
;; strategy: struct decomp on c : Cat
(define(cat-west? c)
  (if (string=? (cat-dir c) "WEST") true false))

;; cat-after-button-down : Cat Number Number -> Cat
;;; GIVEN : a cat, the x and y co-ordinates of the new position
;; RETURNS: the cat following a button-down at the given location.
;; EXAMPLES : (cat-after-button-down (make-cat 40 40 true "NORTH") 60 60)->
;;                                   (make-cat 40 40 true "NORTH")
;; STRATEGY: struct decomp on cat
(define (cat-after-button-down c x y)
  (if (in-cat? c x y)
      (make-cat (cat-x-pos c) (cat-y-pos c) true (cat-dir c))
      c))

;;; cat-after-drag : Cat Number Number -> Cat
;;; GIVEN : a cat, the x and y co-ordinates of the new position
;;; RETURNS: the cat following a drag at the given location
;;; EXAMPLES :(cat-after-drag (make-cat 40 40 true "NORTH") 100 100)-> (make-cat 100 100 true "NORTH")
;;; STRATEGY: struct decomp on cat
(define (cat-after-drag c x y)
  (if (cat-selected? c)
      (make-cat x y true (cat-dir c))
      c))

;;; cat-after-button-up : Cat Number Number -> Cat
;;; GIVEN : a cat, the x and y co-ordinates of the new position
;;; RETURNS: the cat following a button-up at the given location
;;; STRATEGY: struct decomp on cat
(define (cat-after-button-up c x y)
  (if (cat-selected? c)
      (make-cat (check-x-boundaries (cat-x-pos c))
                (check-y-boundaries (cat-y-pos c))
                false
                (cat-dir c))
      c))

;; check-x-boundaries : Numebr -> Number
;; GIVEN : X coordinate of the cat
;; RETURNS : if the coordinate is within the x boundaries
;; STRATEGY : Domain Knowledge
(define (check-x-boundaries x)
  (if (< x HALF-CAT-WIDTH)
      (+ BOUNCE-PADDING HALF-CAT-WIDTH)
      (if(> x (- CANVAS-WIDTH HALF-CAT-WIDTH))
         (- CANVAS-WIDTH HALF-CAT-WIDTH BOUNCE-PADDING) x)))

;; check-y-boundaries : Numebr -> Number
;; GIVEN : y coordinate of the cat
;; RETURNS : if the coordinate is within the y boundaries
;; STRATEGY : Domain Knowledge
(define (check-y-boundaries y)
  (if (< y HALF-CAT-HEIGHT)
      (+ BOUNCE-PADDING HALF-CAT-HEIGHT)
      (if(> y (- CANVAS-HEIGHT HALF-CAT-HEIGHT))
         (- CANVAS-HEIGHT HALF-CAT-HEIGHT BOUNCE-PADDING) y)))

;;; in-cat? : Cat Number Number -> Cat
;;; RETURNS true iff the given coordinate is inside the bounding box of
;;; the given cat.
;;; EXAMPLES: see tests below
;;; STRATEGY: structural decomposition on c : Cat
(define (in-cat? c x y)
  (and
    (<= 
      (- (cat-x-pos c) HALF-CAT-WIDTH)
      x
      (+ (cat-x-pos c) HALF-CAT-WIDTH))
    (<= 
      (- (cat-y-pos c) HALF-CAT-HEIGHT)
      y
      (+ (cat-y-pos c) HALF-CAT-HEIGHT))))


;; initial-world : Number -> World
;; GIVEN    : a number
;; RETURNS  : a world with two unselected cats at the given y coordinate
;; STRATEGY : Functional Composition 
(define (initial-world y)
  (make-world
    (make-cat CAT1-X-COORD y false "SOUTH")
    (make-cat CAT2-X-COORD y false "SOUTH")
    false))

;(main 100)

(define-test-suite bouncing-cats-tests
  (check-equal? (cat-east? (make-cat 20 30 true "EAST")) true
                "Not in the east direction")
  
  (check-equal? (cat-east? (make-cat 20 30 true "WEST")) false
                "Not in the east direction")
  
  (check-equal? (cat-west? (make-cat 20 30 true "WEST")) true
                "Not in the west direction")
  
  (check-equal? (cat-west? (make-cat 20 30 true "EAST")) false
                "Not in the west direction")
  
  (check-equal? (cat-north? (make-cat 20 30 true "NORTH")) true 
                "Not in the north direction") 
  
  (check-equal? (cat-north? (make-cat 20 30 true "SOUTH")) false
                "Not in the north direction")
  
  (check-equal? (cat-south? (make-cat 20 30 true "SOUTH")) true
                "Not in the south direction")
  
  (check-equal? (cat-south? (make-cat 20 30 true "NORTH")) false
                "Not in the south direction")
  
  (check-equal? (cat-after-tick (make-cat 200 300 true "SOUTH"))
                (make-cat 200 300 true "SOUTH") "")
  
  (check-equal? (cat-after-tick-helper 400 400 false "NORTH")
                (make-cat 400 392 false "NORTH") "")
  
  (check-equal? (cat-after-tick-helper 400 400 false "EAST") 
                (make-cat 408 400 false "EAST") "")
  
  (check-equal? (cat-after-tick-helper 400 400 false "WEST")
                (make-cat 392 400 false "WEST") "")
  
  (check-equal? (cat-after-tick-helper 200 393 false "SOUTH")
                (make-cat 200 681/2 false "NORTH") "")
  
  (check-equal? (cat-after-tick-helper 200 200 true "SOUTH")
                (make-cat 200 208 true "SOUTH") "")
  
  (check-equal? (check-east-boundary 460 300 true "EAST") 
                (make-cat 823/2 300 true "WEST"))
  
  (check-equal? (check-east-boundary 400 300 true "EAST")
                (make-cat 408 300 true "EAST"))
  
  (check-equal? (check-west-boundary 10 300 true "WEST")
                (make-cat 77/2 300 true "EAST"))
  
  (check-equal? (check-west-boundary 400 300 true "WEST") 
                (make-cat 392 300 true "WEST"))
  
  (check-equal? (check-north-boundary 10 40 true "NORTH") 
                (make-cat 10 119/2 true "SOUTH"))
  
  (check-equal? (check-north-boundary 400 300 true "NORTH")
                (make-cat 400 292 true "NORTH"))
  
  
  
  (check-equal? (transformed-cat-down (make-cat 40 40 true "NORTH"))
                (make-cat 40 40 true "SOUTH") "")
  (check-equal? (transformed-cat-up (make-cat 40 40 true "SOUTH"))
                (make-cat 40 40 true "NORTH") "")
  (check-equal? (transformed-cat-right (make-cat 40 40 true "NORTH"))
                (make-cat 40 40 true "EAST") "")
  (check-equal? (transformed-cat-left (make-cat 40 40 true "NORTH"))
                (make-cat 40 40 true "WEST") "")
  
  
  (check-equal? (in-cat? (make-cat 20 40 true "NORTH") 50 50) true)
  
  
  (check-equal? (check-x-boundaries 15 ) 77/2 false)
  (check-equal? (check-x-boundaries 500 ) 823/2 false)
  (check-equal? (check-x-boundaries 200 ) 200 false)
  
  (check-equal? (check-y-boundaries 15 ) 119/2 false)
  (check-equal? (check-y-boundaries 500 ) 681/2 false)
  (check-equal? (check-y-boundaries 200 ) 200 false)
  
  
  (check-equal? (cat-after-drag (make-cat 40 40 true "NORTH") 100 100)
                (make-cat 100 100 true "NORTH") (make-cat 40 40 true "NORTH"))
  
  (check-equal? (cat-after-drag (make-cat 40 40 false "NORTH") 100 100)
                (make-cat 40 40 false "NORTH") (make-cat 40 40 true "NORTH"))
  
  
  (check-equal? (cat-after-button-down (make-cat 40 40 true "NORTH") 60 60) 
                (make-cat 40 40 true "NORTH") "clicked Outside the cat")
  
  (check-equal? (cat-after-button-down (make-cat 40 40 true "NORTH") 100 200) 
                (make-cat 40 40 true "NORTH") "clicked Outside the cat")
  
  
  
  (check-equal? (cat-after-button-up (make-cat 440 350 true "EAST") 460 460)
                (make-cat 823/2 681/2 false "EAST") (make-cat 440 350 true "EAST"))
  
  (check-equal? (cat-after-button-up (make-cat 200 200 false "EAST") 460 460) 
                (make-cat 200 200 false "EAST"))
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 true "EAST")
                                                   (make-cat 440 350 false "EAST")
                                                   false) "left")
                (make-world (make-cat 440 350 true "WEST")
                            (make-cat 440 350 false "EAST")
                            false))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 true "EAST")
                                                   false) "left")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 true "WEST")
                            false))
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 true "NORTH")
                                                   (make-cat 440 350 false "EAST")
                                                   false) "right")
                (make-world (make-cat 440 350 true "EAST")
                            (make-cat 440 350 false "EAST")
                            false))
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 true "SOUTH")
                                                   false) "right")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 true "EAST")
                            false))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 true "EAST")
                                                   (make-cat 440 350 false "EAST")
                                                   false) "up")
                (make-world (make-cat 440 350 true "NORTH")
                            (make-cat 440 350 false "EAST")
                            false))
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 true "SOUTH")
                                                   false) "up")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 true "NORTH")
                            false))
  
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 true "EAST")
                                                   (make-cat 440 350 false "EAST")
                                                   false) "down")
                (make-world (make-cat 440 350 true "SOUTH")
                            (make-cat 440 350 false "EAST")
                            false))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 true "SOUTH")
                                                   false) "down")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 true "SOUTH")
                            false))
  
  
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) "left")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            false))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) "right")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            false))
                                   
                                   
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) "up")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            false))
                                   
  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) "down")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            false))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) " ")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            true))

  (check-equal? (world-after-key-event (make-world (make-cat 440 350 false "EAST")
                                                   (make-cat 440 350 false "SOUTH")
                                                   false) "s")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            false))
  
  (check-equal? (world-after-tick (make-world (make-cat 440 350 false "EAST")
                                              (make-cat 440 350 false "SOUTH")
                                              true))
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            true))
  
  (check-equal? (world-after-tick (make-world (make-cat 440 350 false "EAST")
                                            (make-cat 440 350 false "SOUTH")
                                            false))
              (make-world (make-cat 823/2 350 false "WEST")
                          (make-cat 440 681/2 false "NORTH")
                          false))
  
  (check-equal? (world-after-mouse-event (make-world (make-cat 440 350 false "EAST")
                                                     (make-cat 440 350 false "SOUTH")
                                                     true) 50 50 "button-up")
                (make-world (make-cat 440 350 false "EAST")
                            (make-cat 440 350 false "SOUTH")
                            true))
  
  (check-equal? (initial-world 20) (make-world
                                    (make-cat CAT1-X-COORD 20 false "SOUTH")
                                    (make-cat CAT2-X-COORD 20 false "SOUTH")
                                    false))
                                 
                                     

  (check-equal? (cat-after-mouse-event (make-cat 40 40 true "NORTH")
                                       50 50 "button-down")
                (make-cat 40 40 true "NORTH"))

  (check-equal? (cat-after-mouse-event (make-cat 40 40 true "NORTH")
                                       50 50 "button-up")
                (make-cat 40 119/2 false "NORTH"))

  (check-equal? (cat-after-mouse-event (make-cat 40 40 true "NORTH")
                                       50 50 "drag")
                (make-cat 50 50 true "NORTH"))
  
  (check-equal? (cat-after-mouse-event (make-cat 40 40 true "NORTH")
                                       50 50 "move")
                (make-cat 40 40 true "NORTH"))
  
  (check-equal? (place-cat (make-cat 20 40 true "NORTH") EMPTY-CANVAS) 
                (place-image CAT-IMAGE 20 40 EMPTY-CANVAS))
  
  (check-equal? (world-to-scene (make-world (make-cat 20 30 true "NORTH")
                                          (make-cat 150 30 true "NORTH") true))
              (place-cat (make-cat 20 30 true "NORTH") 
                         (place-cat (make-cat 150 30 true "NORTH") EMPTY-CANVAS)))
  )

(run-tests bouncing-cats-tests)