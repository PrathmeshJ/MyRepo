#lang racket

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/universe)
(require 2htdp/image)

(provide make-world)
(provide make-rectangle)
(provide run)
;; ============================================================================
;; PosInt is a Integer greater than 0.

;; PosNum is a Number greater than 0.
;; ============================================================================
;;                                  CONSTANTS
;; ============================================================================

(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500) 
(define TARGET-RADIUS 10)
(define CANVAS-CENTER-X (/ CANVAS-WIDTH 2))
(define CANVAS-CENTER-Y (/ CANVAS-HEIGHT 2))
(define RECT-WIDTH 30)
(define RECT-HEIGHT 20)
(define HALF-RECT-WIDTH (/ RECT-WIDTH 2))
(define HALF-RECT-HEIGHT (/ RECT-HEIGHT 2))
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define TEST-SPEED 20)
(define CANVAS-TOP-CORNER-X 1)
(define CANVAS-TOP-CORNER-Y 1)

;; ============================================================================
;;                            DATA DEFINITIONS
;; ============================================================================

;; World<%> is a world interface type
;; Rectangle<%> is a rectangle interface type

;; Rectangle% (also called Rectangle) is a class,
;; implementing interface Rectangle<%>.

;; World% (also called World) is a class,
;; implementing interface World<%>.

;; ============================================================================ 
;; A ListOf<Rectangle%> is i.e. list of rectangles and is one of
;; -- empty                                (Interpre: empty list)
;; -- (cons Rectangle% ListOf<Rectangle%>) (Interpre: list has one or more
;;                                          rectangles)

;; Template:
;; lor-fn : ListOf<Rectangle%> -> ??
;(define (lor-fn lor)
;  (cond
;    [(empty? lor) ...]
;    [else (... (first lor)
;               (lor-fn (rest lor)))]))

;; ============================================================================ 
;; A ListOf<Rectangle<%>> is i.e. list of Rectangle<%> i.e. rectangle interface
;; type and is one of
;; -- empty                                    (Interpre: empty list)
;; -- (cons Rectangle<%> ListOf<Rectangle<%>>) (Interpre: list has one or more
;;                                              rectangles)

;; Template:
;; lori-fn : ListOf<Rectangle<%>> -> ??
;(define (lori-fn lori)
;  (cond
;    [(empty? lori) ...]
;    [else (... (first lori)
;               (lori-fn (rest lori)))]))

;; ============================================================================
;; A MyWorldMouseEvent is a partition of MouseEvent into the
;; following categories:
;; -- "button-down"         (interp: maybe select rectangle and/or target)
;; -- "drag"                (interp: maybe drag rectangle and/or target)
;; -- "button-up"           (interp: maybe deselect/unselect rectangle and/or 
;;                                                          target)
;; -- any other mouse event (interp: ignored)

;; myworld-mev-fn : MyWorldMouseEvent -> ??
;(define (myworld-mev-fn mev)
;  (cond
;    [(mouse=? mev "button-down") ...]
;    [(mouse=? mev "drag")        ...]
;    [(mouse=? mev "button-up")   ...]
;    [else ...]))

