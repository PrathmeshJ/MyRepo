;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname balls-in-box) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Balls-In-Box
;; user can drag the balls with the mouse on the canvas
;; button-down to select, drag to move, button-up to release.
;; on selecting the ball,the ball must turn to solid green
;; ball and it should be smoothly draggable.
;; also a count of number of balls on canvas must be displayed.
;; start with (run 0)
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)



;; =============================================================================
;;                          provide statements
;; =============================================================================
;; run with (run 0)

(provide run)
(provide initial-world)
(provide world-after-mouse-event)
(provide world-after-key-event)
(provide world-balls)
(provide ball-x-pos)
(provide ball-y-pos)
(provide ball-selected?)
(provide world-after-tick)

;; =============================================================================
;;                                 run
;; =============================================================================
;; MAIN FUNCTION.
;;run : Any -> World
;;GIVEN: an argumentt,which is ignored.
;;EFFECT: runs the world at tick rate of 0.25 secs/tick.
;;RETURNS: the final state of the world.

(define (run any-value frame-rate)
  (big-bang (initial-world any-value)
            (on-draw world->scene)
            (on-tick world-after-tick frame-rate)
            (on-mouse world-after-mouse-event)
            (on-key  world-after-key-event)))

;; =============================================================================
;;                                   CONSTANTS
;; =============================================================================
;;dimensions of  the canvas
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 300)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;;center of the canvas 
(define CANVAS-CENTER-X (/ CANVAS-WIDTH 2))
(define CANVAS-CENTER-Y (/ CANVAS-HEIGHT 2))

;;dimensions of the ball
(define BALL-RADIUS 20)
(define BALL-COLOR "green")

;;distance from the center
(define DISTANCE-FROM-CENTER 20)

;;draw a  selected ball
(define BALL-SELECTED (circle BALL-RADIUS "solid" BALL-COLOR))

;;draw a unselected ball
(define BALL-UNSELECTED (circle BALL-RADIUS "outline" BALL-COLOR))

(define HALF-BALL (/ BALL-RADIUS 2))

(define BALL-HEIGHT-CHECK (- CANVAS-HEIGHT BALL-RADIUS))
(define BALL-WIDTH-CHECK (- CANVAS-WIDTH BALL-RADIUS))

(define BALLSPEED 8)
(define BOUNCE-PADDING 1)
;;examples for testing


;; =============================================================================
;;                                DATA DEFINITIONS
;; =============================================================================

(define-struct ball(x y mx my select? direction))
;;A Ball is a (make-ball Number Number Number Number Boolean)
;; x is the x-co-ordinate of the ball on x-axis
;; y is the y-co-ordinate of the ball on y-axis
;; mx is the coordinate of the mouse pointer  on x-axis
;; my is the coordinate of the mouse pointer on y-axis
;; select? true if ball selected else false.
;; direction is the direction in which the ball is moving

;;template:
;; ball-fn : Ball -> ??
;;(define (ball-fn b)
;; (... (ball-x b)
;;      (ball-y b)
;;      (ball-mx b)
;;      (ball-my b)
;;      (ball-select? b)
;;      (ball-direction b)))




;; A List Of Balls (LOB) (Listof<Ball>) is one of:
;; -- empty                      (interp: empty list of balls)
;; -- (cons Ball Listof<Ball>)   (inter: a List of balls)

;; Template:
;; list-fn : Listof<Ball> -> ??
;; (define (list-fn list)
;;   (cond
;;     [(empty? list) ...]
;;     [else (... (first list)
;;                (list-fn (rest list)))]))

;; A Direction is one of
;;-- "EAST"   (interp : Ball moving in the east )
;;-- "WEST"   (interp : Ball moving in the west )

;; Template:
;; dir-fn : dir -> ??
;; (define (dir-fn dir)
;;  (cond
;;   [(string=? dir "EAST") ...]
;;   [(string=? dir "WEST") ...]))



;; Examples for testing

(define ball-list
  (list
   (make-ball 40 40 50 50 false "EAST")
   (make-ball 40 50 50 50 false "EAST")
   (make-ball 40 60 50 50 false "EAST")))

(define ball-list-mouse-event
  (list
   (make-ball 40 40 30 40 false "EAST")
   (make-ball 40 50 50 50 false "EAST")
   (make-ball 40 60 50 50 false "EAST")))

