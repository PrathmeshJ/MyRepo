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

;; CONSTANTS

(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)
(define CANVAS-CENTER-X (/ CANVAS-WIDTH 2))
(define CANVAS-CENTER-Y (/ CANVAS-HEIGHT 2))
(define RECT-WIDTH 30)
(define RECT-HEIGHT 20)
(define HALF-RECT-WIDTH (/ RECT-WIDTH 2))
(define HALF-RECT-HEIGHT (/ RECT-HEIGHT 2))
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define CANVAS-LEFT-CORNER-X 1)
(define CANVAS-LEFT-CORNER-Y 1)
(define TARGET-RADIUS 10)
(define RED "red")
(define GREEN "green")

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
;; A ListOf<Subscriber%> is a ListOf<Rectangle%> 
;; WHERE: ListOf<Subscriber%> represents the rectangles which are buddies of a 
;;        given Rectangle 
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
    
    ;; Integer Integer MyWorldMouseEvent -> World<%>
    ;; Given: a mouse location and a mouse event
    ;; Effect: updates this World to its state following the 
    ;; given MyWorldMouseEvent
    on-mouse
    
    ;; MyWorldKeyEvent -> World<%>
    ;; Given: a key event
    ;; Effect: updates this World to its state following the given
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
;; Subscriber<%> Interface:

(define Subscriber<%>
  (interface ()
    ;; String -> Void
    ;; Given: a value of color as String,
    ;; EFFECT: update new color published from buddy
    update-color
    ))

;; ============================================================================
;;                            CLASS : WORLD
;; ============================================================================
;; A World is a (new World% [target-x Integer] [target-y Integer] 
;;                          [target-selected? Boolean] [x-select Integer] 
;;                          [y-select Integer]
;;                          [rectangles ListOf<Rectangle<%>>])
;; target-x: represents the x co-ordinate of the target
;; target-y: represents the y co-ordinate of the target
;; x-select: represents the mouse pointer x co-ordinate iff the target is 
;; selected
;; y-select: represents the mouse pointer y co-ordinate iff the target is
;; selected
;; target-selected?: represents the selection status of the target. If target
;; is selected, then target-selected? is true, else false
;; rectangles: represents a ListOf<Rectangle<%>> which are contained in the
;; World%