;; ============================================================================
;; A MyWorldKeyEvent is a partition of KeyEvent, into following categories:
;; -- "n"                 (interp: add new eastwardly i.e. towards right
;;                         moving rectangle at centered at target's center)
;; -- any other KeyEvent  (interp: ignored)

;; Template:
;; myworld-kev-fn : MyWorldKeyEvent -> ??
;(define (myworld-kev-fn kev)
;;  (cond 
;;    [(key=? kev "n")  ...]
;;    [else ...]))

;; ============================================================================
;; Interfaces: 
;; World<%> Interface - states methods that each of its implementation
;;                      classes has to implement

(define World<%>
  (interface ()
    
    ;; -> Void
    ;; Given: no arguments
    ;; Effect: updates this World<%> to its state following one tick
    on-tick                             
    
    ;; Integer Integer MyWorldMouseEvent -> Void
    ;; Given: a mouse location and a mouse event
    ;; Effect: updates this World<%> to its state following the 
    ;; given MyWorldMouseEvent
    on-mouse
    
    ;; MyWorldKeyEvent -> Void
    ;; Given: a key event
    ;; Effect: updates this World<%> to its state following the given
    ;; MyWorldKeyEvent
    on-key
    
    ;; Scene -> Scene
    ;; Given: a scene
    ;; Returns a Scene like the given one, but with this object drawn
    ;; on it.
    add-to-scene  
    
    ;; -> Integer
    ;; Given: no arguments
    ;; Returns: the x and y coordinates of the target in this world
    get-x
    get-y
    
    ;; -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the target is selected in this world, else return
    ;; false
    get-selected?
    
    ;; -> ListOf<Rectangle<%>>
    ;; Given: no arguments
    ;; Returns: gets the list of rectangles in this world
    get-rectangles
    ))

;; ============================================================================
;;                            CLASS : WORLD
;; ============================================================================
;; A World is a (new World% [target-x Integer] [target-y Integer] 
;;                          [target-selected? Boolean] [x-select Integer] 
;;                          [y-select Integer] [speed Integer]
;;                          [rectangles ListOf<Rectangle<%>>])

;; target-x: represents the x co-ordinate of target
;; target-y: represents the y co-ordinate of target
;; target-selected?: represents the selection status of the target. true if 
;;                   selected else false
;; x-select: represents the mouse pointer x co-ordinate iff the target is 
;;           selected
;; y-select: represents the mouse pointer y co-ordinate iff the target is
;;           selected
;; rectangles: represents a ListOf<Rectangle<%>> which are contained
;;             in the World%
;; speed : The speed with which rectangles move either in right or left
;;         direction
(define World%               ; World% class
  (class* object% (World<%>)   
    (init-field target-x)          ; x co-ordinate of the target
    (init-field target-y)          ; y co-ordinate of the target
    (init-field target-selected?)  ; target selected or not
    (init-field x-select)    ; x co-ordinate of the mouse if target selected
    (init-field y-select)    ; y co-ordinate of the mouse if target selected
    (init-field rectangles)  ; ListOf<Rectangle<%>> - list of rectangles
    (init-field speed)       ; Integer - speed of rectangles in the world 
    
    (field [TARGET-IMAGE
            (circle TARGET-RADIUS "outline" "red")])
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; Effect: world is updated to a state after one tick
    ;; Examples: see the test suite below
    ;; Strategy: HOFC
    (define/public (on-tick)
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: state of the given rectangle is updated after tick
       (lambda (rectangle)
         (send rectangle on-tick)) 
       rectangles))
    
    ;; on-mouse : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; MyWorldMouseEvent mev i.e. mouse event
    ;; Effect: World is updated to a state after the given 
    ;; MyWorldMouseEvent
    ;; Examples: see the test suite below
    ;; Strategy: Structural Decomposition on mev : MyWorldMouseEvent 
    (define/public (on-mouse mx my mev)
      (cond
        [(mouse=? mev "button-up")
         (send this world-after-button-up mx my mev)]
        [(mouse=? mev "button-down") 
         (send this world-after-button-down mx my mev)]
        [(mouse=? mev "drag")
         (send this world-after-drag mx my mev)]
        [else this]))
    
    ;; world-after-button-up : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; MyWorldMouseEvent mev
    ;; DETAILS: The target and any Rectangle that is present in the
    ;; World will be unselected
    ;; Examples: see the test suite below
    ;; Strategy: HOFC
    (define/public (world-after-button-up mx my mev)
      (begin
        (set! x-select mx) (set! y-select my)
        (set! target-selected? false))
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: state of given rectangle is updated after
       ;; given MyWorldMouseEvent
       (lambda (rectangle)
         (send rectangle on-mouse mx my mev))
       rectangles))
    
    ;; world-after-button-down : Integer Integer MyWorldMouseEvent -> Void
    ;; EFFECT: this World's state is updated by the given 
    ;; "button-down" MyWorldMouseEvent
    ;; DETAILS: The target and the any Rectangle that is present in the
    ;; selection range will be selected. 
    ;; Other rectangle will remain as they are
    ;; Examples: see the test suite below
    ;; Strategy: HOFC
    (define/public (world-after-button-down mx my mev)
      (begin
        (set! x-select mx) (set! y-select my) 
        (set! target-selected? (send this target-after-button-down mx my)))
      (for-each
       (lambda (rectangle)
         ;; Rectangle% -> Void
         ;; Given : a rectangle
         ;; Effect: state of given rectangle is updated after 
         ;; given MyWorldMouseEvent
         (send rectangle on-mouse mx my mev))
       rectangles))
         
    ;; world-after-drag : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; MyWorldMouseEvent mev
    ;; EFFECT: state of this World is updated after the given 
    ;; "drag" MyWorldMouseEvent
    ;; DETAILS: Any rectangle or a target if selected, are dragged along
    ;; the mouse pointer, other rectangles or unselected target
    ;; remain as they are
    ;; Examples: see the test suite below
    ;; Strategy: HOFC
    (define/public (world-after-drag mx my mev)
      (begin
        (set! target-x (send this target-x-position-after-drag mx))
        (set! target-y (send this target-y-position-after-drag my))
        (set! x-select mx) (set! y-select my))
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: state of given rectangle is updated after
       ;; given MyWorldMouseEvent
       (lambda (rectangle)
         (send rectangle on-mouse mx my mev))
       rectangles))
    
    ;; target-after-button-down : Integer Integer -> Boolean
    ;; GIVEN: x and y co-ordinates of the mouse position
    ;; RETURNS: true iff the mouse position is in the selection range
    ;; of the target, else false
    ;; Examples: see the test suite below
    (define/public (target-after-button-down mx my)
      (send this mouse-in-target-range? mx my))
    
    ;; mouse-in-target-range? : Integer Integer -> Boolean
    ;; GIVEN: x and y co-ordinates of the mouse position
    ;; RETURNS: true iff the mouse position is in the selection range
    ;; of the target, else false
    ;; Examples: see the test suite below
    (define/public (mouse-in-target-range? mx my)
      (<= (sqrt (+ (sqr (- target-x mx))
                   (sqr (- target-y my))))
          TARGET-RADIUS))
    
    
    ;; target-x-position-after-drag : Integer -> Integer
    ;; GIVEN: x co-ordinate of the mouse position
    ;; RETURNS: if target is selected, returns new x co-ordinate of the target
    ;; else returns the same x co-ordinate of the target
    ;; Examples: see the test suite
    (define/public (target-x-position-after-drag mx)
      (if target-selected?
          (+ target-x (- mx x-select))
          target-x))
    
    ;; target-y-position-after-drag : Integer -> Integer
    ;; GIVEN: y co-ordinate of the mouse position
    ;; RETURNS: if target is selected, returns new y co-ordinate of the target
    ;; else returns the same y co-ordinate of the target
    ;; Examples: see the test suite
    (define/public (target-y-position-after-drag my)
      (if target-selected?
          (+ target-y (- my y-select))
          target-y))
    
    ;; on-key: MyWorldKeyEvent -> Void
    ;; GIVEN: a key event i.e. MyWorldKeyEvent
    ;; Effect: state of the World is updated after the given key event. 
    ;; The World is only responsive to 'n' MyWorldKeyEvent.
    ;; Iff key 'n' is pressed, a new rectangle is created, else the
    ;; world remains the same.
    ;; Examples: see the test suite 
    ;; STRATEGY: Structural Decomposition on kev : MyWorldKeyEvent
    (define/public (on-key kev)
      (cond
        [(key=? kev "n")
         (set! rectangles 
               (cons
                (make-rectangle (send this get-x)
                                (send this get-y)
                                speed) 
                rectangles))]
        [else this]))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a Scene scene
    ;; RETURNS: a Scene in which this World is potrayed on the given scene
    ;; Examples: see the test suite 
    ;; Strategy: HOFC
    (define/public (add-to-scene scene)
      (local
        ;; first add the target to the scene
        ((define scene-with-target
           (place-image TARGET-IMAGE target-x target-y EMPTY-CANVAS)))
        ;; then each rectangle one by one to the scene
        (foldr
         ;; Rectangle Scene -> Scene
         ;; Given: a rectangle and a scene
         ;; Returns: a scene with given rectangle painted
         ;; on it.
         (lambda (r scene)
           (send r add-to-scene scene))
         scene-with-target
         rectangles)))
    
    ;; get-x : -> Integer
    ;; get-y : -> Integer
    ;; Given: no arguments
    ;; Returns: the x , y coordinates of the target i.e. center of target
    ;; target in this world
    ;; Examples: 
    ;; this -> (new World%
    ;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;                  [x-select 0] [y-select 0] [target-selected? false]
    ;;                  [rectangles empty] [speed 10]))
    ;; (send this get-x) -> CANVAS-CENTER-X
    ;; (send this get-y) -> CANVAS-CENTER-Y
    (define/public (get-x) target-x)
    (define/public (get-y) target-y)
    
    ;; get-selected? : -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the target is selected in this world, else return
    ;; false
    ;; Examples: 
    ;; this -> (new World%
    ;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;                  [x-select 0] [y-select 0] [target-selected? false]
    ;;                  [rectangles empty] [speed 10]))
    ;; (send this get-selected?) -> false
    (define/public (get-selected?) target-selected?)
    
    ;; get-speed : -> Integer
    ;; Given: no arguments
    ;; Returns: speed of rectangles in this world
    ;; Examples: 
    ;; this -> (new World%
    ;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;                  [x-select 0] [y-select 0] [target-selected? false]
    ;;                  [rectangles empty] [speed 10]))
    ;; (send this get-speed) -> 10
    (define/public (get-speed) speed)
    
    ;; get-rectangles : -> ListOf<Rectangle%>
    ;; Given: no arguments
    ;; Returns: a list of rectangles in this world
    ;; Examples: 
    ;; this -> (new World%
    ;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;                  [x-select 0] [y-select 0] [target-selected? false]
    ;;                  [rectangles empty] [speed 10]))
    ;; (send this get-rectangles) -> empty
    (define/public (get-rectangles) rectangles)
    ))


