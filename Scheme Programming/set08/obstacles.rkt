;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname obstacles) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

;===============================================================================
;; PROBLEM SET DESCRIPTION

; In obstacle? function,a list of positions is given and you check if it 
; qualifies as an obstacle or not.A set of positions is an obstacle iff 
; it has the following properties:
; 1.The set is non-empty
; 2.Every position in the set is occupied
; 3.Any two positions in the set are linked by a chain of adjacent blocks 
;   in the set.
; 4.Every position that is adjacent to the set is either in the set or is 
; vacant. To check for adjacency for a given position ,we first check if 
; they've same x or y coordinate, if so, you add +1 to the other 
; coordinate. If both of those differ by 1 , that means the given pair of 
; coordinates is adjacent to each other.


; In board-to-obstacles, we've been given a set of occupied positions and 
; we've to find the set of obstacles on that board. 

; ALGORITHM:
; 1. Call a helper function called board-to-obstacles wherein you initialize
; a context argument to zero and pass an empty PositionSet which would store
; the final state of PositionSet to be returned.
; 2. In the helper function, ctxt is the context argument on which we're
; accumulating values of PositionSet on every iteration.
; 3. We're using General recursion here and the program terminates when 
; list of Position is empty.

(define ONE 1)
;===============================================================================
(provide obstacle?)
(provide board-to-obstacles)
(provide position-set-equal?)
;===============================================================================
;; A Position is a (list PosInt PosInt)
;; position-fn: Position -> ??
;;(define (position-fn: p)
;;  (... (first p))
;;  (... (second p)))
;===============================================================================
;; A PositionSet is a ListOf<Position> WITH NO DUPLICATES
;; -- empty                         Interp: PositionSet maybe empty 
;; -- (cons Position PositionSet)   Interp: PositionSet maybe a ListOf<Position>
;===============================================================================
;; positionset-fn: ListOf<Position> -> ??
;;(define (positionset-fn poset)
;;  (cond
;;    [(empty? poset) ...]
;;    [else (... position-fn(first poset)
;;               (positionset-fn (rest poset)))]))

;; A PositionSetSet is a ListOf<PositionSet> WITH NO DUPLICATES
;; -- empty                             Interp:PositionSetSet maybe empty 
;; -- (cons PositionSet PositionSetSet) Interp:PositionSetSet maybe a 
;;                                             ListOf<PositionSet>

;; positionsetset-fn: ListOf<PositionSet> -> ??
;; (define (positionsetset-fn posetset)
;;  (cond
;;    [(empty? posetset) ...]
;;    [else (... positionset-fn(first posetset)
;;               (positionsetset-fn (rest posetset)))]))
;===============================================================================
;; A Block is a Position

;; board-fn: ListOf<Block> -> ??
;;(define (board-fn lob)
;;  (cond
;;    [(empty? lob) ...]
;;    [else (... position-fn(first lob)
;;               (board-fn (rest lob)))]))



;==============End of Data Definitions=========================================

;; Examples for Testing:

(define pset1 (list 
               (list 1 2)
               (list 1 3)
               (list 2 3)
               (list 3 2)
               (list 3 4)
               (list 4 1)
               (list 4 4)))

(define pset10 (list 
                (list 1 2)
                (list 1 3)
                (list 2 3)
                (list 3 2)
                (list 3 4)
                (list 4 1)
                (list 4 4)))


(define pset2 (list 
               (list 1 2)
               (list 1 3)
               (list 2 3)))

(define pset3 (list
               (list 3 2)))

(define pset4 (list 
               (list 2 4)
               (list 3 4)
               (list 4 4)))
(define pset5 (list 
               (list 1 1)
               (list 3 4)
               (list 4 4)))

;==============================================================================
;CONSTANTS

(define LOCATE-ADJOINING-ELEMENTS (list
                                   (list 2 2)
                                   (list 0 2)
                                   (list 1 3)
                                   (list 1 1)))

(define CTXT (list (first pset1)))

(define CORRECT-PSETSET
(list
 (list (list 4 1))
 (list (list 4 4) (list (list 3 4)))
 (list (list 3 2))
 (list (list 2 3) (list (list 1 3) (list (list 1 2))))))

;====================================Funct implementation begins================
; FUNCTION1

;; position-set-equal? : PositionSet PositionSet -> Boolean
;; GIVEN: two list of positions respectively
;; RETURNS: true iff they denote the same set of positions 
;; EXAMPLES: (position-set-equal? pset1 pset10) = true
;; STRATEGY: Function Composition