(define World%               ; World% class
  (class* object% (World<%>)   
    (init-field target-x)          ; x co-ordinate of the target
    (init-field target-y)          ; y co-ordinate of the target
    (init-field target-selected?)  ; selection status of the target
    (init-field x-select)    ; x co-ordinate of the mouse if target selected
    (init-field y-select)    ; y co-ordinate of the mouse if target selected
    (init-field rectangles)  ; ListOf<Rectangle<%>> - list of rectangles
    

    (field [CIRCLE-IMAGE (circle TARGET-RADIUS "outline" "red")])
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; Effect: state of world updated after one tick
    ;; Examples: see the test suite
    ;; Strategy: HOFC
    (define/public (on-tick)
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: state of rectangle updates to new state after tick
       (lambda (rectangle)
         (send rectangle on-tick)) 
       rectangles))
    
    ;; on-mouse : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; mouse event
    ;; Effect: updates this World to its state following the
    ;; given MyWorldMouseEvent
    ;; Examples: see the test suite
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
    ;; Effect: updates this World to its state following the given
    ;; "button-up" MyWorldMouseEvent
    ;; Examples: see the test suite 
    ;; Strategy: HOFC
    (define/public (world-after-button-up mx my mev)
      (begin
        (set! x-select mx) (set! y-select my)
        (set! target-selected? false))
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: updates given rectangle to its state given MyWorldMouseEvent
       (lambda (rectangle)
         (send rectangle on-mouse mx my mev))
       rectangles))
    
    ;; world-after-button-down : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; MyWorldMouseEvent mev
    ;; Effect: updates this World to its state following the given
    ;; "button-down" mev
    ;; Other rectangle will remain as they are
    ;; Examples: see the test suite 
    ;; Strategy: HOFC
    (define/public (world-after-button-down mx my mev)
      (begin
        (set! x-select mx) (set! y-select my) 
        (set! target-selected? (send this target-after-button-down mx my)))
      (for-each
       (lambda (rectangle)
         ;; Rectangle% -> Void
         ;; Given : a rectangle
         ;; Effect: updates given rectangle to its state given MyWorldMouseEvent
         (send rectangle on-mouse mx my mev))
       rectangles))
    
    ;; world-after-drag : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinates of the mouse position and a
    ;; MyWorldMouseEvent mev
    ;; Effect: updates this World to its state following the given
    ;; "drag" MyWorldMouseEvent
    ;; DETAILS: Any rectangle or a target if selected, are dragged along
    ;; the mouse pointer, other rectangles or unselected target
    ;; remain as they are
    ;; Examples: see the test suite
    ;; Strategy: HOFC
    (define/public (world-after-drag mx my mev)
      (begin
        (set! target-x (send this target-x-after-drag mx))
        (set! target-y (send this target-y-after-drag my))
        (set! x-select mx) (set! y-select my))
      (for-each
       ;; Rectangle% -> Void
       ;; Given : a rectangle
       ;; Effect: updates given rectangle to its state given MyWorldMouseEvent
       (lambda (rectangle)
         (send rectangle on-mouse mx my mev))
       rectangles))
    
    ;; target-after-button-down : Integer Integer -> Boolean
    ;; GIVEN: x and y co-ordinates of the mouse position
    ;; RETURNS: true iff the mouse position is in the selection range
    ;; of the target, else false
    ;; Examples: see the test suite
    (define/public (target-after-button-down mx my)
      (send this in-range? mx my))
    
    ;; in-range? : Integer Integer -> Boolean
    ;; GIVEN: x and y co-ordinates of the mouse position
    ;; RETURNS: true iff the mouse position is in the selection range
    ;; of the target, else false
    ;; Examples: see the test suite
    (define/public (in-range? mx my)
      (<= (sqrt (+ (sqr (- target-x mx))
                   (sqr (- target-y my))))
          TARGET-RADIUS))
    
    
    ;; target-x-after-drag : Integer -> Integer
    ;; GIVEN: x co-ordinate of the mouse position
    ;; RETURNS: if target is selected, returns new x co-ordinate of the target
    ;; else returns the same
    ;; Examples: see the test suite
    (define/public (target-x-after-drag mx)
      (if target-selected?
          (+ target-x (- mx x-select))
          target-x))
    
    ;; target-y-after-drag : Integer -> Integer
    ;; GIVEN: y co-ordinate of the mouse position
    ;; RETURNS: if target is selected, returns new y co-ordinate of the target
    ;; else returns the same
    ;; Examples: see the test suite
    (define/public (target-y-after-drag my)
      (if target-selected?
          (+ target-y (- my y-select))
          target-y))
    
    
    ;; on-key: MyWorldKeyEvent -> Void
    ;; GIVEN: a key event i.e. MyWorldKeyEvent
    ;; Effect: updates this World to its state following the given
    ;; key event. The World is only responsive to 'n' MyWorldKeyEvent.
    ;; Iff key 'n' is pressed, a new rectangle is created, else
    ;; World remains as is.
    ;; Examples: see the test suite 
    ;; STRATEGY: Structural Decomposition on kev : MyWorldKeyEvent
    (define/public (on-key kev)
      (cond
        [(key=? kev "n") 
         (set! rectangles (cons(make-rectangle (send this get-x)
                                               (send this get-y)
                                               this)
                               rectangles))]
        [else this]))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a Scene scene
    ;; RETURNS: a Scene in which this World is potrayed on the given scene
    ;; Examples: see the test suite 
    ;; Strategy: HOFC
    (define/public (add-to-scene scene)
      (local
        ;; adding target to the scene
        ((define scene-with-target 
           (place-image CIRCLE-IMAGE target-x target-y EMPTY-CANVAS)))
        ;; adding rectangle one after another
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
    ;; Returns: the center coordinates of the target
    ;; Examples: 
    ;; this -> (new World%
    ;;              [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;              [x-select 0] [y-select 0] [target-selected? false]
    ;;              [rectangles empty]))
    ;; (send this get-x) -> CANVAS-CENTER-X
    ;; (send this get-y) -> CANVAS-CENTER-Y
    (define/public (get-x) target-x)
    (define/public (get-y) target-y)
    
    ;; get-selected? : -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the target is selected, else returns
    ;; false
    ;; Examples: 
    ;; this -> (new World%
    ;;              [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;              [x-select 0] [y-select 0] [target-selected? false]
    ;;              [rectangles empty]))
    ;; (send this get-selected?) -> false
    (define/public (get-selected?) target-selected?)
    
    ;; get-rectangles : -> ListOf<Rectangle%>
    ;; Given: no arguments
    ;; Returns: a list of rectangles in this world
    ;; Examples: 
    ;; this -> (new World%
    ;;              [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
    ;;              [x-select 0] [y-select 0] [target-selected? false]
    ;;              [rectangles empty]))
    ;; (send this get-rectangles) -> empty
    
    (define/public (get-rectangles) rectangles)
    ;; Rectangle Number Number ListOf<Subscriber%> -> Void
    ;; Given: a Rectangle, the center coordinates of the rectangle
    ;; and the List of Buddies of the given rectangle
    ;; Effect: updates 'buddies' list of the given rectangle if the rectangle
    ;; overlaps with any Rectangle present in the World after the given 
    ;; rectangle is dragged
    ;; Examples: see the test suite below
    ;; Design Strategy:  HOFC
    (define/public (buddies-after-drag rect rect-x rect-y buddies-list)
      (map
       ;; Rectangle -> Void
       ;; Given: a rectangle
       ;; Effect: updates buddies-list of the given rectangle
       ;; along with the rectangle with which given rectangle overlaps AND
       ;; the two overlapping rectangles are not already present in the
       ;; buddies-list of each other
       (lambda (r)
         (if (and (send r rectangles-overlap? rect-x rect-y)
                  (not (member r buddies-list)))
             (begin
               (send rect subscribe r)
               (send r subscribe rect)
               (send rect update-color RED))
             r))
       rectangles))
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
;;                               CLASS : RECTANGLE
;; ============================================================================
;; A Rectangle is a (new Rectangle% [x Integer] [y Integer] [mx Integer]
;;                                  [my Integer] [color String]
;;                                  [world-obj World%] [selected? Boolean])
;; Interpretation:
;; x: the x co-ordinate of the center of the Rectangle
;; y: the y co-ordinate of the center of the Rectangle
;; color: color of the rectangle
;; mx : a x coordinate of a mouse position
;; my : a y coordinate of a mouse position
;; world-obj: World% Object that this rectangle is a part of 
;; selected?: is a boolean and represents the selection status of the Rectagle
;; If Rectangle is selected, selected? is true, else false

(define Rectangle%                 
  (class* object% (Rectangle<%> Subscriber<%>)
    ; Rectangle% class implements Rectangle<%> and Subscriber<%> interface
    (init-field
     x                 ; x co-ordinate of the center of rectangle
     y                 ; y co-ordinate of the center of rectangle
     color             ; color with which the rectangle is to be displayed
     mx                ; x co-ordinate of the mouse position
     my                ; y co-ordinate of the mouse position
     buddies           ; List of Buddies of the rectangle
     world-obj)        ; World Object that this rectangle is a part of
    (init-field [selected? false]) ; default selection status is false
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; Effect: state of this rectangle is updated to new state after tick
    ;; Examples: See the test suite below
    (define/public (on-tick)
      this) 
    
    ;; on-key : MyWorldKeyEvent -> Void
    ;; GIVEN: a key event MyWorldKeyEvent
    ;; Effect: updates this Rectangle to its state following the given
    ;; key event
    ;; Examples: 
    ;; (define w1 (make-world))
    ;; (define r1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1))
    ;; say, this -> r1
    ;; (send this on-key " ") -> this (which is r1) 
    (define/public (on-key kev) this)    
    
    ;; on-mouse : Integer Integer MyWorldMouseEvent -> Void
    ;; GIVEN: x and y co-ordinate of the mouse position and a MyWorldMouseEvent
    ;; Effect: updates this Rectangle to its state following the given
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
    ;; Effect: updates this Rectangle to its state following the given
    ;; buton-down MyWorldMouseEvent
    ;; DETAILS:  If the event is inside the rectangle, returns
    ;; a rectangle just like this one, except that it is
    ;; selected.  Otherwise returns the rectangle unchanged.
    ;; Examples: see the tests below    
    (define/public (rectangle-after-button-down mouse-x mouse-y)
      (if (send this mouse-in-rect? mouse-x mouse-y)
          (begin
            (set! mx mouse-x) (set! my mouse-y) 
            (set! selected? true)
            (set! color RED) 
            (send this update-color RED))
          this))
    
    ;; rectangle-after-drag : Integer Integer -> Void
    ;; Given: x and y positions of mouse after drag event
    ;; Effect: updates this Rectangle to its state following the given
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
            (set! selected? true)
            (send world-obj buddies-after-drag this x y buddies))
          this))
    
    ;; rectangle-after-button-up : -> Void
    ;; Given: no arguments
    ;; Effect: updates this Rectangle to its state following the given
    ;; button-up mouse event. 
    ;; DETAILS: The button-up mouse event unselects any selected
    ;; rectangle and has no effect on any already un-selected rectangle
    ;; Examples: see the tests below
    
    (define/public (rectangle-after-button-up)
      (begin
        (set! selected? false)
        (set! color GREEN)
        (send this update-color GREEN)))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a scene same as given, only this Rectangle is potrayed on the
    ;; given Scene
    ;; Examples: 
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y)
    ;; (send this add-to-scene EMPTY-CANVAS) -> 
    ;;   (place-image 
    ;;     (rectangle RECT-WIDTH RECT-HEIGHT "outline" "green")
    ;;     CANVAS-CENTER-X
    ;;     CANVAS-CENTER-Y
    ;;     EMPTY-CANVAS)
    
    (define/public (add-to-scene scene)
      (place-image 
       (rectangle RECT-WIDTH RECT-HEIGHT "outline" color)
       x y scene))
    
    ;; mouse-in-rect? : Integer Integer -> Boolean
    ;; GIVEN: x and y locations of the mouse
    ;; RETURNS: true iff the location is inside this rectangle,
    ;; else returns false.
    ;; Examples: 
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1)
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
    
    ;; get-x : -> Integer
    ;; get-y : -> Integer
    ;; Given: no arguments
    ;; Returns: the x , y coordinates of the center of this rectangle
    ;; Examples:
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle 0 30 w1)
    
    ;; (send this get-x) -> 0
    ;; (send this get-y) -> 30
    (define/public (get-x) x)
    (define/public (get-y) y)
    
    ;; is-selected? : -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff this rectangle is selected, else return
    ;; false
    ;; Examples: 
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle 0 30 w1)
    ;; (send this is-selected?) -> false
    (define/public (is-selected?) selected?)
    
    
    ;; Rectangle% -> Void
    ;; Given: a rectangle which wants to be buddy with this rectangle
    ;; Effect: the buddy-list of the current rectangle is updated 
    ;; by adding the given rectangle to its list.
    ;; Examples: 
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1)
    ;; rect2 -> (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1)
    ;; (send subscribe rect2)
    ;; -> rect2 gets added to buddies list of this rectangle
    (define/public (subscribe subscriber)
      (set! buddies (cons subscriber buddies)))
    
    ;; String -> Void
    ;; Given: a value of color as String, 
    ;; Effect: the color value of each rectangle in the buddies
    ;; of this Rectangle is updated
    ;; Examples: see the test suite below
    ;; Strategy: HOFC
    (define/public (update-color val)
      (for-each
       ;; Rectangle% -> Void
       ;; Given: a rectangle
       ;; Effect: updates the color of given rectangle to the given value val
       (lambda (obj)
         (send obj change-color-of-buddy val))
       buddies))
    
    ;; String -> Void
    ;; Given: a value of color as String, 
    ;; Effect: the color value of each rectangle is updated to the given val
    ;; Examples: see the test suite below
    (define/public (change-color-of-buddy val)
      (set! color val))
    
      
    ;; -> String
    ;; Given: no arguments
    ;; RETURNS: either "red"(RED) or "green"(GREEN), depending on the color in
    ;; which this rectangle would be displayed if it were displayed now.
    ;; Examples:
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1)
    ;; (send this get-color) -> "green"
    (define/public (get-color)
      color)
    
    ;; Number Number -> Boolean
    ;; Given: x,y coordinates of the other Rectangle
    ;; Returns: true iff this rectangle overlaps with the given Rectangle
    ;; else false
    ;; Examples:
    ;; (define w1 (make-world))
    ;; this -> 
    ;; (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1)
    ;; 
    ;; (send this rectangles-overlap? CANVAS-CENTER-X CANVAS-CENTER-Y) -> true
    (define/public (rectangles-overlap? rect-x rect-y)
      (and
       (<= (abs (- rect-x x)) RECT-WIDTH)
       (<= (abs (- rect-y y)) RECT-HEIGHT)))
    ))