;; ============================================================================
;; Rectangle<%> Interface:

(define Rectangle<%>
  (interface ()
    
    ;; -> Void
    ;; Given: no arguments
    ;; Effect: updates this Rectangle to its state following a tick
    on-tick                             
    
    ;; Integer Integer MyWorldMouseEvent -> Void
    ;; Given: a mouse location and a mouse event
    ;; Effect: updates this Rectangle to its state following the given
    ;; MyWorldMouseEvent
    on-mouse
    
    ;; MyWorldKeyEvent -> Void
    ;; Given: a key event
    ;; Effect: updates this Rectangle to its state following the given
    ;; MyWorldKeyEvent
    on-key
    
    ;; Scene -> Scene
    ;; Given: a scene
    ;; Returns: a Scene like the given one, but with this object drawn
    ;; on it.
    add-to-scene
    
    ;; -> Integer
    ;; Given: no arguments
    ;; Returns: the x and y coordinates of the center of the rectangle
    get-x
    get-y
    
    ;; -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the rectangle currently selected, else returns false
    is-selected?
    
    ;; -> String
    ;; Given: no arguments
    ;; Returns: the color in which this rectangle would be displayed if
    ;; it were displayed now.
    get-color
    ))

;; ============================================================================
;;                              CLASS : RECTANGLE
;; ============================================================================
;; A Rectangle is a (new Rectangle% [x Integer] [y Integer] 
;;                                  [mx Integer][my Integer]
;;                                  [speed Integer] 
;;                                  [color String]
;;                                  [selected? Boolean])

