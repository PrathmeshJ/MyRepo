#lang racket

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/universe)
(require 2htdp/image)

(provide make-world)
(provide make-target)
(provide make-rectangle)
(provide run)
;; *****************************************************************************

;; (run framerate speed)

;; *****************************************************************************
;; CONSTANTS

;; CANVAS DIMENSIONS
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)
(define CANVAS-CENTER-X (/ CANVAS-WIDTH 2))
(define CANVAS-CENTER-Y (/ CANVAS-HEIGHT 2))

(define TARGET-RADIUS 10)

;; Rectangle dimensions
(define RECTANGLE-WIDTH 30)
(define RECTANGLE-HEIGHT 20)
(define RECTANGLE-HALF-WIDTH (/ RECTANGLE-WIDTH 2))
(define HALF-RECTANGLE-HEIGHT (/ RECTANGLE-HEIGHT 2))

;; Empty canvas
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;; *****************************************************************************
;;                              DATA DEFINITIONS
;; *****************************************************************************
;; A Direction is one of:    
;; -- "West"     (interpr: Moving in west direction)
;; -- "East"     (interpr: Moving in east direction)


;; TEMPLATE :
;; direction-fn: Direcction -> ??
;;(define (direction-fn direction)
;;  (cond
;;    [(string=? direction "West")  ...]
;;    [(string=? direction "East")  ...]))

;; *****************************************************************************

;; Rectangle% is a Rectangle
;; A ListOf<Rectangle%> is i.e. list of rectangles and is one of
;; -- empty                                (Interp: list has no rectangles)
;; -- (cons Rectangle% ListOf<Rectangle%>) (Interp: list has one or more
;;                                          rectangle instances/objects)
;; Template:
;; list-of-rectangle-fn : ListOf<Rectangle%> -> ??
;(define (list-of-rectangle-fn lor)
;  (cond
;    [(empty? lor) ...]
;    [else (... (first lor)
;               (list-of-rectangle-fn (rest lor)))]))

;; *****************************************************************************

;; A MyWorldKeyEvent is a partitioned KeyEvent, which is one of
;; -- "n"                (interp: Add a new Rectangle moving right,to the scene)
;; -- any other KeyEvent (interp: Ignore)

;; TEMPLATE:
;; my-world-key-event-fn : MyWorldKeyEvent -> ??
;;(define (my-world-key-event-fn kev)
;;  (cond 
;;    [(key=? kev "n")...]
;;    [else ...]))

;; *****************************************************************************

;; A MyWorldMouseEvent is a MouseEvent that is one of:
;; -- "button-down"         (interp: maybe select a rectangle and/or target)
;; -- "drag"                (interp: maybe drag a rectangle and/or target)
;; -- "button-up"           (interp: maybe unselect a rectangle and/or target)
;; -- any other mouse event (interp: ignored)

; mev-fn: MyWorldMouseEvent -> ??
;(define (mev-fn mev)
;  (cond
;    [(mouse=? mev "button-down") ...]
;    [(mouse=? mev "drag") ...]
;    [(mouse=? mev "button-up") ...]
;    [else ...]))
;; *****************************************************************************
;;                                 INTERFACES
;; *****************************************************************************

;; World Interface