;; ============================================================================
;; make-rectangle : Integer Integer World% -> Rectangle%
;; Given: a x and y positions of center of target target, and 
;; world instance of which this rectangle is part of
;; Returns: an unselected rectangle created centered at the given target's
;; center 
;; Examples: 
;; (define w1 (make-world)) ->
;;  (new World%
;;       [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;       [x-select 0] [y-select 0] [target-selected? false]
;;       [rectangles empty])
;; (make-rectangle 10 10 w1) ->
;;  (new Rectangle% 
;;       [x 10] [y 10] [mx 0] [my 0]
;;       [color GREEN] [buddies empty]
;;       [world-obj w1])

;; Strategy : Domain Knowledge
(define (make-rectangle x y world-obj)
  (new Rectangle% 
       [x x] [y y] [mx 0] [my 0]
       [color GREEN] [buddies empty] 
       [world-obj world-obj]))
;; Tests: see the test-suite below
;; ============================================================================
;; make-world : -> World%
;; Given: no arguments
;; Returns: Creates a world with no rectangles
;; Examples: 
;; (make-world) ->
;;  (new World%
;;       [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;       [x-select 0] [y-select 0] [target-selected? false]
;;       [rectangles empty])

;; Strategy : Domain Knowledge
(define (make-world)
  (new World%
       [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
       [x-select 0] [y-select 0] [target-selected? false]
       [rectangles empty]))
;; Tests: see the test-suite below
;; ============================================================================
;; run : PosNum -> World%
;; Given: a frame rate (in seconds/tick),
;; Details: creates and runs a world.  Returns the final state of the world
;; EFFECT: runs an initial world at the given frame rate
;; RETURNS: the final state of the world
;; Design Strategy: Function Composition
(define (run rate)
  (big-bang (make-world)
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
;; Returns: true iff targets in both worlds have same observable behaviours
;; else return false
;; Examples:
;; (define t1 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty]))
;; (define t2 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y] 
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty]))