;; x represents the x co-ordinate of the center of the rectangle
;; y represents the y co-ordinate of the center of the rectangle
;; mx : x coordinate of a mouse position
;; my : y coordinate of a mouse position
;; speed : speed with which rectangle moves on canvas
;; color: a String value and is the color of the rectangle to be displayed
;; selected?: is a boolean and represents the selection status of the rectagle
;; If rectangle is selected, selected? is true, else false

(define Rectangle%                 
  (class* object% (Rectangle<%>)   ; Rectangle% class implements Rectangle<%>
                                   ; interface
    (init-field                      
     x                 ; x co-ordinate of the center of rectangle              
     y                 ; y co-ordinate of the center of rectangle              
     mx                ; x co-ordinate of the mouse position              
     my                ; y co-ordinate of the mouse position              
     speed             ; speed with which the rectangle moves in canvas
     color)            ; color with which the rectangle is to be displayed
    (init-field [selected? false]) ; default selection status is false
    
    
    (field [RECT-IMG (rectangle RECT-WIDTH RECT-HEIGHT "outline" color)])
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; Effect: updates this Rectangle to its state following a tick
    ;; Examples: See the test suite below
    (define/public (on-tick)
      (send this rectangle-after-tick))
    
    ;; on-key : MyWorldKeyEvent -> Void
    ;; GIVEN: a key event MyWorldKeyEvent
    ;; Effect: updates this Rectangle to its state after given key event
    ;; Examples:
    ;; (define r1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED))
    ;; say, this -> r1
    ;; (send this on-key " ") -> this (which is r1 itself) 
    (define/public (on-key kev) this)
    
    ;; on-mouse : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinate of the mouse position and a MyWorldMouseEvent
    ;; Effect: state of the rectangle is updated after given
    ;; MyWorldMouseEvent
    ;; Examples: see the tests below
    ;; DESIGN STRATEGY: Structural Decomposition on mev : MyWorldMouseEvent
    (define/public (on-mouse mouse-x mouse-y mev)
      (cond
        [(mouse=? mev "button-down")
         (send this rectangle-after-button-down mouse-x mouse-y)]
        [(mouse=? mev "drag") 
         (send this rectangle-after-drag mouse-x mouse-y)]
        [(mouse=? mev "button-up")
         (send this rectangle-after-button-up)]
        [else this]))
    
    ;; rectangle-after-button-down : Integer Integer -> Void
    ;; GIVEN: the location of a mouse pointer in terms of x and y co-ordinates
    ;; Effect: the state of rectangle is updated after a button
    ;; down at the given location
    ;; DETAILS:  If the event is inside the rectangle, returns
    ;; a rectangle just like this one, except that it is
    ;; selected.  Otherwise returns the rectangle unchanged.
    ;; Examples: see the tests below    
    (define/public (rectangle-after-button-down mouse-x mouse-y)
      (if (send this mouse-in-rect? mouse-x mouse-y)
          (begin
            (set! mx mouse-x) (set! my mouse-y) 
            (set! selected? true))
          this))
    
    ;; rectangle-after-drag : Integer Integer -> Void
    ;; Given: x and y positions of mouse after drag event
    ;; Effect: state of this rectangle is updated after the given
    ;; drag mouse event.
    ;; DETAILS: If the rectangle is already selected, then the 
    ;; rectangle will be dragged along the mouse-pointer, 
    ;; else the position of this rectangle will remain unchanged
    ;; Examples: see the tests below
    (define/public (rectangle-after-drag mouse-x mouse-y)
      (if selected?
          (begin 
               (set! x (+ x (- mouse-x mx)))
               (set! y (+ y (- mouse-y my)))
               (set! mx mouse-x) (set! my mouse-y) 
               (set! selected? true))
          this))
    
    ;; rectangle-after-button-up : -> Void
    ;; Given: no arguments
    ;; Effect: state of rectangle is updated after the given button-up
    ;; mouse event.
    ;; DETAILS: The button-up mouse event unselects any selected
    ;; rectangle and has no effect on any already un-selected rectangle
    ;; Examples: see the tests below
    (define/public (rectangle-after-button-up)
      (begin
        (set! selected? false)))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a scene same as given, only this Rectangle is potrayed on the
    ;; given Scene
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED)
    ;; (send this add-to-scene EMPTY-CANVAS) -> 
    ;;   (place-image 
    ;;     (rectangle RECT-WIDTH RECT-HEIGHT "outline" "green")
    ;;     CANVAS-CENTER-X
    ;;     CANVAS-CENTER-Y
    ;;     EMPTY-CANVAS)
    (define/public (add-to-scene scene)
      (place-image RECT-IMG x y scene))
    
    ;; mouse-in-rect? : Integer Integer -> Boolean
    ;; GIVEN: x and y locations of the mouse
    ;; RETURNS: true iff the location is inside this rectangle,
    ;; else returns false.
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED)
    ;; (send this mouse-in-rect? CANVAS-CENTER-X CANVAS-CENTER-Y) -> 
    ;;   true
    (define/public (mouse-in-rect? mouse-x mouse-y)
      (and
       (<= 
        (- x HALF-RECT-WIDTH)
        mouse-x
        (+ x HALF-RECT-WIDTH))
       (<= 
        (- y HALF-RECT-HEIGHT)
        mouse-y
        (+ y HALF-RECT-HEIGHT))))
    
    ;; rectangle-after-tick : -> Void
    ;; Given: no arguments
    ;; Effect : a state of this rectangle is updated after one tick 
    ;; Examples: see the tests below
    (define/public (rectangle-after-tick)
      (if selected?
          this
          (begin
            (set! x (send this new-x-after-tick))
            (set! speed (send this speed-after-tick)))))
    
    ;; new-x-after-tick : -> Integer
    ;; Given: no arguments
    ;; Where: this rectangle is not selected
    ;; RETURNS: a new x position of center of this rectangle after tick
    ;; Examples: see the tests below 
    
    (define/public (new-x-after-tick)
      (if (send this rect-outside-boundary?)
          (send this x-pos-after-crossing)
          (+ x speed)))
    
    ;; rect-outside-boundary? : -> Boolean
    ;; Given: no arguments
    ;; RETURNS: true iff this rectangle crosses left or right border of canvas,
    ;; else returns false. A rectangle crosses left or right border means
    ;; its left or right side is beyond left or right border respectively.
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED)
    ;; (send this rect-outside-boundary?) -> 
    ;;   false
    
    (define/public (rect-outside-boundary?)
      (or (send this cross-right-border?)
          (send this cross-left-border?)))
    
    ;; cross-right-border? : -> Boolean
    ;; Given: no arguments
    ;; RETURNS: true iff this rectangle is crossing right border of canvas,
    ;; else returns false
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 15 30 20)
    ;; (send this cross-right-border?) -> 
    ;;   false
    
    (define/public (cross-right-border?)
      (or (> x (- CANVAS-WIDTH HALF-RECT-WIDTH))
          (> (+ x speed) (- CANVAS-WIDTH HALF-RECT-WIDTH))))
    
    ;; cross-left-border? : -> Boolean
    ;; Given: no arguments
    ;; RETURNS: true iff this rectangle crosses left border of canvas,
    ;; else returns false
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    ;; (send this cross-left-border?) -> 
    ;;   true
    (define/public (cross-left-border?)
      (or (< x HALF-RECT-WIDTH)
          (< (+ x speed) HALF-RECT-WIDTH)))
    
    ;; x-pos-after-crossing : -> Integer
    ;; Given: no arguments
    ;; RETURNS: x position of center of this rectangle after tick
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    ;; (send this x-pos-after-crossing) -> 
    ;;   HALF-RECT-WIDTH
    
    (define/public (x-pos-after-crossing)
      (if (send this cross-right-border?)
          (- CANVAS-WIDTH HALF-RECT-WIDTH)
          HALF-RECT-WIDTH))
    
    ;; speed-after-tick : -> Integer
    ;; Given: no arguments
    ;; RETURNS: new speed of rectangle, after tick
    ;; Note: speed of rectangle is either positive or negative.
    ;; If rectangle is moving in right direction then speed will be positive
    ;; If rectangle is moving in left direction then speed will be negative
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    ;; (send this speed-after-tick) -> 20
    
    (define/public (speed-after-tick)
      (if (send this rect-outside-boundary?)
          (* speed -1)
          speed))
    
    ;; get-x : -> Integer
    ;; get-y : -> Integer
    ;; Given: no arguments
    ;; Returns: the x , y coordinates of the center of this rectangle
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    
    ;; (send this get-x) -> 0
    ;; (send this get-y) -> 30
    (define/public (get-x) x)
    (define/public (get-y) y)
    
    ;; is-selected? : -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff this rectangle is selected, else return
    ;; false
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    ;; (send this is-selected?) -> false
    (define/public (is-selected?) selected?)
    
    ;; -> String
    ;; Given: no arguments
    ;; RETURNS: either "red" or "green", depending on the color in
    ;; which this rectangle would be displayed if it were displayed now.
    ;; Examples:
    ;; this -> 
    ;; (make-rectangle 0 30 20)
    ;; (send this get-color) -> "green"
    (define/public (get-color)
      color)
    ))