(define World<%>
  (interface ()
    
    ;; -> World<%>
    ;; GIVEN: no arguments
    ;; Returns: the World<%> that should follow this one after a tick
    on-tick                             
    
    ;; Integer Integer MouseEvent -> World<%>
    ;; Given: a mouse location and a mouse event
    ;; Returns: the World<%> that should follow this one after the
    ;; given MouseEvent
    on-mouse
    
    ;; KeyEvent -> World<%>
    ;; Given: a key event
    ;; Returns: the World<%> that should follow this one after the
    ;; given KeyEvent
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

;; *****************************************************************************
;; NOTE : wherever World is used, its World% type
;; A World is a (new World% [target Target%] [rectangles ListOf<Rectangle%>]
;;                          [speed PosInt])

;; Interpretation: represents a world, containing a target and a list of
;; rectangles and speed

;; World% -- a class that satisfies the World<%> interface.

(define World%                    ; World% implements the world interface
  (class* object% (World<%>)        
    ;; what you need to create an object of this class
    (init-field target)           ; a Target% - target 
    (init-field rectangles)       ; a ListOf<Rectangle%> - the list of 
    ; rectangles.             
    (init-field speed)            ; speed of rectangle
    
    (super-new)
    
    ;; on-tick : -> World%
    ;; GIVEN : No arguments
    ;; RETURNS: A world like this one, but as it should be after a tick
    ;; EXAMPLES:
    ;; (send (send W0 on-tick) get-x) -> CANVAS-CENTER-X
    ;; (send (send W0 on-tick) get-y) -> CANVAS-CENTER-Y
    ;; STRATEGY: HOFC
    (define/public (on-tick)
      (new World%
           [target (send target on-tick)]
           [rectangles (map
                        ;; Rectangle -> Rectangle
                        ;; GIVEN : a rectangle
                        ;; RETURNS : the same rectangle after tick
                        (lambda (r) (send r on-tick))
                        rectangles)]
           [speed speed]))
    
    ;; on-mouse : Number Number MyWorldMouseEvent -> World%
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given mouse event.
    ;; EXAMPLES:
    ;; (send (send w-having-one-rectangle-selected on-mouse 20 30 "drag")
    ;; get-y) = 30
    ;; (send (send w-having-one-rectangle-selected on-mouse 20 30 "drag") 
    ;; get-x) = 20
    ;; STRATEGY: HOFC
    (define/public (on-mouse x y evt)
      (new World%
           [target (send target on-mouse x y evt)]
           [rectangles (map
                        ;; Rectangle -> Rectangle
                        ;; GIVEN : a rectangle
                        ;; RETURNS : the same rectangle after mouse event
                        (lambda (r) (send r on-mouse x y evt))
                        rectangles)]
           [speed speed]))
    
    ;; on-key : MyWorldKeyEvent -> World%
    ;; GIVEN : a key event
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given key event.
    ;; EXAMPLES:
    ;; (length (send (send W1 on-key "n") get-rectangles)) = 2
    ;; STRATEGY: STRUCTURAL DECOMPOSITION on MyWorldKeyEvent (kev)
    ;; DETAILS: on the "n" key press creates a rectangle in the world moving in
    ;; the east direction
    (define/public (on-key kev)
      (cond
        [(key=? kev "n")
         (new World%
              [target (send target on-key kev)]
              [rectangles (cons 
                           (send (make-rectangle target speed) on-key kev)
                           rectangles)]
              [speed speed])]
        [else this]))    
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : a scene
    ;; RETURNS: a scene like the given one, but with this world painted
    ;; on it.
    ;; EXAMPLES :
    ;; (send W0 add-to-scene EMPTY-CANVAS)=> CIRC-IMG
    ;; STRATEGY: HOFC
    (define/public (add-to-scene worldscene)
      (local
        ;; first add the target to the scene
        ((define scene-with-target (send target add-to-scene worldscene)))
        ;; add all the rectangles one by one to the scene
        (foldr
         ;; Rectangle Scene -> Scene
         ;; GIVEN : a rectangle
         ;; RETURNS : the scene with given rectangle
         (lambda (r scene)
           (send r add-to-scene scene))
         scene-with-target
         rectangles)))
    
    ;; (get-x)-> Integer
    ;; (get-y)-> Integer
    ;; Given: no arguments
    ;; Returns: the x and y coordinates of the target in this world
    ;; EXAMPLES:
    ;; (send W0 get-x) = CANVAS-CENTER-X
    ;; (send W0 get-y) = CANVAS-CENTER-Y
    ;; STRATEGY : DOMAIN KNOWLEDGE
    (define/public (get-x) (send target get-x))
    (define/public (get-y) (send target get-y))
    
    ;; get-selected? -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the target is selected in this world, else return
    ;; false
    ;; EXAMPLES: (send W0 get-selected?) = false
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-selected?) (send target get-selected?))
    
    ;; get-target -> Target
    ;; Given: no arguments
    ;; Returns: the target from the world
    ;; EXAMPLES:
    ;; (send (send W0 get-target) get-x) = CANVAS-CENTER-X
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-target) target)
    
    ;; get-rectangles -> ListOf<Rectangle%>
    ;; Given: no arguments
    ;; Returns: list of rectangles from the world
    ;; EXAMPLES: (length (send (send W1 on-key "n") get-rectangles)) = 2
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-rectangles) rectangles)
    
    ;; get-speed -> PosInt
    ;; Given: no arguments
    ;; Returns: the speed of the rectangle
    ;; EXAMPLES:
    ;; (send W0 get-speed) = 5
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-speed) speed)
    ))

;; *****************************************************************************
;; Rectangle Interface :
(define Rectangle<%>
  (interface ()
    
    ;; -> Rectangle<%>
    ;; Given: no arguments
    ;; Returns: the Rectangle<%> that should follow this one after a tick
    on-tick                             
    
    ;; Integer Integer MouseEvent -> Rectangle<%>
    ;; Given: a mouse location and a mouse event
    ;; Returns: the Rectangle<%> that should follow this one after the
    ;; given MouseEvent
    on-mouse
    
    ;; KeyEvent -> Rectangle<%>
    ;; Given: a key event
    ;; Returns: the Rectangle<%> that should follow this one after the
    ;; given KeyEvent
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
    ))

;; *****************************************************************************
;; NOTE : Wherever Rectangle is used, its Rectangle% type

;; Rectangle% -- a class that satisfies the Rectangle<%> interface
;; (shown below).