;; (target-similar? t1 t2) -> true

;; Design Strategy: Function Composition
(define (target-similar? w1 w2)
  (and
   (equal? (send w1 get-x) (send w2 get-x))
   (equal? (send w1 get-y) (send w2 get-y))
   (equal? (send w1 get-selected?) (send w2 get-selected?))))
;; Tests: see the test-suite below
;; ============================================================================
;; rectangle-similar? : Rectangle% Rectangle% -> Boolean 
;; Given: two rectangle
;; Returns: true iff both rectangles have same observable behaviours, else
;; returns false
;; Examples: 
;; (define w1 (make-world))
;; (define r1 (new Rectangle% 
;;        [x 1] [y 65] [mx 0] [my 0]
;;        [color GREEN] [buddies empty] 
;;        [world-obj w1])

;; (define r2 (new Rectangle% 
;;        [x 2] [y 23] [mx 0] [my 0]
;;        [color GREEN] [buddies empty] 
;;        [world-obj w1])

;; (rectangle-similar? r1 r2) -> false
;; Design Strategy: Function Composition
(define (rectangle-similar? r1 r2)
  (and 
   (equal? (send r1 get-x) (send r2 get-x))
   (equal? (send r1 get-y) (send r2 get-y))
   (equal? (send r1 is-selected?) (send r2 is-selected?))
   (equal? (send r1 get-color) (send r2 get-color))))
;; Tests: see the test-suite below
;; ============================================================================
;; world-similar? : World% World% -> Boolean
;; Given : two worlds
;; Returns: true iff both world's behavioural properties are the same
;; Examples: 
;; (define w1 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y]
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty]))
;; (define w2 (new World%
;;                  [target-x CANVAS-CENTER-X] [target-y CANVAS-CENTER-Y]
;;                  [x-select 0] [y-select 0] [target-selected? false]
;;                  [rectangles empty]))