(define ball-list-updated
  (list
   (make-ball 200 150 0 0 false "EAST")
   (make-ball 40 40 50 50 false "EAST")
   (make-ball 40 50 50 50 false "EAST")
   (make-ball 40 60 50 50 false "EAST")))

(define list-with-1-selected-ball 
  (list
   (make-ball 40 40 50 50 true "EAST")
   (make-ball 40 50 50 50 false "EAST")
   (make-ball 40 60 50 50 false "EAST")))

(define list-for-mouse-down
  (list
   (make-ball 40 40 50 50 false "EAST")))

(define list-after-mouse-down
  (list
   (make-ball 40 40 50 50 true "EAST")))

(define list-after-mouse-down-west
  (list
   (make-ball 40 40 50 50 true "WEST")))

(define empty-list
  (list
   empty))



(define-struct world (list paused? ball-speed))
;; A World is a (make-world (Listof<Ball>))
;; list is the list of balls on the canvas
;; paused? tells us if the world is paused or not
;; ball-speed is the speed with which the ball moves in the world

;;template:
;; world-fn : World -> ??
;;(define (world-fn w)
;; (... (world-list w)
;; (... (world-paused w)
;; (... (world-ball-speed w)))



;;A MakeNewBallKeyEvent is a KeyEvent, which is one of
;; -- "n"                (interp: create a new ball at center of canvas)
;; -- " "                (interp: pauses and unpauses the world)
;; -- any other KeyEvent (interp: ignore)

;; TEMPLATE:
;; make-new-ball-kev-fn : MakeNewBallKeyEvent -> ??
;;(define (make-new-ball-kev-fn kev)
;;  (cond 
;;   [(key=? kev "n")...]
;;   [(key=? kev " ")...]
;;   [else ...]))


;; A MoveBallMouseEvent is a partition of MouseEvent, which is one of
;; following categories:
;; -- "button-down"   (interp: maybe select the ball)
;; -- "drag"          (interp: maybe drag the ball)
;; -- "button-up"     (interp: unselect the ball)
;; -- any other mouse event (interp: ignored)

;;(define (mev-fn mev)
;;  (cond
;;    [(mouse=? mev "button-down") ...]
;;    [(mouse=? mev "drag") ...]
;;    [(mouse=? mev "button-up") ...]
;;    [else ...]))

;; =============================================================================
;;                                initial-world
;; =============================================================================
;; initial-world : Any  -> World
;; GIVEN: An argument, which is ignored.
;; RETURNS: a world with no balls.
;; EXAMPLES :(initial-world 0) ->  (make-world empty)
(define (initial-world bspeed)
  ( make-world empty false bspeed))

;;Tests:
(define world-to-use 
  (make-world ball-list false BALLSPEED))

(define world-to-use-paused
  (make-world ball-list true BALLSPEED))

(define world-after-mouse-up
  (make-world ball-list-mouse-event false BALLSPEED))

(define world-updated
  (make-world ball-list-updated false BALLSPEED))

(define world-for-mouse-event
  (make-world list-with-1-selected-ball false BALLSPEED))

(define world-for-mouse-down
  (make-world list-for-mouse-down false BALLSPEED))

(define world-after-mouse-down
  (make-world list-after-mouse-down false BALLSPEED))





(define-test-suite initial-world-test
  
  (check-equal? 
   (initial-world 0) 
   (make-world  empty false 0) 
   "initial world selected") )
(run-tests initial-world-test)


;; within-ball? : Ball Number Number -> Boolean
;; GIVEN: a ball ,x and y coordinates of the mouse
;; RETURNS: true iff the given coordinate is inside the ball;
;; EXAMPLES: see tests below
;; STRATEGY: Structural decomposition on b : Ball
(define (within-ball? b x y)
  
  (if (<= (sqrt(+ (* (- (ball-x b) x) (- (ball-x b) x))  
                  (* (- (ball-y b) y) (- (ball-y b) y)))) 20)
      true false))


;; =============================================================================
;;                                 world->scene
;; =============================================================================
;; world->scene : World Number -> Scene
;; GIVEN: a world
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world->scene select-for-drag)=>ball-selected-scene
;; STRATEGY: structural decomposition [World]
(define(world->scene w)
  (place-image ( text (string-append "Balls on Canvas : "
                                     (number->string (length (world-list w))))
                  20 "black") 200 10 (refresh-scene(world-list w))))


;; refresh-scene : LOB -> Scene
;; GIVEN : A list of balls
;; RETUENS : A Scene with updated lst of balls
;; EXAMPLES :
;; STARTEGY : STRUCTURAL DECOMPOSITION of List
;(define (refresh-scene list )
;  (cond
;    [(empty? list)  EMPTY-CANVAS ]
;    [else (if(ball-selected? (first list))
;             (place-image BALL-SELECTED 
;                          (ball-x-pos (first list))
;                          (ball-y-pos (first list))
;                          (refresh-scene (rest list)))
;             (place-image BALL-UNSELECTED
;                          (ball-x-pos (first list))
;                          (ball-y-pos (first list))
;                          (refresh-scene (rest list))))]))            
;




(define (refresh-scene list)
  (foldr
   ;; Ball Scene -> Scene
   ;; GIVEN : A Scene and a ball
   ;; RETURNS : The refreshed scene
   (lambda (ball n) (if (ball-selected? ball) 
                      (place-image BALL-SELECTED 
                          (ball-x-pos ball)
                          (ball-y-pos ball)
                           n)
             (place-image BALL-UNSELECTED
                          (ball-x-pos ball)
                          (ball-y-pos ball)
                          n)))
   EMPTY-CANVAS
   list))


;; world-after-tick : World -> World
;; GIVEN: a world w
;; RETURNS: the world that should follow w after a tick.
;; EXAMPLES : (world-after-tick (cons (make-ball 0 0 0 0 false true) empty))
;; -> (make-world (cons (make-ball 158 150 0 0 false true) empty) false)
;; STRATEGY: structural decomposition on w : World
(define (world-after-tick w)
  (cond
    [(world-paused? w) w]
    [else (make-world
           (ball-after-tick (world-list w) (world-ball-speed w))
           (world-paused? w)
           (world-ball-speed w))]))

;; ball-after-tick : LOB -> LOB
;; GIVEN : A LOB 
;; RETURNS : The LOB after the tick
;; EXAMPLES :(ball-after-tick (cons (make-ball 158 150 0 0 false true) empty))
;;            -> (cons (make-ball 166 150 0 0 false true) empty)
;; STRATEGY : STRUCTURAL DECOMPOSTION OF LOB : List
;(define (ball-after-tick list bspeed)
;  (cond
;    [(empty? list) empty]
;    [else (if (ball-selected? (first list))
;          (cons (first list) (ball-after-tick (rest list) bspeed))
;          (cons (ball-after-tick-helper (first list) bspeed)
;                (ball-after-tick (rest list) bspeed)))]))

(define (ball-after-tick list bspeed)
  (map
   ;; Ball -> Ball
   ;; GIVEN : A ball
   ;; RETURNS : the same ball after tick
   (lambda (ball) (if (ball-selected? ball)
                      ball
                      (ball-after-tick-helper ball bspeed)))
   list))



;; ball-after-tick-helper : Ball -> Ball
;; GIVEN : A Ball 
;; RETURNS : The same Ball after the tick
;; EXAMPLES :(ball-after-tick-helper (make-ball 166 150 0 0 false true))
;;           -> (make-ball 174 150 0 0 false true)
;; STRATEGY : STRUCTURAL DECOMPOSTION OF b : Ball
(define (ball-after-tick-helper b bspeed)
  (get-the-ball-to-move (ball-x b)
                        (ball-y b)
                        (ball-mx b)
                        (ball-my b)
                        (ball-selected? b)
                        (ball-direction b)
                        bspeed))

;; get-the-ball-to-move : Number Number Number Number Boolean Boolean -> Ball
;; GIVEN : The x and y coordinates of a ball, the x and y coordinates
;;         of the mouse pointer,
;;         ball selected or not and the direction of the ball
;; RETURNS : The same Ball after the tick
;; EXAMPLES :(get-the-ball-to-move 174 150 0 0 false true)
;;           -> (make-ball 182 150 0 0 false true)
;; STRATEGY : FUNCTIONAL COMPOSITION
(define (get-the-ball-to-move x y mx my sel dir bspeed)
   (cond
   [(string=? dir "EAST") (check-east-boundary x y mx my sel dir bspeed)]
   [(string=? dir "WEST") (check-west-boundary x y mx my sel dir bspeed)]))
       
;; check-east-boundary : Number Number Number Number Boolean Boolean -> Ball
;; GIVEN    : the x-coordinate, y-coordinate of the ball,
;;            the x and y coordinate of the mouse pointer,
;;            if the ball is selectedor not and the direction 
;;            of the ball
;; RETURNS  : the same ball with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : ( check-east-boundary 174 150 0 0 false true)
;;             ->  (make-ball 182 150 0 0 false true)
;; TESTS    : In the test suite
(define(check-east-boundary x-pos y-pos mx my selected? dir bspeed)
  (if (or (> (+ x-pos BALL-RADIUS bspeed) BALL-WIDTH-CHECK) (> x-pos BALL-RADIUS BALL-WIDTH-CHECK))
      (make-ball (- BALL-WIDTH-CHECK BOUNCE-PADDING BOUNCE-PADDING )
                 y-pos
                 mx
                 my
                 selected?
                 "WEST")
      (make-ball (+ x-pos bspeed)
                 y-pos
                 mx
                 my
                 selected?
                 dir)))

;; check-west-boundary : Number Number Number Number Boolean Boolean -> Ball
;; GIVEN    : the x-coordinate, y-coordinate of the ball,
;;            the x and y coordinate of the mouse pointer,
;;            if the ball is selectedor not and the direction 
;;            of the ball
;; RETURNS  : the same ball with the direction changed or retained direction
;;            which is determined upon checking the conditions
;; EXAMPLES : ( check-west-boundary 174 150 0 0 false false)
;;             -> (make-ball 166 150 0 0 false false)
;; TESTS    : In the test suite
(define(check-west-boundary x-pos y-pos mx my selected? dir bspeed)
  (if (or (< x-pos BALL-RADIUS BALL-RADIUS) (< (- x-pos bspeed) BALL-RADIUS))
      (make-ball (+ BALL-RADIUS BOUNCE-PADDING BOUNCE-PADDING )
                 y-pos
                 mx
                 my
                 selected?
                 "EAST")
      (make-ball (- x-pos bspeed) y-pos mx my selected? dir)))



;; =============================================================================
;;                                 world-after-drag
;; =============================================================================

;; world-after-drag : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a drag at the given location.
;; if the world is selected, then return a world just like the given
;; one, except that it is now centered on the position relative to the
;; selected point on the ball by the mouse position.
;; EXAMPLE:
;; (world-after-drag(make-world 50 30 80 15 true) 200 15)=> 
;; (make-world 170 30 200 15 true)  
;; STRATEGY : Functional composition.
(define (world-after-drag w mx my)
  (make-world (get-the-drag-event-list(world-list w) mx my)
              (world-paused? w)
              (world-ball-speed w)))

;; get-the-drag-event-list : LOB Number Number LOB
;; GIVEN : A List , xcoordinate, y-coordinate
;; RETURNS : An updated List or an empty list
;; EXMAPLES : (get-the-drag-event-list ball-list 50 50)->
;;            (cons (make-ball 40 40 50 50 false) 
;;            (cons (make-ball 40 50 50 50 false)
;;            (cons (make-ball 40 60 50 50 false) empty)))
;; STRATEGY : STRUCTURAL DECOMPOSITION of List
;(define (get-the-drag-event-list list mx my)
;  (cond
;    [(empty? list) empty]
;    [else (if(ball-selected? (first list))
;             (cons (calculate-distance (first list) mx my) 
;                   (get-the-drag-event-list (rest list) mx my))
;             (cons (first list)(get-the-drag-event-list (rest list) mx my)))]))
;

(define (get-the-drag-event-list list mx my)
  (map
   ;; Ball -> Ball
   ;; GIVEN : A Ball
   ;; RETURNS : The refreshed scene
   (lambda (ball) (if (ball-selected? ball)
                      (calculate-distance ball mx my)
                      ball ))
   list))

;; calculate-distance: Ball Number Number -> Ball
;; GIVEN: a ball , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: Check the distance of the mouse click from the center of
;; the ball and return the ball at the calculated distance.
;; EXAMPLE:
;; (calculate-distance(make-world 50 30 80 15 true) 200 15)=>  
;; (make-world 170 30 200 15 true)
;; STRATEGY:Structural decomposition on w : World 
(define (calculate-distance b mx my)
  (make-ball (- mx(-(ball-mx b)(ball-x b))) 
             (- my(-(ball-my b)(ball-y b))) mx my true (ball-direction b)))



;; world-after-button-down : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a button-down at the given location.
;; if the button-down is inside the ball, return a outlined ball that it is
;; selected.
;; EXAMPLE:(world-after-button-down (make-world (list 
;;         (make-ball 72 146 12 144 false "EAST")) false 10) 50 50) ->
;;         (make-world (list (make-ball 72 146 12 144 false "EAST")) false 10)
;; STRATEGY : Structural decomposition on w : World 
(define (world-after-button-down w mx my)
  (make-world(fetch-list (world-list w) mx my)
             (world-paused? w)
             (world-ball-speed w)))


;; fetch-list : LOB Number Number -> LOB
;; GIVEN: a LOB , x and y coordinates of the mouse pointer.
;; RETURNS: the LOB following a button-down at the given location.
;; if the button-down is inside the ball, return a outlined ball that it
;; is selected.
;; EXAMPLE: (fetc-list ball-list) -? updated-ball-list
;; STRATEGY : Structural decomposition on list : LOB
;(define (fetch-list list mx my)
;  (cond
;    [(empty? list) empty]
;    [else (if(within-ball? (first list) mx my)
;             (cons (make-ball (ball-x (first list))
;                              (ball-y (first list))
;                              mx 
;                              my 
;                              true
;                             (ball-direction? (first list)))
;                   (fetch-list (rest list)mx my))
;             (cons (first list)(fetch-list (rest list) mx my)))]))

(define (fetch-list list mx my)
   (map
   ;; Ball -> Ball
   ;; GIVEN : A Ball
   ;; RETURNS : The Ball after button down
    (lambda (ball) (if (within-ball? ball mx my)
                       (make-ball (ball-x ball)
                                  (ball-y ball)
                                  mx 
                                  my 
                                  true
                                  (ball-direction? ball))
                       ball ))
    list))
;; world-after-button-up : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a button-up at the given location.
;; if the ball is selected, return a ball just like the given one,
;; except that it is no longer selected.
;; EXAMPLE:
;; (world-after-mouse-event unselected-ball
;;   180 200   ;; a large motion
;;   "button-up")=> unselected-ball  
;; STRATEGY:  Structural decomposition on w : World
(define (world-after-button-up w mx my)
  (make-world(fetch-button-up-list(world-list w) mx my)
             (world-paused? w)
             (world-ball-speed w)))

;; fetch-button-up-list : List Integer Integer -> List
;; GIVEN : A List anf the x and y cooridinates of the mouse pointer
;; RETURNS : Empty if the list is empty
;;           and a list with the ball at the new position
;; EXAMPLES :
;; STRATEGY : STRUCTURAL DECOMPOSITION of List
;(define (fetch-button-up-list list mx my)
;  (cond
;    [(empty? list) empty]
;    [else (if(ball-selected? (first list))
;             (cons (make-ball (ball-x (first list))
;                              (ball-y (first list)) 
;                              mx 
;                              my 
;                              false
;                              (ball-direction (first list)))
;                   (fetch-button-up-list (rest list)mx my))
;             (cons (first list)(fetch-button-up-list (rest list)mx my)))]))
;

(define (fetch-button-up-list list mx my)
   (map
   ;; Ball -> Ball
   ;; GIVEN : A Ball
   ;; RETURNS : The ball after button up
    (lambda (ball) (if (ball-selected? ball)
                       (make-ball (ball-x ball)
                                  (ball-y ball)
                                  mx 
                                  my 
                                  false
                                  (ball-direction? ball))
                       ball ))
    list))


;; =============================================================================
;;                            world-after-mouse-event
;; =============================================================================
;; world-after-mouse-event : World Number Number MouseEvent -> World
;; GIVEN: A world , x and y coordinate of the mouse and a mouseevent
;; RETURNS: the world that follows the given mouse event.
;; EXAMPLES:
;; STRATEGY: Structural decomposition on mev:MoveBallMouseEvent
(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up")(world-after-button-up w mx my)]
    [else w]))