;; A Rectangle is a (new Rectangle% [x Integer] [y Integer]  
;;                                  [mx Integer] [my Integer]
;;                                  [speed PosInt] [selected? Boolean]
;;                                  [direction String]
(define Rectangle%
  (class* object% (Rectangle<%>)
    (init-field x y mx my speed)
    (init-field [selected? false])
    (init-field [direction "East"])
    
    (field [IMG (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "green")])
    
    (super-new)
    
    ;; on-tick : -> Rectangle
    ;; GIVEN : No arguments
    ;; RETURNS: A Rectangle like this one, but as it should be after a tick
    ;; EXAMPLES: 
    ;; (send (send rect1 on-tick) get-x) = (+ CANVAS-CENTER-X SPEED)
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (on-tick)
      (if selected?
          this
          (rectangle-after-tick x y
                                mx my
                                speed
                                selected?
                                direction)))
    
    ;; rectangle-after-tick : Number Number Number Number Number 
    ;;                        Booolean String -> Rectangle
    ;; GIVEN : the x,y coordinates, the mouse x and y coordinates, speed, 
    ;;         boolean denoting whether rectangle is selected or not, and the
    ;;         direction of the rectangle.
    ;; RETURNS : the same rectangle after a tick
    ;; EXAMPLES: 
    ;; (send 
    ;; (send rect1 rectangle-after-tick 60 70 120 130 5 true "East") 
    ;; get-x) =
    ;; (+ CANVAS-CENTER-X SPEED)
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (rectangle-after-tick x y mx my speed selected? direction)
      (new Rectangle% 
           [x (send this new-x-after-tick)]
           [direction (send this direction-after-tick)]
           [y y] [mx mx] [my my] [speed speed] [selected? selected?]))
    
    ;; direction-after-tick : -> String
    ;; GIVEN : No arguments
    ;; RETURNS : direction string
    ;; EXAMPLES :(send rect2 direction-after-tick) = "East"
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (direction-after-tick)
      (if (send this rectangle-touching-x-boundary?)
          (send this change-direction)
          direction))
    
    ;; rectangle-touching-x-boundary? : -> Boolean
    ;; GIVEN : No arguments
    ;; RETURNS : boolean true or false
    ;; EXAMPLES:
    ;; (send rect1 rectangle-touching-x-boundary?) = false
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (rectangle-touching-x-boundary?)
      (or (= (send this new-x-after-tick)
             RECTANGLE-HALF-WIDTH)
          (= (send this new-x-after-tick) 
             (- CANVAS-WIDTH RECTANGLE-HALF-WIDTH))))
    
    ;; change-direction : -> String
    ;; GIVEN : No arguments
    ;; RETURNS : direction string
    ;; EXAMPLES:
    ;;(send rect1 change-direction) = "West" 
    ;; STRATEGY : STRUCTURAL DECOMPOSITION of Direction
    (define/public (change-direction)
      (cond
        [(string=? direction "West") "East"]
        [(string=? direction "East") "West"]))
    
    ;; new-x-after-tick -> Number
    ;; GIVEN : No arguments
    ;; RETURNS : a number
    ;; EXAMPLES:
    ;; (send rect2 new-x-after-tick) = (+ CANVAS-CENTER-X SPEED)
    ;; STRATEGY : FUNCTION COMPOSITION
    ;; STRATEGY : STRUCTURAL DECOMPOSITION of Direction 
    (define/public (new-x-after-tick)
      (cond
        [(string=? direction "West")
         (max (- x speed) RECTANGLE-HALF-WIDTH)]
        [(string=? direction "East") 
         (min (+ x speed) (- CANVAS-WIDTH RECTANGLE-HALF-WIDTH))]))
    
    ;; on-key : KeyEvent -> Rectangle
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given key event.
    ;; DETAILS: a Rectangle ignores key events
    ;; EXAMPLES:
    ;; (send (send rect1 on-key "ab") get-x) = CANVAS-CENTER-X
    ;; STRATEGY: domain knowledge
    (define/public (on-key kev) this)      
    
    ; on-mouse : Number Number MouseEvent -> Rectangle
    ; GIVEN: the location of a mouse event, and the mouse event
    ; RETURNS: the Rectangle that should follow this one after the given
    ; mouse event.
    ; EXAMPLES:
    ; (send (send rect1 on-mouse 120 130 "button-down") is-selected?) = false
    ; (send (send rect2 on-mouse 120 130 "drag") get-x) = (+ CANVAS-CENTER-X 120)

    ; STRATEGY: STRUCT DECOMP on evt : MouseEvent
    (define/public (on-mouse mouse-x mouse-y evt)
      (cond
        [(mouse=? evt "button-down")
         (send this rectangle-after-button-down mouse-x mouse-y)]
        [(mouse=? evt "drag") 
         (send this rectangle-after-drag mouse-x mouse-y)]
        [(mouse=? evt "button-up")
         (send this rectangle-after-button-up)]
        [else this]))
    
    
     ;; rectangle-after-button-down : Number Number -> Rectangle
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the Rectangle that should follow this one after a button
    ;; down at the given location
    ;; DETAILS:  If the event is inside
    ;; the Rectangle, returns a Rectangle just like this Rectangle, except that
    ;; it is selected.  Otherwise returns the Rectangle unchanged.
    ;; EXAMPLES:
    ;; (send (send rect2 rectangle-after-button-down 60 90) is-selected?) = true
    ;; STRATEGY: structural decomposition on this
    (define/public (rectangle-after-button-down mouse-x mouse-y)
      (if (send this in-rect? mouse-x mouse-y)
          (new Rectangle% 
               [x x] [y y] [mx mouse-x] [my mouse-y] 
               [direction direction] [speed speed] [selected? true])
          this))
    
    ;; rectangle-after-drag : Number Number -> Rectangle
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the Rectangle that should follow this one after a drag at
    ;; the given location 
    ;; DETAILS: if Rectangle is selected, move the Rectangle to the mouse
    ;; location, otherwise ignore.
    ;; EXAMPLES:
    ;; (send (send rect2 rectangle-after-drag 70 80) get-x) = 
    ;; (+ CANVAS-CENTER-X SPEED)
    ;; STRATEGY: domain knowledge 
    (define/public (rectangle-after-drag mouse-x mouse-y)
      (if selected?
          (new Rectangle% 
               [x (+ x (- mouse-x mx))] 
               [y (+ y (- mouse-y my))] 
               [mx mouse-x] [my mouse-y] 
               [direction direction] [speed speed] [selected? selected?])
          this))
    
    ;; rectangle-after-button-up : -> Rectangle
    ;; RETURNS: the Rectangle that should follow this one after a button-up
    ;; DETAILS: button-up unselects all Rectangles
    ;; EXAMPLES: 
    ;; (send (send rect1 rectangle-after-button-up) is-selected?) = false
    ;; STRATEGY: domain knowledge
    (define/public (rectangle-after-button-up)
      (new Rectangle% 
           [x (send this bouncing-back)] [y y] [mx mx] [my my]
           [direction direction] [speed speed] [selected? false]))
    
    
    ;; bouncing-back : -> PosInt
    ;; GIVEN : No arguments
    ;; RETURNS : a posint
    ;; EXAMPLE : 
    ;; (send rect1 bouncing-back) = CANVAS-CENTER-X
    ;; STRATEGY : STRUCTURAL DECOMPOSITION on Direction
    (define/public (bouncing-back)
      (cond
        [(string=? direction "West")
         (max x RECTANGLE-HALF-WIDTH)]
        [(string=? direction "East") 
         (min x (- CANVAS-WIDTH RECTANGLE-HALF-WIDTH))]))
    
    
    ;; add-to-scene : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this Rectangle painted
    ;; on it.
    ;; EXAMPLES:
    ;; (send rect1  add-to-scene CIRC-IMG) = ONE-RECT-IMAGE1  
    ;; STRATEGY: function composition
    (define/public (add-to-scene scene)
      (place-image IMG x y scene)) 
    
    ;; in-rect? : Number Number -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this Rectangle.
    ;; EXAMPLES : 
    ;; (send rect1 in-rect? 40 50) = false
    ;; STRATEGY: Domain knowledge
    (define/public (in-rect? other-x other-y)
      (and
       (<= 
        (- x RECTANGLE-HALF-WIDTH)
        other-x
        (+ x RECTANGLE-HALF-WIDTH))
       (<= 
        (- y HALF-RECTANGLE-HEIGHT)
        other-y
        (+ y HALF-RECTANGLE-HEIGHT))))
    
    ;; -> Integer
    ;; Given: no arguments
    ;; Returns: the x and y coordinates of the rectangle in this world
    ;; EXAMPLES:
    ;; (send rect1 get-x) = CANVAS-CENTER-X
    ;; (send rect1 get-y) = CANVAS-CENTER-Y
    (define/public (get-x) x)
    (define/public (get-y) y)
    
    ;; is-selected? -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the rectangle is selected in this world, else return
    ;; false
    ;; EXAMPLES:
    ;; (send rect1 is-selected?) = false
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (is-selected?) selected?)
    
    ;; get-direction -> String
    ;; Given: no arguments
    ;; Returns: the direction of the rectangle
    ;; EXAMPLES: 
    ;; (send rect1 get-direction) = "East"
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-direction) direction)
    
    ;; get-target -> PosInt
    ;; Given: no arguments
    ;; Returns: the speed of the rectangle
    ;; EXAMPLES:
    ;; (send rect1 get-speed) = 5
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-speed) speed)
    ))
