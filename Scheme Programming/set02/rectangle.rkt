;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname rectangle) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; start with (main 0)

(require rackunit)
(require rackunit/text-ui)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")


(provide initial-world)
(provide world-to-center)
(provide world-selected?)
(provide world->scene)
(provide world-after-mouse-event)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; MAIN FUNCTION.

;run : Any -> World
;GIVEN: any value
;EFFECT: Ignores its argument and runs the world.
;RETURNS: the final state of the world.

(define (run initial-pos)
  (big-bang (initial-world 0)
            (on-draw world->scene)
            (on-mouse world-after-mouse-event)
            ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

(define CIRCLE-IMAGE (circle 5 "solid" "red"))
(define RECT-IMAGE (rectangle 100 60 "solid" "green"))
(define RECT-IMAGE-OUTLINE (rectangle 100 60 "outline" "green"))

;; dimensions of the canvas
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 300)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;; dimensions of the rectangle
(define HALF-RECTANGLE-WIDTH  (/ (image-width  RECT-IMAGE) 2))
(define HALF-RECTANGLE-HEIGHT (/ (image-height RECT-IMAGE) 2))

;; Mouse co-ordinates
(define INITIAL-X 0)
(define INITIAL-Y 0)

;; initial world
(define X 200)
(define Y 100)
(define MX 0)
(define MY 0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA  DEFINITION

(define-struct world(x-pos y-pos mx my selected?))
;; A World is a (make-world Number Number Boolean Boolean)
;; Interpretation: 
;; x-pos, y-pos give the position of the rectangle image. 
;; mx,my gives the position of the mouse click
;; selected? describes whether or not the cat is selected.

;; template:
;; world-fn : World -> ??
;(define (world-fn w)
; (... (world-x-pos w) (world-y-pos w) (world-paused? w) (world-selected? w)))

;
;initial-world : Any -> World
;GIVEN: any value
;RETURNS: the initial world.
;Ignores its argument.
(define(initial-world num)
(make-world X Y MX MY false ))

;
;world-to-center : World -> Posn
;GIVEN: a world
;RETURNS: the coordinates of the center of the rectangle as a Posn
; EXAMPLES : (world-to-center 
(define (world-to-center w)
  ( make-posn (world-x-pos w) (world-y-pos w)))
;
;world-selected? : World -> Boolean
;GIVEN a world
;RETURNS: true iff the rectangle is selected.
;
;; world-after-mouse-event : World Number Number MouseEvent -> World
;; produce the world that should follow the given mouse event
;; EXAMPLES :
;; strategy: struct decomp on mouse events
(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up")(world-after-button-up w mx my)]
    [else w]))

;; world-after-button-down : World Number Number -> World
;; RETURNS: the world following a button-down at the given location.
;; if the button-down is inside the cat, return a cat just like the
;; given one, except that it is selected.
;; STRATEGY: struct decomp on world
(define (world-after-button-down w mx my)
  (if (within-rectangle? w mx my)
      (make-world (world-x-pos w) (world-y-pos w) mx my true)
      w))


;; world-after-drag : World Number Number -> World
;; RETURNS: the world following a drag at the given location.
;; if the world is selected, then return a world just like the given
;; one, except that it is now centered on the mouse position.
;; STRATEGY: struct decomp on world
(define (world-after-drag w mx my)
  (if (world-selected? w)
      (make-world (- (world-x-pos w)
                     (- (world-mx w) mx)) 
                  (- (world-y-pos w) 
                     (- (world-my w) my)) 
                  mx my true )w))

;; world-after-button-up : World Number Number -> World
;; RETURNS: the world following a button-up at the given location.
;; if the cat is selected, return a cat just like the given one,
;; except that it is no longer selected.
;; STRATEGY: struct decomp on world
(define (world-after-button-up w mx my)
  (if (world-selected? w)
      (make-world (world-x-pos w) (world-y-pos w) mx my
                   false)
      w))
  

;; world->scene : World -> Scene
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world->scene (make-world 20 ??))
;;          = (place-image RECT RECT-X-COORD 20 EMPTY-CANVAS)
;; STRATEGY: structural decomposition [World]
(define (world->scene w)
  (cond
  [(world-selected? w)(place-image CIRCLE-IMAGE
               (world-mx w)
               (world-my w)
               (place-image RECT-IMAGE-OUTLINE (world-x-pos w) (world-y-pos w)  EMPTY-CANVAS))]
  [else (place-image RECT-IMAGE
               (world-x-pos w)
               (world-y-pos w)
               EMPTY-CANVAS) ]))



;; within-rectangle? : World Number Number -> World
;; RETURNS: true iff the given coordinate is inside the bounding box of
;; the cat.
;; EXAMPLES: see tests below
;; strategy: structural decomposition on w : World
(define (within-rectangle? w x y)
  (and
    (<= 
      (- (world-x-pos w) HALF-RECTANGLE-WIDTH)
      x
      (+ (world-x-pos w) HALF-RECTANGLE-WIDTH))
    (<= 
      (- (world-y-pos w) HALF-RECTANGLE-HEIGHT)
      y
      (+ (world-y-pos w) HALF-RECTANGLE-HEIGHT))))


(define-test-suite rectangle-tests
  (check-equal? (initial-world 8) (make-world 200 100 0 0 false))
  
  (check-equal? (world->scene (make-world 20 30 50 60 true))
                (place-image CIRCLE-IMAGE  50 60 
                             (place-image RECT-IMAGE-OUTLINE 20 30  EMPTY-CANVAS)))
  
  (check-equal? (world->scene (make-world 20 30 50 60 false))
                (place-image RECT-IMAGE  20 30 EMPTY-CANVAS))

  (check-equal? (within-rectangle? (make-world 20 30 40 50 true) 15 15) true false)

  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 true) 30 30 "move")
                (make-world 20 30 40 50 true))
  
  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 true) 30 30 "button-down")
                (make-world 20 30 30 30 true))
  
  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 false) 100 130 "button-down") 
                (make-world 20 30 40 50 false))
  
  (check-equal? (world-after-mouse-event
                (make-world 20 30 40 50 true) 30 30 "drag")
                (make-world 10 10 30 30 true))
  
  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 false) 30 30 "drag") 
                (make-world 20 30 40 50 false))
  
  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 true) 30 30 "button-up")
                (make-world 20 30 30 30 false))
  
  (check-equal? (world-after-mouse-event 
                (make-world 20 30 40 50 false) 30 30 "button-up") 
                (make-world 20 30 40 50 false))
  
  (check-equal? (world-to-center (make-world 20 30 40 50 true))
                (make-posn 20 30)))
(run-tests rectangle-tests)