;; =============================================================================
;;                            world-balls
;; =============================================================================
;; world-balls : World -> ListOf<Ball>
;; GIVEN: a world,
;; RETURNS: the list of balls that are in the box.
;; EXAMPLES : (world-balls world-to-use) -> ball-list
;; STRATEGY : STRUCTURAL DECOMPOSITION of World
(define (world-balls w)
   (world-list w))

;; =============================================================================
;;                      ball-x-pos , ball-y-pos
;; =============================================================================
;; ball-x-pos : Ball -> Number
;; ball-y-pos : Ball -> Number
;; GIVEN: a ball
;; RETURNS: the x or y position of its center
;; EXAMPLES : (ball-x-pos (make-ball 20 20 30 40 true) -> 20)
;;            (ball-y-pos (make-ball 20 20 30 40 true) -> 20)
;; STRATEGY : STRUCTURAL DECOMPOSITION of Ball
(define( ball-x-pos b)
  (ball-x b))

(define( ball-y-pos b)
  (ball-y b))

;; =============================================================================
;;                            ball-selected
;; =============================================================================
;; ball-selected? : Ball -> Boolean
;; GIVEN: a world
;; RETURNS: true iff the ball is selected.
;; EXAMPLE:
;; (ball-selected? selected-ball)=>true
;; STRATEGY : Structural decomposition on b : Ball 
(define ( ball-selected? b)
  (if (ball-select? b) true false))