;; *****************************************************************************
;; NOTE : Wherever Target is used its a Target% type

;; Target% -- a class that satisfies the Rectangle<%> interface
;; (shown below).

;; A Target is a (new Target% [x Integer] [y Integer]  
;;                            [mx Integer] [my Integer]
;;                            [selected? Boolean]
;;                            [radius PosInt]
(define Target%
  (class* object% () 
    (init-field x y mx my)                       ;; x,y and mouse x,y coordinate
    (init-field [selected? false])               ;; boolean denoting selected
    (init-field [radius TARGET-RADIUS])          ;; radius
    (field [IMG (circle radius "outline" "red")]);; img having a circle
    
    (super-new)
    
    ;; on-tick : -> Target
    ;; GIVEN : No arguments
    ;; RETURNS: A Target like this one, but as it should be after a tick
    ;; EXAMPLES:
    ;; (send (send target1 on-tick) get-x) = CANVAS-CENTER-X
    ;; STRATEGY : DOMAIN KNOWLEDGE
    (define/public (on-tick)
      this)
    
    ;; on-key : MyWorldKeyEvent -> Target
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given key event.
    ;; DETAILS: a Target ignores key events
    ;; EXAMPLES: 
    ;; (send target1 on-key "n") = target1
    ;; STRATEGY: domain knowledge
    (define/public (on-key kev)
      this)      
    
    ; on-mouse : Number Number MouseEvent -> Rectangle
    ; GIVEN: the location of a mouse event, and the mouse event
    ; RETURNS: the Rectangle that should follow this one after the given
    ; mouse event.
    ; EXAMPLES:
    ; (send (send target1 on-mouse 60 70 "button-down") get-selected?) = false
    ; STRATEGY: STRUCT DECOMP on evt : MouseEvent
    (define/public (on-mouse mouse-x mouse-y evt)
      (cond
        [(mouse=? evt "button-down")
         (send this target-after-button-down mouse-x mouse-y)]
        [(mouse=? evt "drag") 
         (send this target-after-drag mouse-x mouse-y)]
        [(mouse=? evt "button-up")
         (send this target-after-button-up)]
        [else this]))
    
    ;; target-after-button-down : Number Number -> Target
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the Target that should follow this one after a button
    ;; down at the given location
    ;; DETAILS:  If the event is inside
    ;; the Target, returns a Target just like this Target, except that it is
    ;; selected.  Otherwise returns the Target unchanged.
    ;; EXAMPLES:
    ;; (send 
    ;; (send target-selected taget-after-button-down 80 90)
    ;; get-selected?) = 
    ;; true
    ;; STRATEGY: structural decomposition on this
    (define/public (target-after-button-down mouse-x mouse-y)
      (if (send this within-target? mouse-x mouse-y)
          (new Target% 
               [x x] [y y] 
               [mx mouse-x] [my mouse-y] 
               [selected? true])
          this))
    
    ;; target-after-drag : Number Number -> Target
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the Target that should follow this one after a drag at
    ;; the given location 
    ;; DETAILS: if Target is selected, move the Target to the mouse location,
    ;; otherwise ignore.
    ;; EXAMPLES:
    ;; (send (send target-selected target-after-drag 80 90) get-x) = 80
    ;; STRATEGY: domain knowledge  (NOTE: new doesn't count)
    (define/public (target-after-drag mouse-x mouse-y)
      (if selected?
          (new Target% 
               [x (+ x (- mouse-x mx))] 
               [y (+ y (- mouse-y my))] 
               [mx mouse-x] [my mouse-y] 
               [selected? selected?])
          this))
    
    ;; target-after-button-up : -> Target
    ;; RETURNS: the Target that should follow this one after a button-up
    ;; DETAILS: button-up unselects all Targets
    ;; EXAMPLES:
    ;; (send (send target1 target-after-button-up) get-selected?) = false
    ;; STRATEGY: domain knowledge  (NOTE: new doesn't count)
    (define/public (target-after-button-up)
      (new Target% 
           [x x] [y y] 
           [mx mx] [my my] 
           [selected? false]))
    
    ;; add-to-scene : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this Target painted
    ;; on it.
    ;; EXAMPLES:
    ;; (send target1 add-to-scene EMPTY-CANVAS) = CIRC-IMG
    ;; STRATEGY: function composition
    (define/public (add-to-scene scene)
      (place-image IMG x y scene))
    
    ;; within-target? : Number Number -> Boolean
    ;; GIVEN: a location on the canvas
    ;; RETURNS: true iff the location is inside this Target.
     ;; EXAMPLE:
    ;; (send target1 within-target? 90 140)= false
    ;; STRATEGY : DOMAIN KNOWLEDGE
    (define/public (within-target? other-x other-y)
      (<= (+ (sqr (- x other-x)) (sqr (- y other-y)))
          (sqr radius)))
    
    ;; -> Integer
    ;; Given: no arguments
    ;; Returns: the x and y coordinates of the target in this world
     ;; EXAMPLES:
    ;; (send target1 get-x) = CANVAS-CENTER-X
    ;; (send target1 get-y) = CANVAS-CENTER-Y
    ;; STRATEGY : DOMAIN KNOWLEDGE
    (define/public (get-x) x)
    (define/public (get-y) y)
    
    ;; get-selected? -> Boolean
    ;; Given: no arguments
    ;; Returns: true iff the target is selected in this world, else return
    ;; false
    ;; EXAMPLES:
    ;; (send target1 get-selected?) = false
    ;; STRATEGY : FUNCTION COMPOSITION
    (define/public (get-selected?) selected?)
    
    ))

;; *****************************************************************************
;; make-rectangle : Target PosInt -> Rectangle
;; GIVEN : A Target and the speed of the rectangle
;; RETURNS : A rectangle
;; EXAMPLES : (make-rectangle (make-target) 2) -> (object:Rectangle% ...)
;; STRATEGY : DOMAIN KNOWLEDGE
(define (make-rectangle target speed)
  (new Rectangle% 
       [x (send target get-x)]
       [y (send target get-y)]
       [mx 0] [my 0]
       [speed speed]))
;; *****************************************************************************
;; make-target :  -> Target
;; GIVEN : No arguments
;; RETURNS : A target
;; EXAMPLES : (make-target) - >(object:Target% ...)
;; STRATEGY : DOMAIN KNOWLEDGE
(define (make-target)
  (new Target% 
       [x CANVAS-CENTER-X] 
       [y CANVAS-CENTER-Y] 
       [mx 0] [my 0]))
;; *****************************************************************************

;; make-world : PosInt -> World%
;; Creates a world with no rectangles, but in which any rectangles
;; created in the future will travel at the given speed.
;; GIVEN : the speed of the rectangle
;; RETURNS : The world initially with no rectangles but if a rectangle gets
;;           created it will move with the given speed
;; EXAMPLES :(make-world 2) -> (object:World% ...)
;; STRATEGY : DOMAIN KNOWLEDGE
(define (make-world speed)
  (new World%
       [target (make-target)]
       [rectangles empty]
       [speed speed]))

;; run : PosNum PosInt -> World%
;; GIVEN : a frame rate (in seconds/tick) and a rectangle-speed (in pixels/tick)
;; creates and runs a world.  Returns the final state of the world
;; RETURNS : the world
(define (run rate speed)
  (big-bang (make-world speed)
            (on-tick
             ;; World -> World
             ;; GIVEN : A world
             ;; RETURNS : the same world after tick
             (lambda (w) (send w on-tick))
             rate)
            (on-draw
             ;; World -> World
             ;; GIVEN : A world
             ;; RETURNS : the same world after tick
             (lambda (w) (send w add-to-scene EMPTY-CANVAS)))
            (on-key
             ;; World MyWorldKeyEvent -> World
             ;; GIVEN : A world and a key event
             ;; RETURNS : The same world after key event
             (lambda (w kev) (send w on-key kev)))
            (on-mouse
             ;; World PosInt PosInt MyMouseKeyEvent -> World
             ;; GIVEN : A world, x-y coordinate and mouse event
             ;; RETURNS : The same world after mouse event
             (lambda (w x y evt) (send w on-mouse x y evt)))))

;; *****************************************************************************
;; world-similar? : World World -> Boolean
;; GIVEN : two worlds
;; RETURNS : true if the two worlds are same
;; EXAMPLES : tests below
;; STRATEGY : FUNCTION COMPOSITION
(define (world-similar? W1 w2)
  (and
   (target-similar? (send W1 get-target) (send w2 get-target))
   (andmap
    ;; Rectangle Rectangle -> Boolean
    ;; GIVEN : two rectangles
    ;; RETURNS : true if both are same
    (lambda (r1 r2) (rectangle-similar? r1 r2))
    (send W1 get-rectangles)
    (send w2 get-rectangles))
   (equal? (send W1 get-speed) (send w2 get-speed))))

;; rectangle-similar? : Rectangle Rectangle -> Boolean
;; GIVEN : two rectangles
;; RETURNS : true if the two rectangles are same
;; EXAMPLES : tests below
;; STRATEGY : FUNCTION COMPOSITION
(define (rectangle-similar? r1 r2)
  (and
   (equal? (send r1 get-x) (send r2 get-x))
   (equal? (send r1 get-y) (send r2 get-y))
   (equal? (send r1 is-selected?) (send r2 is-selected?))
   (equal? (send r1 get-direction) (send r2 get-direction))
   (equal? (send r1 get-speed) (send r2 get-speed))))

;; target-similar? : Target Target -> Boolean
;; GIVEN : two targets
;; RETURNS : true if the two targets are same
;; EXAMPLES : tests below
;; STRATEGY : FUNCTION COMPOSITION
(define (target-similar? t1 t2)
  (and 
   (equal? (send t1 get-x) (send t2 get-x))
   (equal? (send t1 get-y) (send t2 get-y))
   (equal? (send t1 get-selected?) (send t2 get-selected?))))

;; *****************************************************************************

;; Examples for test
(define SPEED 5)
(define TARGET (make-target))

(define scene-with-everything-at-center-unselected
  (place-image 
   (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "green")
   CANVAS-CENTER-X CANVAS-CENTER-Y
   (place-image (circle TARGET-RADIUS "outline" "red")
                CANVAS-CENTER-X CANVAS-CENTER-Y EMPTY-CANVAS)))

(define w-having-one-rectangle-east-moving-rectangle
  (new Rectangle% 
       [x RECTANGLE-HALF-WIDTH]
       [y CANVAS-CENTER-Y]
       [mx RECTANGLE-HALF-WIDTH] 
       [my CANVAS-CENTER-Y]
       [selected? false]
       [speed SPEED]))

(define w-having-one-rectangle-east-moving-target
  (new Target%
       [x RECTANGLE-HALF-WIDTH] 
       [y CANVAS-CENTER-Y]
       [mx RECTANGLE-HALF-WIDTH]
       [my CANVAS-CENTER-Y]
       [selected? false]))

(define w-having-one-rectangle-east-moving 
  (new World%
       [target w-having-one-rectangle-east-moving-target]
       [rectangles (cons w-having-one-rectangle-east-moving-rectangle
                         empty)]
       [speed SPEED]))

;; Constants for Testing
(define W0 (make-world SPEED))

(define W1 (send (make-world SPEED) on-key "n"))

(define w-having-one-rectangle (send (make-world SPEED) on-key "n"))

(define w-having-one-rectangle-selected 
  (send w-having-one-rectangle on-mouse CANVAS-CENTER-X CANVAS-CENTER-Y 
        "button-down"))

(define  RECTANGLE 
  (rectangle RECTANGLE-WIDTH RECTANGLE-HEIGHT "outline" "green"))

(define CIRCLE (circle TARGET-RADIUS "outline" "red"))


(define CIRC-IMG (place-image CIRCLE CANVAS-CENTER-X 
                              CANVAS-CENTER-Y EMPTY-CANVAS)) 

(define ONE-RECT-IMAGE (place-image RECTANGLE 200 150 
                                    (place-image CIRCLE CANVAS-CENTER-X
                                                 CANVAS-CENTER-Y EMPTY-CANVAS)))

;; Constants for Rectangle

(define rect1  (new Rectangle% 
                    [x CANVAS-CENTER-X]
                    [y CANVAS-CENTER-Y]
                    [mx 0]
                    [my 0]
                    [speed SPEED]
                    [selected? false]
                    [direction "East"]))

(define rect2  (new Rectangle% 
                    [x CANVAS-CENTER-X]
                    [y CANVAS-CENTER-Y]
                    [mx 0]
                    [my 0]
                    [speed SPEED]
                    [selected? true]
                    [direction "East"]))

;; Constants for Target

(define target1 (new Target%
                     [x CANVAS-CENTER-X]
                     [y CANVAS-CENTER-X]
                     [mx 0]
                     [my 0]
                     [selected? false]
                     [radius TARGET-RADIUS]))


(define target-selected (new Target%
                         [x CANVAS-CENTER-X]
                         [y CANVAS-CENTER-Y]
                         [mx CANVAS-CENTER-X]
                         [my CANVAS-CENTER-Y]
                         [selected? true]
                         [radius  TARGET-RADIUS]))
                     





;; *****************************************************************************
(define-test-suite rectangle-tests
  
  (local ((define r1 (make-rectangle TARGET SPEED)))
    (check-eqv? r1 r1
                "A Rectangle is eqv? to itself"))
  
  (local ((define t1 (make-rectangle TARGET SPEED)))
    (check-equal? t1 t1
                  "A Rectangle is equal? to itself"))
  
  (local ((define W1 (send (make-world SPEED) on-key "n"))
          (define w2 (send W1 on-key "n")))
    (check-equal?
     (length (send w2 get-rectangles))
     2
     "after 2 'n', there should be 2 rectangles"))
  
  (local ((define W1 (send (make-world SPEED) on-key " "))
          (define w2 (send W1 on-key " ")))
    (check-equal? W1 w2
                  "on any other key event"))
  
  (local (;; A world with single rectangle
          (define w-having-one-rectangle
            (send (make-world SPEED) on-key "n"))
          
          ;; select the rectangle
          (define w-having-one-rectangle-selected
            (send w-having-one-rectangle
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "button-down"))
          
          ;; drag the selected rectangle to the right end
          (define w-having-one-rectangle-dragged
            (send w-having-one-rectangle-selected 
                  on-mouse (- CANVAS-WIDTH RECTANGLE-HALF-WIDTH)
                  CANVAS-CENTER-Y "drag"))
          
          ;; deselect the rectangle
          (define w-having-one-rectangle-dragged-unselected
            (send w-having-one-rectangle-dragged 
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "button-up"))
          
          ;; reversing the direction o next tick
          (define w-having-one-rectangle-dragged-unselected-after-tick
            (send w-having-one-rectangle-dragged-unselected on-tick))
          
          
          
          ;; USING THE SAME RECTANGLE FOR REVERSED DIRECTION
          ;; "button-down" the above rectangle
          (define w-having-one-rectangle-dragged-selected1
            (send w-having-one-rectangle-dragged-unselected-after-tick
                  on-mouse (- CANVAS-WIDTH RECTANGLE-HALF-WIDTH)
                  CANVAS-CENTER-Y "button-down"))
          ;; drag the rectangle to the left end
          (define w-having-one-rectangle-dragged1
            (send w-having-one-rectangle-dragged-selected1 
                  on-mouse RECTANGLE-HALF-WIDTH
                  CANVAS-CENTER-Y "drag"))
          ;; deselect it
          (define w-having-one-rectangle-dragged-unselected1
            (send w-having-one-rectangle-dragged1 
                  on-mouse RECTANGLE-HALF-WIDTH
                  CANVAS-CENTER-Y "button-up"))
          ;; again the direction will reverse on touching the wall
          (define w-having-one-rectangle-dragged-unselected1-after-tick
            (send w-having-one-rectangle-dragged-unselected1 on-tick)))
    ;; Compare above world with constant world defined above in examples
    (check world-similar? w-having-one-rectangle-east-moving
           w-having-one-rectangle-dragged-unselected1-after-tick
           "Both worlds are not equal"))
  
  ;; test case for add-to-scene function
  (local ((define w-having-one-rectangle 
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-scene
            (send w-having-one-rectangle add-to-scene EMPTY-CANVAS)))
    (check-equal? w-having-one-rectangle-scene
                  scene-with-everything-at-center-unselected
                  "Scene with world having single unselected rectangle
                  not proper"))
  
  ;; test case for get-x function
  (local ((define w-having-one-rectangle 
            (send (make-world SPEED) on-key "n")))
    (check-equal? (send w-having-one-rectangle get-x)
                  CANVAS-CENTER-X
                  "Target x-position is at CANVAS-CENTER-X"))
  
  ;; get-y
  (local ((define w-having-one-rectangle 
            (send (make-world SPEED) on-key "n")))
    (check-equal? (send w-having-one-rectangle get-y)
                  CANVAS-CENTER-Y
                  "Target y-position is at CANVAS-CENTER-Y"))
  
  ;; get-selected?
  (local ((define w-having-one-rectangle
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-selected
            (send w-having-one-rectangle
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "button-down")))
    (check-equal? (send w-having-one-rectangle-selected get-selected?)
                  true
                  "Target is selected"))
  
  
  ;; rectangle unselected after tick
  (local ((define w-having-one-rectangle 
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-after-tick 
            (send w-having-one-rectangle on-tick)))
    (check-not-eqv? w-having-one-rectangle
                    w-having-one-rectangle-after-tick
                    "A Both worlds are not equal"))
  
  ;; button down outside rectangle
  (local ((define w-having-one-rectangle
            (send (make-world SPEED) on-key "n"))
          (define w-1-rect-after-mouse-down-top-left-corner
            (send w-having-one-rectangle
                  on-mouse 1
                  1 "button-down")))
    (check world-similar? w-having-one-rectangle
           w-1-rect-after-mouse-down-top-left-corner
           "A Both worlds are equal"))
  
  (local ((define w-having-one-rectangle
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-selected
            (send w-having-one-rectangle
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "button-down"))
          (define w-having-one-rectangle-selected-after-tick
            (send w-having-one-rectangle-selected on-tick)))
    (check world-similar? w-having-one-rectangle-selected
           w-having-one-rectangle-selected-after-tick
           "A Both worlds are equal"))
  
  ;; drag the rectangle
  (local ((define w-having-one-rectangle 
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-dragged
            (send w-having-one-rectangle
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "drag")))
    (check world-similar? w-having-one-rectangle 
           w-having-one-rectangle-dragged
           "A Both worlds are equal"))
  
  (local ((define w-having-one-rectangle
            (send (make-world SPEED) on-key "n"))
          (define w-having-one-rectangle-after-mouse-move
            (send w-having-one-rectangle
                  on-mouse CANVAS-CENTER-X
                  CANVAS-CENTER-Y "move")))
    (check world-similar? w-having-one-rectangle 
           w-having-one-rectangle-after-mouse-move
           "Both worlds are equal"))
  
  )
(run-test rectangle-tests)