;; ============================================================================
;; make-rectangle : Integer Integer PosInt -> Rectangle%
;; Given: a x and y positions of center of target and a 
;; rectangle-speed (in pixels/tick)
;; Returns: an unselected rectangle created centered at the given target's 
;; center, moving in right direction  
;; Examples: 
;; (make-rectangle 10 10 20) ->
;;  (new Rectangle% 
;;       [x 10] [y 10] [mx 0] [my 0]
;;       [speed 20] [color "green"])
;; Strategy : Domain Knowledge
(define (make-rectangle x y speed)
  (new Rectangle% 
       [x x] [y y]
       [mx 0] [my 0]
       [speed speed]
       [color "green"]))
;; Tests: see test suite below
;; ============================================================================
;; make-world : PosInt -> World%
;; Given: a rectangle speed i.e. a positive integer
;; Returns: Creates a world with no rectangles, but in which any rectangles
;; created in the future will travel at the given speed.

;; Examples: 
;; (make-world 20) ->
;;  (new World%
;;       [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;       [x-select 0] [y-select 0] [target-selected? false]
;;       [rectangles empty] [speed 20])

;; Strategy : Domain Knowledge
(define (make-world speed)
  (new World%
       [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
       [x-select 0] [y-select 0] [target-selected? false]
       [rectangles empty]
       [speed speed]))
;; Tests: see test suite below
;; ============================================================================
;; run : PosNum PosInt -> World%
;; Given: a frame rate (in seconds/tick) and a rectangle-speed (in pixels/tick),
;; creates and runs a world.  Returns the final state of the world
;; EFFECT: runs an initial world at the given frame rate
;; RETURNS: the final state of the world
;; Design Strategy: Function Composition
(define (run rate speed)
  (big-bang (make-world speed)
            (on-tick
             ;; World -> Void
             ;; Given: a world
             ;; EFFECT: updates the state of the given World 
             ;; after on-tick event
             (lambda (w) (send w on-tick) w) rate)
            (on-key
             ;; World -> Void
             ;; Given: a world
             ;; EFFECT: updates the state of the given World 
             ;; after on-key event
             (lambda (w kev) (send w on-key kev) w))
            (on-mouse
             ;; World -> Void
             ;; Given: a world
             ;; EFFECT: updates the state of the given World 
             ;; after on-mouse event
             (lambda (w mx my mev) (send w on-mouse mx my mev) w))
            (to-draw
             ;; World -> Scene
             ;; Given: a world
             ;; Returns: a scene with given world drawn on it
             (lambda (w) (send w add-to-scene EMPTY-CANVAS)))))

;; ============================================================================
;; target-similar? : World% World% -> Boolean 
;; Given: two worlds
;; Returns: true iff targets in both worlds have same observable behaviours else
;; return false
;; Examples:
;; (define t1 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty] [speed 10]))
;; (define t2 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty] [speed 10]))