;; ball-direction? : Ball -> Boolean
;; GIVEN: a world
;; RETURNS: true iff the ball is selected.
;; EXAMPLE:
;; (ball-direction? selected-ball)=>true
;; STRATEGY : Structural decomposition on b : Ball 
(define ( ball-direction? b)
  (ball-direction b))


;; =============================================================================
;;                        world-after-key-event
;; =============================================================================
;; world-after-key-event : World MakeNewBallKeyEvent -> World
;; GIVEN: a world w and a key event 
;; RETURNS: the world that should follow the given world
;; after the given key event.
;; EXAMPLES: 

;; STRATEGY: STRUCTURAL DECOMPOSITION on kev : MakeNewBallKeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n") (add-a-new-ball  w)]
    [(key=? kev " ") (world-with-paused-toggled w)]
    [else w]))


;; world-with-paused-toggled : World -> World
;; GIVEN : a World 
;; RETURNS: a world just like the given one, but with paused? toggled
;; EXAMPLES : 
;; STRATEGY: structural decomposition on w : World
(define (world-with-paused-toggled w)
  (make-world
   (world-list w)
   (not (world-paused? w))
   (world-ball-speed w)))


;; add-a-new-ball : World -> World
;; GIVEN : A world
;; RETURNS : The same world with a added ball
;; EXAMPLES :
;; STRATEGY : STRUCTURAL DECOMPOSITION OF World
(define (add-a-new-ball w)
  (make-world (update-list (world-list w))
              (world-paused? w)
              (world-ball-speed w)))

