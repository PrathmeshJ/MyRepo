;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(provide initial-robot
  robot-left 
  robot-right
  robot-forward
  robot-north? 
  robot-south? 
  robot-east? 
  robot-west?)

; DATA DEFINITION
; Direcion is one of
; --NORTH : The North direction
; --SOUTH : The South direction
; --EAST  : The East direction
; --WEST  : The South direction

; TEMPLATE
;(define (direction-fn direction)
;  {cond
;    [(string=? direction NORTH ...)]
;    [(string=? direction SOUTH ...)]
;    [(string=? direction EAST ...)]
;    [(string=? direction WEST ...)]
;    }
;  )

(define-struct robot (xcoordinate ycoordinate direction))

;; A Robot is a 
;; (make-robot Integer Integer String)
;; Interp:
;; xcoordinate, ycoordinate is the coordinates where the robot is placed with
;; its center on the coordinates in cm

;; template
;; robot-fn : Robot -> ??

(define (robot-fn r)
  (... (robot-xcoordinate robot)
       (robot-ycoordinate robot)
       (robot-direction robot)
  )
)

;; initial-robot : PosInt PosInt -> Robot
;; GIVEN: a set of (x,y) coordinates
;; RETURNS: a robot with its center at those coordinates, facing north
;; (up).
;; EXAMPLES :
;; (initial-robot 200 300) -> make-robot 200 300 "NORTH"
;; (initial-robot 10 50) -> make-robot 10 50 "NORTH"
; Strategy : STRUCTURAL DECOMPOSITION

(define (initial-robot x-coordinate y-coordinate )
    (make-robot x-coordinate y-coordinate "NORTH")
  )

;; robot-north? : Robot -> Boolean
;; GIVEN: a Robot
;; RETURNS: true if the the Robot is facing NORTH
; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction
(define (robot-north? robot)
  (if (string=? (robot-direction robot) "NORTH") true false )
  )

;; robot-north? : Robot -> Boolean
;; GIVEN: a Robot
;; RETURNS: true if the the Robot is facing SOUTH
; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction
(define (robot-south? robot)
  (if (string=? (robot-direction robot) "SOUTH") true false )
  )

;; robot-north? : Robot -> Boolean
;; GIVEN: a Robot
;; RETURNS: true if the the Robot is facing EAST
; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction
(define (robot-east? robot)
  (if (string=? (robot-direction robot) "EAST") true false )
  )

;; robot-north? : Robot -> Boolean
;; GIVEN: a Robot
;; RETURNS: true if the the Robot is facing WEST
; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction
(define (robot-west? robot)
  (if (string=? (robot-direction robot) "WEST") true false )
  )