;; (target-similar? t1 t2) -> true
;; Design Strategy: Function Composition
(define (target-similar? world1 world2)
  (and
   (equal? (send world1 get-x) (send world2 get-x))
   (equal? (send world1 get-y) (send world2 get-y))
   (equal? (send world1 get-selected?) (send world2 get-selected?))))
;; Tests: see test suite below
;; ============================================================================
;; rectangle-similar? : Rectangle% Rectangle% -> Boolean 
;; Given: two rectangle
;; Returns: true iff both rectangles have same observable behaviours, else
;; return false

;; See tests below

;; Design Strategy: Function Composition
(define (rectangle-similar? r1 r2) 
  (and 
   (equal? (send r1 get-x) (send r2 get-x))
   (equal? (send r1 get-y) (send r2 get-y))
   (equal? (send r1 is-selected?) (send r2 is-selected?))
   (equal? (send r1 get-color) (send r2 get-color))))
;; Tests: see test suite below
;; ============================================================================
;; world-similar? : World% World% -> Boolean
;; Given : two worlds
;; Returns: true iff both world's behavioural properties are the same 
;; Examples : see tests below
;; Design Strategy: Function Composition
(define (world-similar? world1 world2)
  (and
   (target-similar? world1 world2)
   (andmap
    (lambda (r1 r2) (rectangle-similar? r1 r2))
    (send world1 get-rectangles)
    (send world2 get-rectangles))
   (equal? (send world1 get-speed) (send world2 get-speed))))