(define (position-set-equal? set1 set2)
  (and
   (pos-subset? set1 set2)
   (pos-subset? set2 set1)))


;; my-member? : Position PositionSet -> Boolean
;; GIVEN: a position and a list of positions 
;; RETURNS: a boolean value depicting if a given position is
;; present in the list of position
;; EXAMPLES: (my-member? (list 1 2) pset1) = true
;; strategy: HOFC

(define (my-member? x set1)
  (ormap
   ; Position -> Boolean
   ; GIVEN: a Position from PositionSet
   ; RETURNS: a boolean value depicting if
   ; that position is present in that PositionSet.
   (lambda (z) (equal? x z))
   set1))

;; pos-subset? : PositionSet PositionSet -> Boolean
;; GIVEN: 2 respective list of positions
;; RETURNS: a boolean value depicting if first position is a subset
;; of the second position
;; EXAMPLES:(pos-subset? pset2 pset1) = true
;; strategy: HOFC

(define (pos-subset? set1 set2)
  (andmap
   ; Position -> Boolean
   ; GIVEN: a Position from PositionSet
   ; RETURNS: a boolean value depicting if 
   ; that position is a subset of that PositionSet.
   (lambda (x) (my-member? x set2))
   set1))

; Tests
(define-test-suite position-set-equal?-tests
  (check-equal? (position-set-equal? pset1 pset10)
                true
                "returns true if both positions are equal"))

(run-tests position-set-equal?-tests)

;==============Funct 2=========================================================

;; obstacle? : PositionSet -> Boolean
;; GIVEN: a list of positions
;; RETURNS: a boolean value depicting if the given list of positions
;; qualify as an obstacle or not.
;; EXAMPLES: (obstacle? pset1) = false
;; STRATEGY: HOFC

(define (obstacle? pset)  
  (cond
    [(empty? pset) false]
    [else (if (= ONE (length pset))   
              true      
              (andmap 
               ; Position -> Boolean
               ; GIVEN: a position
               ; RETURNS: a boolean value depicting if that position
               ; is present in the given PositionSet.
               (lambda(p) (check-if-adjacent-to-any p pset))       
               pset))]))

;; check-if-adjacent-to-any: Position PositionSet -> Boolean 
;; GIVEN: a position and a list of positions
;; RETURNS: a boolean value depicting if a given position is
;; adjacent to any position in the list of positions.
;; EXAMPLES: 
;; (check-if-adjacent-to-any (list 1 2) pset1) = true
;; STRATEGY: HOFC

(define (check-if-adjacent-to-any pos pset)  
  (ormap 
   ;Position -> Boolean
   ;GIVEN: a Position from a PositionSet
   ;RETURNS: a boolean value depicting if any of the Positions
   ;are in the given PositionSet.
   (lambda(position) (position-adjacent pos position))   
   pset))

;; position-adjacent: Position Position -> Boolean
;; GIVEN: 2 positions
;; RETURNS: a boolean value depicting if the two given
;; positions are adjacent to each other.
;; EXAMPLES: (position-adjacent (list 1 2) (list 1 3)) = true
;; STRATEGY: Structural Decomposition on pos1,pos2 : Position
(define (position-adjacent pos1 pos2)  
  (or (and (= (first pos1) (first pos2))           
           (or (= (+ ONE (second pos1)) (second pos2))               
               (= (second pos1) (+ ONE (second pos2)))))      
      (and (= (second pos1) (second pos2))           
           (or (= (+ ONE (first pos1)) (first pos2))               
               (= (first pos1) (+ ONE (first pos2)))))))