;;; robot-left : Robot -> Robot
;;; GIVEN : A robot in a particular direction
;;; RETURNS : The robot facing in the new direction in the left
;;; EXAMPLES :
;;; (robot-left (robot (200,200,NORTH) robot(200,200,WEST))
;;; (robot-left (robot (200,200,SOUTH) robot(200,200,EAST))
;;; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction

(define (robot-left robot)
  ( cond
    [(robot-north? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "WEST")]
    [(robot-west? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "SOUTH")]
    [(robot-south? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "EAST")]
    [(robot-east? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "NORTH")]
    )
  )

;;; robot-right : Robot -> Robot
;;; GIVEN : A robot in a particular direction
;;; RETURNS : The robot facingin the new direction in the right
;;; EXAMPLES :
;;; (robot-right (robot (200,200,NORTH) robot(200,200,EAST))
;;; (robot-right (robot (200,200,SOUTH) robot(200,200,WEST))
;;; Strategy : STRUCTURAL DECOMPOSITION on Robot->Direction

(define ( robot-right robot)
( cond
    [(robot-north? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "EAST")]
    [(robot-west? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "NORTH")]
    [(robot-south? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "WEST")]
    [(robot-east? robot)
     (make-robot (robot-xcoordinate robot) (robot-ycoordinate robot) "SOUTH")]
    )
  ) 

;;; possible-moves : robot PosInt -> robot
;;; GIVEN: The possible no of moves for the Robot
;;; RETURNS: the robot at the specified distance
;;; EXAMPLES :
;;; (possible-moves (robot(180 22 "NORTH") 15) (make-robot 180 15 "NORTH")) 
;;; (possible-moves (robot(180 22 "SOUTH" 15) (make-robot 180 37 "SOUTH"))
;;; (possible-moves (robot(180 22 "EAST") 10) (make-robot 185 22 "EAST"))
;;; (possible-moves (robot(180 22 "WEST") 10) (make-robot 165 22 "WEST"))
;   Strategy : STRUCTURAL DECOMPOSITION of Robot

(define ( possible-moves robot distance-to-travel)
  (cond
    [(and (robot-north? robot) (< distance-to-travel (- (robot-ycoordinate robot) 15)))
     (make-robot (robot-xcoordinate robot) (- (robot-ycoordinate robot) distance-to-travel) "NORTH")]
    
    [(and (robot-north? robot) (>= distance-to-travel (- (robot-ycoordinate robot) 15)))
     (make-robot (robot-xcoordinate robot) 15 "NORTH")]
    
    [(and (robot-south? robot) (< distance-to-travel (- 385 (robot-ycoordinate robot))))
     (make-robot (robot-xcoordinate robot) (+ (robot-ycoordinate robot) distance-to-travel) "SOUTH")]
    
    [(and (robot-south? robot) (>= distance-to-travel (- 385 (robot-ycoordinate robot))))
     (make-robot (robot-xcoordinate robot) 385 "SOUTH")]   
    
    [(and (robot-east? robot) (>= distance-to-travel (- 185 (robot-xcoordinate robot))))
     (make-robot 185 (robot-ycoordinate robot) "EAST")]
    
    [(and (robot-east? robot) (< distance-to-travel (- 185 (robot-xcoordinate robot))))
     (make-robot (+ (robot-xcoordinate robot) distance-to-travel) (robot-ycoordinate robot) "EAST" )]
    
    [(and (robot-west? robot) (>= distance-to-travel (- (robot-xcoordinate robot) 15)))
     (make-robot 15 (robot-ycoordinate robot) "WEST")]
    
    [(and (robot-west? robot) (< distance-to-travel (- (robot-xcoordinate robot) 15)))
     (make-robot (- (robot-ycoordinate robot) distance-to-travel) (robot-ycoordinate robot) "WEST" )]
    
   )
  )


;;; robot-forward : Robot PosInt -> Robot
;;; GIVEN: a robot and a distance to move
;;; RETURNS: the robot now placed at the specified distance
;;; STRATEGY: Functional composition
;;; EXAMPLES :
;;; (robot-forward (robot(200 200 NORTH) 10) robot(200 210 NORTH)) 
;;; (robot-forward (robot(200 200 SOUTH) 10) robot(200 190 SOUTH))
;;; (robot-forward (robot(200 200 EAST) 10) robot(210 200 EAST))
;;; (robot-forward (robot(200 200 WEST) 10) robot(190 200 WEST))
   
(define (robot-forward robot distance-to-travel) 
  (cond
    
    [ (robot-north? robot) (if-robot-north robot distance-to-travel)]
    [ (robot-south? robot) (if-robot-south robot distance-to-travel)]
    [ (robot-east? robot) (if-robot-east robot distance-to-travel)]
    [ (robot-west? robot) (if-robot-west robot distance-to-travel)]
    )
  )
 
;;; if-robot-north : Robot PosInt -> Robot
;;; GIVEN: a robot facing in the NORTH direction and a distance to move
;;; RETURNS: the robot now placed at the specified distance
;;; STRATEGY: STRUCTURAL DECOMPOSITION
(define (if-robot-north robot distance-to-travel)
  (cond
    [(and (> (robot-ycoordinate robot) 400)
          (and (> (robot-xcoordinate robot) 15) (< (robot-xcoordinate robot) 185)) )
          (possible-moves robot distance-to-travel) ] ;inside the canvas
    
    [(or (<= (robot-xcoordinate robot) 15) (>= (robot-xcoordinate robot) 185)) 
          (make-robot (robot-xcoordinate robot) (- (robot-ycoordinate robot) distance-to-travel) "NORTH" )]; outside the canvas walls
    
    [ (<= (robot-ycoordinate robot) 0)
          (make-robot (robot-xcoordinate robot) (- (robot-ycoordinate robot) distance-to-travel) "NORTH" )]
    
    [(and (>= (robot-xcoordinate robot) 0) (< (robot-xcoordinate robot) 200)
          (<= (robot-ycoordinate robot) 400)
          (>= (robot-ycoordinate robot) 0)) (possible-moves robot distance-to-travel)]
    )
  )
;;; if-robot-south : Robot PosInt -> Robot
;;; GIVEN: a robot facing in the SOUTH direction and a distance to move
;;; RETURNS: the robot now placed at the specified distance
;;; STRATEGY: STRUCTURAL DECOMPOSITION
(define (if-robot-south robot distance-to-travel)
  (cond
    [(and (<= (robot-ycoordinate robot) 0)
          (and (> (robot-xcoordinate robot) 15) (< (robot-xcoordinate robot) 185)) )
          (possible-moves robot distance-to-travel) ] ;inside the canvas
    
    [(or (< (robot-xcoordinate robot) 15) (> (robot-xcoordinate robot) 185))
          (make-robot (robot-xcoordinate robot) (+ (robot-ycoordinate robot) distance-to-travel) "SOUTH" )]; outside the canvas walls
    
    [(>= (robot-ycoordinate robot) 400)
          (make-robot (robot-xcoordinate robot) (+ (robot-ycoordinate robot) distance-to-travel) "SOUTH")]
    
    [(and (>= (robot-xcoordinate robot) 0) (< (robot-xcoordinate robot) 200)
          (<= (robot-ycoordinate robot) 400)
          (>= (robot-ycoordinate robot) 0)) (possible-moves robot distance-to-travel)]
    )
  )
(if-robot-south(make-robot 20 410 "SOUTH") 30)
;;; if-robot-east : Robot PosInt -> Robot
;;; GIVEN: a robot facing in the EAST direction and a distance to move
;;; RETURNS: the robot now placed at the specified distance
;;; STRATEGY: STRUCTURAL DECOMPOSITION
(define (if-robot-east robot distance-to-travel)
  (cond
    [(and (<= (robot-xcoordinate robot) 0)
     (and (>= (robot-ycoordinate robot) 15) (<= (robot-ycoordinate robot) 385)) ) 
     (possible-moves robot distance-to-travel) ] ;inside the canvas
     
    [(or (< (robot-ycoordinate robot) 15) (> (robot-ycoordinate robot) 385))
          (make-robot (+ (robot-xcoordinate robot) distance-to-travel) (robot-ycoordinate robot) "EAST" )]; outside the canvas walls
    
    [(>= (robot-xcoordinate robot) 185)
          (make-robot (+ (robot-xcoordinate robot) distance-to-travel) (robot-ycoordinate robot) "EAST")]
    
    [(and (>= (robot-xcoordinate robot) 0) (<= (robot-xcoordinate robot) 200)
          (<= (robot-ycoordinate robot) 400)
          (>= (robot-ycoordinate robot) 0)) (possible-moves robot distance-to-travel)]
     )
  )
;;; if-robot-west : Robot PosInt -> Robot
;;; GIVEN: a robot facing in the WEST direction and a distance to move
;;; RETURNS: the robot now placed at the specified distance
;;; STRATEGY: STRUCTURAL DECOMPOSITION
(define (if-robot-west robot distance-to-travel)
  (cond
     [(and (>= (robot-xcoordinate robot) 200) 
          (and (>= (robot-ycoordinate robot) 15) (<= (robot-ycoordinate robot) 385)) )
          (possible-moves robot distance-to-travel) ] ;inside the canvas
    
    [(or (< (robot-ycoordinate robot) 15) (> (robot-ycoordinate robot) 385))
          (make-robot (- (robot-xcoordinate robot) distance-to-travel) (robot-ycoordinate robot) "WEST" )]; outside the canvas walls
    
    [(<= (robot-xcoordinate robot) 14)
          (make-robot (- (robot-xcoordinate robot) distance-to-travel) (robot-ycoordinate robot) "WEST")]
    
    [(and (>= (robot-xcoordinate robot) 0) (<= (robot-xcoordinate robot) 200) (<= (robot-ycoordinate robot) 400) 
          (>= (robot-ycoordinate robot) 0)) (possible-moves robot distance-to-travel)]
    
    )
  )

(if-robot-east (make-robot 190 47 "EAST") 100)

;;  TESTS

(define-test-suite robot-motion-tests
; robot-right 
(check-equal? (robot-right (make-robot 20 30 "NORTH")) (make-robot 20 30 "EAST"))
(check-equal? (robot-right (make-robot 20 30 "EAST"))  (make-robot 20 30 "SOUTH"))
(check-equal? (robot-right (make-robot 20 30 "SOUTH")) (make-robot 20 30 "WEST"))
(check-equal? (robot-right (make-robot 20 30 "WEST"))  (make-robot 20 30 "NORTH"))
  
 ;robot left
(check-equal? (robot-left (make-robot 20 30 "NORTH"))  (make-robot 20 30 "WEST"))
(check-equal? (robot-left (make-robot 20 30 "EAST"))  (make-robot 20 30 "NORTH"))
(check-equal? (robot-left (make-robot 20 30 "SOUTH"))  (make-robot 20 30 "EAST"))
(check-equal? (robot-left (make-robot 20 30 "WEST"))  (make-robot 20 30 "SOUTH"))
  
(check-equal? ( initial-robot -16 -17) (make-robot -16 -17 "NORTH"))
(check-equal? ( initial-robot 416 20) (make-robot 416 20 "NORTH"))
(check-equal? ( initial-robot 0 20) (make-robot 0 20 "NORTH"))
  
(check-equal? (possible-moves (make-robot 50 30 "WEST") 10 ) (make-robot 20 30 "WEST") )
(check-equal? ( robot-west? (make-robot 20 30 "EAST")) false)
  
(check-equal? (robot-forward (make-robot 150 410 "NORTH") 500) (make-robot 150 15 "NORTH"))
(check-equal? (robot-forward (make-robot -15 300 "NORTH") 500) (make-robot -15 -200 "NORTH"))
(check-equal? (robot-forward (make-robot 300 300 "NORTH") 500) (make-robot 300 -200 "NORTH"))
(check-equal? (robot-forward (make-robot 250 410 "NORTH") 500) (make-robot 250 -90 "NORTH"))
(check-equal? (robot-forward (make-robot 100 200 "NORTH") 500) (make-robot 100 15 "NORTH"))
(check-equal? (robot-forward (make-robot 150 -100 "NORTH") 500) (make-robot 150 -600 "NORTH"))

(check-equal? (robot-forward (make-robot 150 -10 "SOUTH") 500) (make-robot 150 385 "SOUTH"))
(check-equal? (robot-forward (make-robot -15 160 "SOUTH") 500) (make-robot -15 660 "SOUTH"))
(check-equal? (robot-forward (make-robot 190 -100 "SOUTH") 500) (make-robot 190 400 "SOUTH"))
(check-equal? (robot-forward (make-robot 100 200 "SOUTH") 500) (make-robot 100 385 "SOUTH"))
(check-equal? (robot-forward (make-robot 186 450 "SOUTH") 500) (make-robot 186 950 "SOUTH"))
(check-equal? (robot-forward (make-robot 300 100 "SOUTH") 500) (make-robot 300 600 "SOUTH"))

(check-equal? (robot-forward (make-robot 250 300 "WEST") 500) (make-robot 15 300 "WEST"))
(check-equal? (robot-forward (make-robot -15 300 "WEST") 500) (make-robot -515 300 "WEST"))
(check-equal? (robot-forward (make-robot 100 300 "WEST") 500) (make-robot 15 300 "WEST"))
(check-equal? (robot-forward (make-robot 140 -100 "WEST") 500) (make-robot -360 -100 "WEST"))
(check-equal? (robot-forward (make-robot -100 -100 "WEST") 500) (make-robot -600 -100 "WEST"))
(check-equal? (robot-forward (make-robot 140 450 "WEST") 500) (make-robot -360 450 "WEST"))
(check-equal? (robot-forward (make-robot 300 100 "WEST") 500) (make-robot 15 100 "WEST"))
(check-equal? (robot-forward (make-robot 140 200 "WEST") 500) (make-robot 15 200 "WEST"))
(check-equal? (robot-forward (make-robot 210 400 "WEST") 500) (make-robot -290 400 "WEST"))
(check-equal? (robot-forward (make-robot 210 -10 "WEST") 500) (make-robot -290 -10 "WEST"))

(check-equal? (robot-forward (make-robot 250 300 "EAST") 500) (make-robot 750 300 "EAST"))
(check-equal? (robot-forward (make-robot -15 300 "EAST") 500) (make-robot 185 300 "EAST"))
(check-equal? (robot-forward (make-robot 100 300 "EAST") 500) (make-robot 185 300 "EAST"))
(check-equal? (robot-forward (make-robot 140 -100 "EAST") 500) (make-robot 640 -100 "EAST"))
(check-equal? (robot-forward (make-robot -100 -100 "EAST") 500) (make-robot 400 -100 "EAST"))
(check-equal? (robot-forward (make-robot 140 450 "EAST") 500) (make-robot 640 450 "EAST"))
(check-equal? (robot-forward (make-robot -10 450 "EAST") 500) (make-robot 490 450 "EAST"))
(check-equal? (robot-forward (make-robot 300 100 "EAST") 500) (make-robot 800 100 "EAST"))
(check-equal? (robot-forward (make-robot 140 200 "EAST") 500) (make-robot 185 200 "EAST"))
(check-equal? (robot-forward (make-robot 210 400 "EAST") 500) (make-robot 710 400 "EAST"))
(check-equal? (robot-forward (make-robot 210 -10 "EAST") 500) (make-robot 710 -10 "EAST"))

(check-equal? (possible-moves (make-robot 20 30 "NORTH") 100 ) (make-robot 20 15 "NORTH") )
(check-equal? (possible-moves (make-robot 20 100 "NORTH") 50 ) (make-robot 20 50 "NORTH") )
(check-equal? (possible-moves (make-robot 20 20 "SOUTH") 100 ) (make-robot 20 120 "SOUTH") )
(check-equal? (possible-moves (make-robot 20 100 "SOUTH") 300 ) (make-robot 20 385 "SOUTH") )
(check-equal? (possible-moves (make-robot 20 100 "EAST") 100 ) (make-robot 120 100 "EAST") )
(check-equal? (possible-moves (make-robot 20 100 "EAST") 300 ) (make-robot 185 100 "EAST") )
(check-equal? (possible-moves (make-robot 20 100 "WEST") 100 ) (make-robot 15 100 "WEST") )
(check-equal? (possible-moves (make-robot 19 100 "WEST") 4 ) (make-robot 15 100 "WEST") )
  
(check-equal? (if-robot-south(make-robot 20 410 "SOUTH") 30) (make-robot 20 440 "SOUTH"))
  
)
  
  (run-tests robot-motion-tests)