;; ============================================================================
;;                                   TESTS
;; ============================================================================
;; Examples for tests
(define rectangle1
  (new Rectangle% 
       [x HALF-RECT-WIDTH]
       [y CANVAS-CENTER-Y]
       [mx HALF-RECT-WIDTH] 
       [my CANVAS-CENTER-Y]
       [selected? false]
       [speed TEST-SPEED]
       [color "green"]))

(define world-with-single-rectangle 
  (new World%
       [target-x HALF-RECT-WIDTH] [target-y CANVAS-CENTER-Y]
       [x-select HALF-RECT-WIDTH] [y-select CANVAS-CENTER-Y]
       [target-selected? false]
       [rectangles (cons rectangle1
                         empty)]
       [speed TEST-SPEED]))

(define scene-with-everything-at-center-unselected
  (place-image 
   (rectangle RECT-WIDTH RECT-HEIGHT "outline" "green")
   CANVAS-CENTER-X CANVAS-CENTER-Y
   (place-image (circle TARGET-RADIUS "outline" "red")
                CANVAS-CENTER-X CANVAS-CENTER-Y EMPTY-CANVAS)))

;; ============================================================================

(define-test-suite stateful-world-tests
  
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world1 on-tick)
   (check-not-eqv? world1 world2
                   "both worlds are not similar"))

  (test-begin
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world2 on-key "n")
   (send world1 on-mouse CANVAS-TOP-CORNER-X CANVAS-TOP-CORNER-Y "button-down")
   (check world-similar? world1 world2
          "both worlds are similar"))
  
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world2 on-key "n")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (send world2 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down") 
   (send world2 on-tick)
   (check world-similar? world1 world2
          "test for ontick event, both worlds are similar"))
  
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world2 on-key "n")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "drag")
   (check world-similar? world1 world2
          "tests for drag event, both worlds are similar"))
  
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world2 on-key "n")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "move")
   (check world-similar? world1 world2
          "tests for ignored mouse event, both worlds are similar"))
  
  (test-begin
   (define rect1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED))
   (define rect2 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED))
   (send rect1 on-key "t")
   (check rectangle-similar? rect1 rect2
          "tests for ignored key event, both worlds are similar"))
  
  (test-begin
   (define rect1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED))
   (define rect2 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y TEST-SPEED))
   (send rect1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "move")
   (check rectangle-similar? rect1 rect2
          "both rectangles are same"))
  
  ;; world-similar
  (test-begin 
   (define world1 (make-world TEST-SPEED))
   (define world2 (make-world TEST-SPEED))
   (send world1 on-key " ")
   (check world-similar? world1 world2
          "A world is similar? to itself"))
  
  ;; add-to-scene function
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (define world1-scene (send world1 add-to-scene EMPTY-CANVAS))
   (check-equal? world1-scene
                 scene-with-everything-at-center-unselected
                 "Scene for world with single unselected rectangle
                  is incorrect"))
  
  ;; get-x function
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (check-equal? (send world1 get-x)
                 CANVAS-CENTER-X
                 "Target circle's x-position is at CANVAS-CENTER-X"))
  
  ;; get-y function
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (check-equal? (send world1 get-y)
                 CANVAS-CENTER-Y
                 "Target circle's y-position is at CANVAS-CENTER-Y"))
  
  ;; test case for get-selected? function
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (check-equal? (send world1 get-selected?) true
                  "Target circle is selected"))
  
  
  (test-begin
   (define world1 (make-world TEST-SPEED))
   (send world1 on-key "n")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (send world1 on-mouse (- CANVAS-WIDTH HALF-RECT-WIDTH) 
         CANVAS-CENTER-Y "drag")
   (send world1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-up")
   (send world1 on-tick)
   (send world1 on-mouse (- CANVAS-WIDTH HALF-RECT-WIDTH)
         CANVAS-CENTER-Y "button-down")
   (send world1 on-mouse HALF-RECT-WIDTH CANVAS-CENTER-Y "drag")
   (send world1 on-mouse HALF-RECT-WIDTH CANVAS-CENTER-Y "button-up")
   (send world1 on-tick)

   (check world-similar? world-with-single-rectangle
          world1 "tests for on-tick, both worlds are not similar")))
;; ============================================================================
(run-tests stateful-world-tests)
;; ============================================================================