;; update-list : List -> List
;; GIVEN : A List of balls
;; RETURNS : the same list with a new ball added
;; EXAMPLES :
;; STRATERGY : Domain Knowledge
(define (update-list list)
  (cond
    [(empty? list) 
     (cons (make-ball CANVAS-CENTER-X CANVAS-CENTER-Y 0 0  false "EAST") empty)]       
    [else (cons (make-ball CANVAS-CENTER-X CANVAS-CENTER-Y 0 0  false "EAST") 
                list)]))

;; =============================================================================
;;                                   TESTS
;; =============================================================================



(define-test-suite check-balls-in-box
  
  
  (check-equal? (within-ball? (make-ball 40 50 60 70 true "EAST")
                              45 45) true "Within the ball")
  
  (check-equal? (within-ball? (make-ball 40 50 60 70 true "EAST")
                              70 45) false "Outside the ball")
  
  (check-equal? (ball-selected? (make-ball 20 30 40 50 true "EAST"))
                true "Ball is selected")
  
  (check-equal? (ball-selected? (make-ball 20 30 40 50 false "EAST"))
                false "Ball is not  selected")
  
  (check-equal? (world-after-key-event world-to-use "n")
                 world-updated "List updated") 
  
  (check-equal? (world-after-key-event world-to-use "a")
                 world-to-use "Same list returned") 
  
  (check-equal? (world-after-mouse-event world-for-mouse-event
                                         30 40 "button-up") 
                world-after-mouse-up  "Ball deselected")
  
  (check-equal? (world-after-mouse-event world-for-mouse-down
                                         50 50 "button-down")
                world-after-mouse-down  "Ball selected")
  
  (check-equal? (world-after-mouse-event world-for-mouse-down
                                         50 50 "drag")
                world-for-mouse-down  "Ball unselected")
  
  (check-equal? (world-after-mouse-event world-for-mouse-down
                                         50 50 "move")
                world-for-mouse-down  "Ball unselected")
  
  (check-equal? (world-after-drag world-for-mouse-down 50 50)
                world-for-mouse-down  "Ball selected")
  
  (check-equal? (world-after-drag world-after-mouse-down 50 50)
                world-after-mouse-down  "Ball selected")
  
  
  (check-equal? (world-after-button-down 
                 world-for-mouse-down 400 300 )
                 world-for-mouse-down  "Ball selected")
  
  (check-equal? (world-balls world-for-mouse-down) 
                (list
                 (make-ball 40 40 50 50 false "EAST")) "List for the world-balls")
  
  (check-equal? (ball-x-pos (make-ball 20 30 40 50 true "EAST"))
                20 "The x co ordinate is 20")
  
  (check-equal? (ball-y-pos (make-ball 20 30 40 50 true "EAST"))
                30 "The x co ordinate is 30")
  
  (check-equal? (update-list empty) 
                (list (make-ball CANVAS-CENTER-X CANVAS-CENTER-Y 0 0 false "EAST")))
  
  (check-equal? (world->scene world-to-use)
              (place-image 
               (text (string-append "Balls on Canvas : " 
                                    (number->string 
                                     (length (world-list world-to-use))))
                 20 "black") 200 10 (refresh-scene(world-list world-to-use)))
              "The World to Scene is as displayed")


  (check-equal? (world->scene world-for-mouse-event)
                (place-image 
                 (text
                  (string-append 
                   "Balls on Canvas : " 
                   (number->string
                    (length (world-list world-for-mouse-event))))
                  20 "black") 
                 200 10 
                 (refresh-scene(world-list world-for-mouse-event)))
                "The World to Scene is as displayed")
  
  (check-equal? (world-after-tick world-to-use)
                (make-world (list (make-ball 48 40 50 50 false "EAST")
                                  (make-ball 48 50 50 50 false "EAST")
                                  (make-ball 48 60 50 50 false "EAST")) false BALLSPEED)
                "The world that is presnt after tick")
  
  
(check-equal? (world-after-tick world-for-mouse-down)
              (make-world (list (make-ball 48 40 50 50 false "EAST")) false BALLSPEED)
              "World after tick before button down")


  (check-equal? (world-after-tick world-after-mouse-down)
                (make-world (list (make-ball 40 40 50 50 true "EAST")) false BALLSPEED)
                "World after tick after button down")
  
  (check-equal? (world-with-paused-toggled world-to-use)
                (make-world (list (make-ball 40 40 50 50 false "EAST")
                                  (make-ball 40 50 50 50 false "EAST")
                                  (make-ball 40 60 50 50 false "EAST")) true BALLSPEED) 
                "World with paused toggled" )
  
(check-equal? (world-after-key-event world-to-use " ")
              (make-world (list (make-ball 40 40 50 50 false "EAST")
                                (make-ball 40 50 50 50 false "EAST")
                                (make-ball 40 60 50 50 false "EAST")) true BALLSPEED)
              "World after paused key event ")
  
  (check-equal? (check-east-boundary 400 400 50 50 true "EAST" BALLSPEED)
                (make-ball 378 400 50 50 true "WEST")
                "Check east boundary if outside canvas")
  
  
(check-equal? (check-west-boundary 10 10 20 30 true "WEST"  BALLSPEED)
              (make-ball 22 10 20 30 true "EAST")
              "DIrection changed on west boundary")
  
(check-equal? (check-west-boundary 100 100 20 30 true "WEST"  BALLSPEED)
              (make-ball 92 100 20 30 true "WEST")
              "same ball at new position inside the canvas")
  
  (check-equal?  (get-the-ball-to-move 80 100 20 30 true "WEST" 20)
                 (make-ball 60 100 20 30 true "WEST")
                 " move the bass west")
  
  (check-equal? (world-after-tick world-to-use-paused) 
  (make-world (list (make-ball 40 40 50 50 false "EAST")
                    (make-ball 40 50 50 50 false "EAST")
                    (make-ball 40 60 50 50 false "EAST")) true BALLSPEED) 
  "World after tick")
  )

(run-tests check-balls-in-box)
;(run 10 .25)