;Tests
(define-test-suite obstacle?-tests
  (check-equal? (obstacle? pset1)
                false
                "returns false if a given list of position doesn't qualify
                 as an obstacle")
  (check-equal? (obstacle? empty)
                false
                "returns empty if a given list of position is empty")
  (check-equal? (obstacle? pset3)
                true
                "returns true if given length of list of position is 1"))

(run-tests obstacle?-tests)

;===============================================================================
; FUNCTION3

;board-to-obstacles : PositionSet -> PositionSetSet
;GIVEN: the set of occupied positions on a chessboard
;RETURNS: the set of obstacles on that chessboard.
;EXAMPLES:
;(board-to-obstacles pset1) =
;(list
; (list (list 4 1))
; (list (list 4 4) (list (list 3 4)))
; (list (list 3 2))
; (list (list 2 3) (list (list 1 3) (list (list 1 2)))))
;STRATEGY: Function Composition

(define (board-to-obstacles lob)
  (board-to-obstacles-helper lob empty empty))

;; board-to-obstacles-helper: PositionSet PositionSet PositionSet -> 
;;                            PositionSetSet  
;; GIVEN: a list of blocks , a list of position which serves as a context 
;; argument and another list of blocks both of which are initialized to zero.
;; RETURNS: the set of obstacles on the chessboard.
;; WHERE: lob is the nth sublist of a higher list lst0
;; and ctxt represents 1st element of sublist lob.
;; EXAMPLES: 
;;(board-to-obstacles-helper pset1 empty empty) =
;;(list
;; (list (list 4 1))
;; (list (list 4 4) (list (list 3 4)))
;; (list (list 3 2))
;; (list (list 2 3) (list (list 1 3) (list (list 1 2)))))
;; STRATEGY: General recursion

;; TERMINATION ARGUMENT : Halting measure is the number of Position that are 
;;                        not in PositionSet (or ctxt). Length
;;                        of PositionSet (or ctxt) is increasing but
;;                        number of Position that is not in PositionSet 
;;                        (or ctxt) would keep on decreasing on every iteration.

(define (board-to-obstacles-helper lob ctxt finallist)
  (cond
    [(empty? lob) finallist]
    [(empty? ctxt)        
     (board-to-obstacles-helper lob 
                                (list (first lob)) 
                                (append (list (list (first lob)))
                                        finallist))]
    [else
     (local
       ((define locate-adjoining-elements (find-adjoining-elements 
                                           (first ctxt)))
        (define get-from-list-if-present (check-in-list
                                          locate-adjoining-elements 
                                          lob))
        (define generate-final-list
          (append get-from-list-if-present 
                  (rest ctxt))))       
       (board-to-obstacles-helper (remove (first ctxt) lob)
                                  generate-final-list 
                                  (updatelist 
                                   ctxt 
                                   finallist 
                                   generate-final-list)))]))


;; updatelist: PositionSet PositionSet PositionSet -> PositionSetSet   
;; GIVEN: previous list of positions , list of blocks on board and
;; the newly obtained list of positions.
;; RETURNS: the updated list of PositionSet with correct sets of obstacles
;; formed on board.
;; EXAMPLES: 
;;(updatelist (list (list 1 3)) (list (list (list 1 2))) (list (list 1 3))) =
;;(list
;; (list (list 1 3) (list (list 1 2))))
;; STRATEGY: Structural Decomposition on nexctxt,finallist : PositionSet 

(define (updatelist oldctxt finallist newctxt)
  (if (empty? newctxt)
      finallist
      (cons (append (list (first newctxt)
                          (first finallist)))
            (rest finallist))))

;; find-adjoining-elements: Position -> PositionSet
;; GIVEN: a position
;; RETURNS: list of adjacent positions to that position
;; EXAMPLES: 
;;(find-adjoining-elements (list 1 2)) = (list
;;                                        (list 2 2)
;;                                        (list 0 2)
;;                                        (list 1 3)
;;                                        (list 1 1))
;; STRATEGY: Domain Knowledge

(define (find-adjoining-elements pos)
  (list
   (list (+ (first pos) ONE) (second pos))
   (list (- (first pos) ONE) (second pos))
   (list (first pos)( + (second pos) ONE))
   (list (first pos)(- (second pos) ONE))))


;; check-in-list: PositionSet PositionSet -> PositionSet
;; GIVEN: a list of adjacent positions for a particular position
;; and a list of blocks
;; RETURNS: the list of positions which are present in the list of 
;; blocks 
;; EXAMPLES: (check-in-list LOCATE-ADJOINING-ELEMENTS pset1) = (list (list 1 3))
;; STRATEGY: HOFC

(define (check-in-list locate-adjoining-elements lob)
  (filter
   ; Position -> Position
   ; GIVEN: a position
   ; RETURNS: a position if it's a member of given PositionSet   
   (lambda (e) (my-member? e lob))
   locate-adjoining-elements))

;Tests

(define-test-suite board-to-obstacles-tests
  (check-equal? (board-to-obstacles pset1) 
                CORRECT-PSETSET))

(run-tests board-to-obstacles-tests)
                