;; (world-similar? w1 w2) -> true

;; Design Strategy: Function Composition
(define (world-similar? w1 w2)
  (and
   (target-similar? w1 w2)
   (andmap
    (lambda (r1 r2) (rectangle-similar? r1 r2))
    (send w1 get-rectangles)
    (send w2 get-rectangles))))

;; ============================================================================
;; Examples for tests
(define scene-with-nothing-selected
  (place-image 
   (rectangle RECT-WIDTH RECT-HEIGHT "outline" "green")
   CANVAS-CENTER-X CANVAS-CENTER-Y
   (place-image (circle TARGET-RADIUS "outline" "red")
                CANVAS-CENTER-X CANVAS-CENTER-Y EMPTY-CANVAS)))

;; ============================================================================
(define-test-suite world-tests
  ;; world-similar?
  (test-begin 
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key " ")
   (check world-similar? w1 w2
          "Similar World"))
  
  ;; World after after tick and after adding rectangle by pressing "n" key
  (test-begin
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key "n")
   (send w1 on-tick)
   (check-not-eqv? w1 w2
                   "After tick, similar worlds"))
  
  ;; button down outside rectangle
  (test-begin
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key "n")
   (send w2 on-key "n")
   (send w1 on-mouse CANVAS-LEFT-CORNER-X CANVAS-LEFT-CORNER-Y "button-down")
   (check world-similar? w1 w2
          "both worlds are similar"))
  
    ;; ignored key events i.e. any other key event than "n"
  (test-begin
   (define w1 (make-world))
   (define rect1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1))
   (define rect2 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1))
   (send rect1 on-key "t")
   (check rectangle-similar? rect1 rect2
          "tests for ignored key event, both worlds are similar"))
  
  
  (test-begin
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key "n")
   (send w2 on-key "n")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (send w2 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   ;; w2 world is with one rectangle and it is selected
   (send w2 on-tick)
   (check world-similar? w1 w2
          "ontick event where both worlds are similar"))
  
  ;; drag the rectangle
  (test-begin
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key "n")
   (send w2 on-key "n")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "drag")
   ;; w2 world is with one rectangle with mouse drag
   (check world-similar? w1 w2
          "drag event where both worlds are similar"))
  
  (test-begin
   (define w1 (make-world))
   (define w2 (make-world))
   (send w1 on-key "n")
   (send w2 on-key "n")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "move")
   ;; w1 world is with one rectangle
   ;; w2 world is with one rectangle and mouse is moved
   (check world-similar? w1 w2
          "tests for ignored mouse event, both worlds are similar"))
  
  (test-begin
   (define w1 (make-world))
   (send w1 on-key "n")
   (define w1-scene (send w1 add-to-scene EMPTY-CANVAS))
   (check-equal? w1-scene
                 scene-with-nothing-selected
                 "Scene for world with single unselected rectangle
                  is incorrect"))
  
  (test-begin
   (define w1 (make-world))
   (send w1 on-key "n")
   (check-equal? (send w1 get-x)
                 CANVAS-CENTER-X
                 "Target x-position is center"))
  
  (test-begin
   (define w1 (make-world))
   (send w1 on-key "n")
   (check-equal? (send w1 get-y)
                 CANVAS-CENTER-Y
                 "Target y-position is center"))
  
  ;; get-selected? function
  (test-begin
   (define w1 (make-world))
   (send w1 on-key "n")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (check-equal? (send w1 get-selected?) true
                  "Target is selected"))
  
  (test-begin
   (define w1 (make-world))
   (define rect1 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1))
   (define rect2 (make-rectangle CANVAS-CENTER-X CANVAS-CENTER-Y w1))
   (send rect1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "move")
   (check rectangle-similar? rect1 rect2
          "Same rectangles"))
  
  (test-begin
   (define w1 (make-world))
   (send w1 on-key "n")
   (define w2 (make-world))
   (send w2 on-key "n")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-down")
   (send w1 on-mouse (- CANVAS-WIDTH HALF-RECT-WIDTH) 
         CANVAS-CENTER-Y "drag")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-up")
   (send w1 on-mouse (- CANVAS-WIDTH HALF-RECT-WIDTH)
         CANVAS-CENTER-Y "button-down")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "drag")
   (send w1 on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y "button-up")
   (check world-similar? w2 w1
          "tests for button up and button down and drag,
           both worlds are not similar"))
 )
;; ============================================================================
(run-tests world-tests)
;; ============================================================================