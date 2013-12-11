;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pitchers) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;ALGORITHM USED : 
;;1)Generate the pitchers from the given list
;;2)Generate the list of all possible moves
;;7)Check with all the trivial cases
;;9)For non trivial case, take one valid move at a time from the list
;;  of moves and check whether that move has been traversed or not 
;;3)Traverse the moves one at a time starting from the left side using dfs
;;4)Check each node
;;5)See if it appearing in the past-state-list-of-pitchers
;;6)If it is appearing then check if goal state matches, returns the list of 
;;  moves traversed else backtrack and jump to the next valid move.
;;7)If the node does not appear in the past-state-list add the move to the 
;;  list-of-solution-moves and add the node to the past-state-list and then 
;;  move to the next node.
;;10)For moves, calculate the pitcher state
;;   after the given move and then check if the goal has been reached

(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")
;; ============================================================================

(provide make-move)
(provide move-src)
(provide move-tgt)
(provide solve)
(provide pitchers-after-moves)
(provide pitchers-to-list)
(provide list-to-pitchers)
;; ============================================================================
;;                               CONSTANTS
;; ============================================================================

(define INITIAL-INDEX-VALUE 1)
(define NEXT-INDEX-VALUE 2)
(define INITIAL-CAPACITY 0)
(define PITCHER-CONTENTS-EMPTY 0)
(define INDEX 0)
;; ============================================================================
;;                               DATA DEFINITIONS
;; ============================================================================
;; Any -> any type of data input e.g. Number, Boolean, etc.

;; PosInt is a Integer greater than 0.

;; Nat denotes the set of natural numbers (also called the non-negative 
;; integers) 0, 1, 2, etc.
;; ============================================================================

(define-struct pitcher (id contents capacity))
;; A Pitcher is a (make-pitcher PosInt Nat PosInt)
;; Interp.: A Pitcher represents a pitcher holding liquid,
;; WHERE:
;; id represents the specific pitcher whose value is more than 0,
;; contents represents the quantity of liquid in pitcher currently,
;; capacity represents the capacity of pitcher.
;; Assumption: contents must be less than or equal to capacity.

;; Template:
;; pitcher-fn : Pitcher -> ??
;; (define (pitcher-fn p)
;;  (...
;;      (pitcher-id p)
;;      (pitcher-contents p) 
;;      (pitcher-capacity p)))
;; ============================================================================

(define-struct move (src tgt))
;; A Move is a (make-move PosInt PosInt)
;; WHERE: src and tgt are different
;; INTERP: (make-move i j) means pour from pitcher i to pitcher j, 
;; Now there might be conditions when capacities of pitchers do not match,
;; then pour quantity that can fit/be contained by next pitcher.

;; e.g. If move denotes a pour from pitcher 1 to pitcher 2 but capacity of 
;; pitcher 1 is 5 and pitcher 2 is 8 then after move pitcher 2 will contain 
;; only 5 quantity.
;; In reverse scenario, where pitcher 1 has 5 quantity and pitcher 2 has
;; capacity 3 i.e. any less capacity then only that amount as of destination
;; pitcher's capacity will be poured.

;; Template:
;; move-fn : Move -> ??
;(define (move-fn mv)
;  (... (move-src mv)
;       (move-tgt mv)))

;; ============================================================================
;; A ListOf<Move> is one of 
;; -- empty                        (Interp: list is empty)
;; -- (cons Move ListOf<Move>)     (Interp: list contains one or more moves)
;;
;; Template:
;; list-of-move-fn : ListOf<Move> -> ??
;(define (list-of-move-fn lom)
;  (cond
;    [(empty? lom) ...]
;    [else (... (move-fn (first lom))
;               (list-of-move-fn (rest lom)))]))

;; ============================================================================
;; Important : below data definition is a generalized one, for any data of type
;; X.
;; 
;; A Maybe<X> is one of:
;; -- false              (Interp: boolean false value)
;; -- X                  (Interp: list of one or more Xs)

;; Template:
;; maybex-fn : Maybe<X> -> ??
;(define (maybex-fn mbx)
;  (cond
;    [(false? mbx)  ...]
;    [else ...]))
;; ============================================================================

;; A Maybe<ListOf<Move>> is one of:
;; -- false              (Interp: boolean false value)
;; -- ListOf<Move>       (Interp: list of moves)

;; Template:
;; maybelistofmove-fn : Maybe<ListOf<Move>> -> ??
;(define (maybelistofmove-fn mblom)
;  (cond
;    [(false? mblom)  ...]
;    [else ...]))

;; ============================================================================
;; A ListOf<PosInt> is one of
;; -- empty                            (Interp: list is empty)
;; -- (cons PosInt ListOf<PosInt>)     (Interp: list contains one or more 
;;                                      positive integers)
;; 
;; Template:
;; list-of-posint-fn : ListOf<PosInt> -> ??
;(define (list-of-posint-fn lopi)
;  (cond
;    [(empty? lopi) ...]
;    [else (... (first lopi)
;               (list-of-posint-fn (rest lopi)))]))
;; ============================================================================

;; A ListOfNatNumber is one of
;; -- empty                       (Interp: list is empty)
;; -- (cons ListOfNumber)         (Interp: list of numbers greater than 0)

;; Template:
;; list-of-number-fn : ListOfNatNumber -> ??
;(define (list-of-nat-number-fn lonn)
;  (cond
;    [(empty? lonn) ...]
;    [else (... (first lonn)
;               (list-of-nat-number-fn (rest lonn)))]))

;; ============================================================================
;; A NEListOf<PosInt> is a non-empty list of PosInt i.e. positive integers
;; meaning it will atleast contain one positive integer.
;; ============================================================================

;; A NEListOf<PosInt> is (cons PosInt ListOf<PosInt>)
;; (interp: A non-empty list of positive integers contains at least one,
;; PosInt)

;; Template 1:
;; nelist-of-posint-fn : NEListOf<PosInt> -> ??
;(define (nelist-of-posint-fn nelopi)
;  (... (first nelopi)
;       (nelist-of-posint-fn (rest nelopi))))

;; ============================================================================
;; Definition #2:

;; A NEListOf<PosInt> is one of
;; -- (cons PosInt empty)             (interp: A list with a only one PosInt) 
;; -- (cons PosInt NEListOf<PosInt>)  (interp: represents a sequence whose
;;                                     first element is PosInt and whose other 
;;                                     elements are represented by 
;;                                     NEListOf<PosInt>)


;; Template 2:
;; nelist-of-posint-fn : NEListOf<PosInt> -> ??
;(define (nelist-of-posint-fn nelopi)
;  (cond
;    [(empty? (rest nelopi)) (...(first nelopi))]
;    [else (... (first nelopi)
;               (nelist-of-posint-fn (rest nelopi)))]))


;; ============================================================================
;; A list of Pitcher i.e. ListOf<Pitcher> and is one of 
;; -- empty                          (interpretation: pitchers is empty)
;; -- (cons Pitcher ListOf<Pitcher>) (interpretation: list of pitcher i.e. 
;;                                    pitchers has one or more pitcher)

;; Template:
;; list-of-pitcher-fn : ListOf<Pitcher> -> ??
;(define (list-of-pitcher-fn lop)
;  (cond
;    [(empty? lop) ...]
;    [else (... (pitcher-fn (first lop))
;               (list-of-pitcher-fn (rest lop)))]))

;; ============================================================================
;; Pitchers is a NEListOf<Pitcher> is a non-empty list of Pitcher
;; meaning it will contain atleast one pitcher.
;; ============================================================================
;; Definition #1:
;; A Pitchers is (cons Pitcher ListOf<Pitcher>)
;; (interp: A non-empty list of pitcher contains at least one pitcher)

;; Template 1:
;; pitchers-fn : Pitchers -> ??
;(define (pitchers-fn nelop)
;  (... (pitcher-fn (first nelop))
;       (pitchers-fn (rest nelop))))

;; ============================================================================
;; Definition #2:

;; A Pitchers is one of
;; -- (cons Pitcher empty)             (interp: A list with a only one Pitcher) 
;; -- (cons Pitcher NEListOf<Pitcher>) (interp: represents a sequence whose
;;                                      first element is Pitcher and whose other 
;;                                      elements are represented by 
;;                                      NEListOf<Pitcher>)

;; Template 2:
;; pitchers-fn : Pitchers -> ??
;(define (pitchers-fn nelop)
;  (cond
;    [(empty? (rest nelop)) (...(pitcher-fn (first nelop)))]
;    [else (... (pitcher-fn (first nelop))
;               (pitchers-fn (rest nelop)))]))

;; ============================================================================
;; ListOf<Pitchers> is a list of Pitchers i.e. its a list of list of pitcher, 
;; it is used to indicate the states of pitchers till now 
;; and is one of 
;; -- empty                            (interpretation: list is empty)
;; -- (cons Pitchers ListOf<Pitchers>) (interpretation: list of pitchers i.e. 
;;                                      ListOf<Pitchers> has one or more 
;;                                      pitchers i.e. one or more pitchers
;;                                      states)

;; Template:
;; list-of-pitchers-fn : ListOf<Pitchers> -> ??
;(define (list-of-pitchers-fn lops)
;  (cond
;    [(empty? lops) ...]
;    [else (... (pitchers-fn (first lops))
;               (list-of-pitchers-fn (rest lops)))]))

;; ============================================================================
;; A NEListOf<Pitchers> is a non-empty list of Pitchers i.e.non-empty list of
;; list of pitcher meaning it will contain atleast one Pitchers i.e. one list
;; of pitcher
;; ============================================================================
;; Definition #1:
;; A NEListOf<Pitchers> is (cons Pitchers ListOf<Pitchers>)
;; (interp: A non-empty list of list of pitcher (i.e. ListOf<Pitchers>) 
;; contains at least one Pitchers i.e. one state of pitchers at any time)

;; Template 1:
;; nelist-of-pitchers-fn : NEListOf<Pitchers> -> ??
;(define (nelist-of-pitchers-fn nelops)
;  (... (pitchers-fn (first nelops))
;       (nelist-of-pitchers-fn (rest nelops))))

;; ============================================================================
;; Definition #2:

;; A NEListOf<Pitchers> is one of
;; -- (cons Pitchers empty)             (interp: A list with only one Pitchers) 
;; -- (cons Pitchers NEListOf<Pitchers>)(interp: represents a sequence whose
;;                                      first element is Pitchers and whose
;;                                      other elements are represented by 
;;                                      NEListOf<Pitchers>)

;; Template 2:
;; nelist-of-pitchers-fn : NEListOf<Pitchers> -> ??
;(define (nelist-of-pitchers-fn nelops)
;  (cond
;    [(empty? (rest nelops)) (...(pitchers-fn (first nelops)))]
;    [else (... (pitchers-fn (first nelops))
;               (nelist-of-pitchers-fn (rest nelops)))]))

;; ============================================================================
;; ListRep is an S-expression where
;; ListRep     (list (list contents1 capacity1)
;;                   (list contents2 capacity2)
;;                   ...
;;                   (list contents_n capacity_n))
;; WHERE:  n >=1, and for each i, 0 <= contents_i <= capacity_i
;; INTERPRETATION: the list of pitchers, from 1 to n, with their contents
;; and capacity
;; EXAMPLE: ((5 10) (7 8)) is a list of two pitchers.  The first
;; currently holds 5 and has capacity 10; the second currently holds 7 and has
;; capacity 8.

;; Template: 
;; listrep-fn : ListRep -> ??
;(define (listrep-fn lr)
;  (cond
;    [(empty? lr) ...]
;    [else (... (first lr)
;               (listrep-fn (rest lr)))]))

;; ============================================================================

;; map : (X -> Y) ListOf<X> -> ListOf<Y>
;; construct a list by applying f to each item of the given list 
;; that is, (map f (list x_1 ... x_n)) 
;;            = (list (f x_1) ... (f x_n)) 

;; foldl : (X Y -> Y) Y ListOf<X> -> Y 
;; (foldl f base (list x_1 ... x_n)) 
;;   = (f x_n ... (f x_1 base)) 

;; andmap : (X -> Boolean) ListOf<X> -> Boolean 
;; determine whether p holds for every item on alox 
;; that is, (andmap p (list x_1 ... x_n)) 
;;           = (and (p x_1) ... (p x_n)) 

;; =============================================================================
;;                               example-for-testing
;; =============================================================================
(define list-to-pitcher-sample 
  (list (list 10 20) (list 0 5)))
(define list-to-pitchers-result 
  (list(make-pitcher 1 10 20)(make-pitcher 2 0 5)))
(define pitchers-to-list-sample 
  (list (make-pitcher 0 8 8 )
        (make-pitcher 0 0 5 )))
(define pitchers-to-list-result
  (list (list 8 8) (list 0 5)))
(define sample-moves
  (list
 (make-move 1 2)
 (make-move 1 3)
 (make-move 2 1)
 (make-move 3 2)
 (make-move 1 3)
 (make-move 3 2)
 (make-move 1 3)
 (make-move 3 2)
 (make-move 2 1)
 (make-move 3 2)
 (make-move 1 3)))
(define pitcher-after-moves-result 
  (list
 (make-pitcher 1 5 10)
 (make-pitcher 2 2 7)
 (make-pitcher 3 3 3)))

(define solve-results 
  (list
 (make-move 1 2)
 (make-move 1 3)
 (make-move 2 1)
 (make-move 3 2)
 (make-move 1 3)
 (make-move 3 2)
 (make-move 1 3)
 (make-move 3 2)
 (make-move 2 1)
 (make-move 3 2)
 (make-move 1 3)))
(define list-sample 
  (list 10 7 3))
(define list-sample-when-goal-more-than-capacity
  (list 3 5 3))
(define FIVE 5)
(define FOUR 4)
(define THREE 3)
(define list-for-goal-not-in-list
  (list 8))
(define list-for-dfs 
  (list (make-pitcher 1 8 8) 
        (make-pitcher 1 0 5) 
        (make-pitcher 1 0 3)))
(define list-traverse
  (list 3 7 0))
(define list-to-check-capacity
   (list (make-pitcher 1 0 10)
         (make-pitcher 1 0 8)))
(define list-to-solve
  (list 8 6 2 2))
(define TEN 10)
(define list-for-dfs2 
  (list (make-pitcher 1 4 5) 
        (make-pitcher 2 6 8)))

;; =============================================================================
;;                               list-to-pitchers
;; =============================================================================
;; list-to-pitchers-helper : ListRep PosInt -> ListOf<Pitcher>
;; GIVEN: a list representation i.e. ListRep lr and positive integer i.e. index
;; WHERE: lr is a sublist of some larger list lr0 and index is number of
;; elements processed from lr0 till now during conversion of ListRep to 
;; Pitchers
;; RETURNS: a Pitchers which is a ListOf<Pitcher> i.e. list of pitchers
;; EXAMPLES:(list-to-pitchers-helper (list (list 10 20) (list 0 5)) 0) 
;; = (list (make-pitcher 1 10 20) (make-pitcher 2 0 5))
;; STRATEGY: Structural Decomposition on lp : [ListRep]
(define (list-to-pitchers-helper lr index)
  (cond
    [(empty? lr) empty]
    [else (cons (make-pitcher (+ index INITIAL-INDEX-VALUE) (first (first lr)) 
                              (second (first lr)))
                (list-to-pitchers-helper (rest lr)
                                         (+ index INITIAL-INDEX-VALUE)))])) 
;; =============================================================================
;; list-to-pitchers : ListRep -> Pitchers
;; GIVEN: a list representation i.e. ListRep
;; RETURNS: a Pitchers which is a ListOf<Pitcher> i.e. list of pitchers
;; EXAMPLES:(list-to-pitchers (list (list 10 20) (list 0 5))) 
;; = (list(make-pitcher 1 10 20)(make-pitcher 2 0 5))
;; STRATEGY: Function Composition
(define (list-to-pitchers lr)
  (list-to-pitchers-helper lr INDEX))

;; TESTS:
(define-test-suite list-to-pitchers-tests
  (check-equal? (list-to-pitchers list-to-pitcher-sample) 
                list-to-pitchers-result
                "converts list to pitchers"))
(run-tests list-to-pitchers-tests)
;; =============================================================================
;;                              pitchers-to-list
;; =============================================================================
;; pitchers-to-list : Pitchers -> ListRep
;; GIVEN: a set of pitchers i.e. ListOf<Pitcher> 
;; RETURNS: a ListRep that represents them
;; EXAMPLES:(pitchers-to-list(list (make-pitcher 0 8 8 )(make-pitcher 0 0 5 )))
;; =(list (list 8 8) (list 0 5))
;; STRATEGY: Structural Decomposition on ps : [Pitchers]

(define (pitchers-to-list ps)
  (map
   ;Pitcher -> ListOfNatNumber
   ;GIVEN: a pitcher
   ;RETURNS: list of numbers greater than 0
   (lambda (p)
     (list (pitcher-contents p)
           (pitcher-capacity p)))
   ps))

;; TESTS:
(define-test-suite pitchers-to-list-tests
  (check-equal? (pitchers-to-list pitchers-to-list-sample)
                pitchers-to-list-result
                "converts pitchers to list"))
(run-tests pitchers-to-list-tests)
;; =============================================================================
;;source-pitcher-after-move : Pitcher Pitcher -> Pitcher
;;GIVEN: a source and target pitcher
;;RETURNS: the source pitcher after the move
;;EXAMPLE: (source-pitcher-after-move (make-pitcher 1 6 8) (make-pitcher 1 0 5))
;;= (make-pitcher 1 1 8)
;;STRATEGY: Structural Decomposition on p : Pitcher
(define (source-pitcher-after-move src-pitcher trgt-pitcher)
  (if (> (pitcher-contents src-pitcher) 
          (- (pitcher-capacity trgt-pitcher) (pitcher-contents trgt-pitcher)))
      ;; transfer only available capacity of destination pitcher, to make it
      (make-pitcher (pitcher-id src-pitcher) 
                    (- (pitcher-contents src-pitcher)
                       (- (pitcher-capacity trgt-pitcher) 
                          (pitcher-contents trgt-pitcher)))
                    (pitcher-capacity src-pitcher))
      ;; then transfer everything to destination pitcher,
      ;; making it empty 
      (make-pitcher (pitcher-id src-pitcher) 
                    PITCHER-CONTENTS-EMPTY
                    (pitcher-capacity src-pitcher))))
;; ============================================================================
;;target-pitcher-after-move : Pitcher Pitcher -> Pitcher
;;GIVEN:  source and target pitcher
;;RETURNS: the destination pitcher after the move
;;EXAMPLE: (target-pitcher-after-move (make-pitcher 1 6 8)
;;(make-pitcher 1 0 5))=(make-pitcher 1 5 5)
;;STRATEGY: Structural Decomposition on p : Pitcher
(define (target-pitcher-after-move src-pitcher trgt-pitcher)
  (make-pitcher (pitcher-id trgt-pitcher)
                ;; i.e. now destination pitcher added with source's contents
                (if (> (pitcher-contents src-pitcher) 
                       (- (pitcher-capacity trgt-pitcher)
                          (pitcher-contents trgt-pitcher)))
                    (pitcher-capacity trgt-pitcher)
                    (+ (pitcher-contents src-pitcher)
                       (pitcher-contents trgt-pitcher)))
                (pitcher-capacity trgt-pitcher)))
;; ============================================================================
;; check-if-src-or-tgt : Pitcher Pitcher Pitcher -> Pitcher
;;GIVEN: a pitcher and source and destination pitcher for the move
;;RETURNS: a pitcher after movingfrom source to destination
;;EXAMPLE: (pitcher-after-move (make-pitcher 1 6 8) (make-pitcher 1 0 5)
;;(make-pitcher 2 0 5)) = (make-pitcher 1 0 5)
;;STRATEGY: Structural Decomposition on p : Pitcher 
(define (check-if-src-or-tgt p src-pitcher trgt-pitcher)
  (if (= (pitcher-id src-pitcher) (pitcher-id p))
      ;; if pitcher is source pitcher
      (source-pitcher-after-move src-pitcher trgt-pitcher) 
      ;; else check if it is a destination pitcher
      (if (= (pitcher-id trgt-pitcher) (pitcher-id p))
          ;; destination pitcher after pouring from source pitcher
          (target-pitcher-after-move src-pitcher trgt-pitcher)
          ;;else means it is not a source as well as 
          ;;destination pitcher, so return it as is
          p)))
;; ============================================================================
;; pitchers-after-move-helper : Pitchers Pitcher Pitcher -> Pitchers
;; GIVEN: a set of pitchers i.e. ListOf<Pitcher> and a source pitcher index 
;; and target pitcher index for current move
;; RETURNS: a set of pitchers after given move i.e. from source to destination
;; pitcher of current move
;; EXAMPLES: 
;;(pitchers-after-move-helper (list
;; (make-pitcher 1 3 8)
;; (make-pitcher 2 5 5)
;; (make-pitcher 3 0 3)
;; (make-pitcher 4 0 1)) (make-pitcher 1 3 8)
;; (make-pitcher 2 5 5)) =
;;(list
;; (make-pitcher 1 3 8)
;; (make-pitcher 2 5 5)
;; (make-pitcher 3 0 3)
;; (make-pitcher 4 0 1))

;; STRATEGY: Structural Decomposition on ps : [Pitchers]
;(define (pitchers-after-move-helper ps src-pitcher trgt-pitcher)
;  (cond
;    [(empty? ps) empty]
;    [else (cons (pitcher-after-move (first ps) src-pitcher trgt-pitcher)                 
;                (pitchers-after-move-helper (rest ps) 
;                                            src-pitcher trgt-pitcher))]))
;; STRATEGY: HOFC
(define (pitchers-after-move-helper ps src-pitcher trgt-pitcher)
  (map
   ;Pitcher -> Pitcher
   ;GIVEN: a pitcher
   ;RETURNS: an updated pitcher
   (lambda (p)
     (check-if-src-or-tgt p src-pitcher trgt-pitcher))
   ps))

;; ============================================================================
;; find-src-and-tgt : Pitchers Move -> Pitchers
;; GIVEN: a set of pitchers i.e. ListOf<Pitcher> and a move
;; RETURNS: a set of pitchers after given move
;; EXAMPLES: 
;;(pitchers-after-move (list (make-pitcher 1 8 8) (make-pitcher 2 0 )
;;(make-pitcher 3 0 3)(make-pitcher 4 0 1)) (make-move 1 2))=
;;(list
;; (make-pitcher 1 3 8)
;; (make-pitcher 2 5 5)
;; (make-pitcher 3 0 3)
;; (make-pitcher 4 0 1))                                                                    
;; STRATEGY: Structural Decomposition on m & ps : [Move and Pitchers]

(define (find-src-and-tgt ps m)
  (local
    ((define trgt-pitcher (list-ref ps (- (move-tgt m) INITIAL-INDEX-VALUE)))
     (define src-pitcher  (list-ref ps (- (move-src m) INITIAL-INDEX-VALUE))))
    (pitchers-after-move-helper ps src-pitcher trgt-pitcher)))

;; ============================================================================
;; pitchers-after-moves : Pitchers ListOf<Move> -> Pitchers
;; GIVEN: a set of pitchers i.e. ListOf<Pitcher> and a sequence of moves
;; WHERE: every move refers only to pitchers that are in the set of pitchers.
;; RETURNS: a set of pitchers i.e. ListOf<Pitcher> that should
;; result after executing the given list of moves, in order, on the given
;; set of pitchers.
;; EXAMPLES:(pitchers-after-moves (list (make-pitcher 1 8 8)
;;   (make-pitcher 2 0 5) (make-pitcher 3 0 3) (make-pitcher 4 0 1))
;;   (list (make-move 1 2)  (make-move 4 3) (make-move 2 3)))=
;; (list (make-pitcher 1 3 8) (make-pitcher 2 2 5) (make-pitcher 3 3 3)
;; (make-pitcher 4 0 1))
;; STRATEGY: HOFC

(define (pitchers-after-moves  ps lom)
 (foldl
  ;Pitchers Move -> Pitchers
  ;GIVEN : pitchers and move
  ;RETURNS : Pitchers
  (lambda(x y)
    (find-src-and-tgt y x))
  ps
  lom))
;; =============================================================================
;; make-move : PosInt PosInt -> Move
;; WHERE the two arguments are not equal
;; RETURNS: a move with the given numbers as its source and target,
;; respectively. 
;; NOTE: A default constructor provided by Racket for structure named move 

;; =============================================================================
;; move-src : Move -> PosInt
;; move-tgt : Move -> PosInt
;; RETURNS: the pitcher numbers of the source or target of the move.
;; NOTE: A default getter functions for src and tgt provided by Racket for
;; attributes/members of structure named move

;; =============================================================================
;; get-pitcher-from-capacities : NEListOf<PosInt> -> Pitchers
;; GIVEN: a non empty list of positive integers 
;; RETURNS: a non empty list of pitcher
;; EXAMPLES:
;;(get-pitchers-from-capacities(list 10 7 3)) = 
;;(list
;; (make-pitcher 1 10 10)
;; (make-pitcher 2 0 7)
;; (make-pitcher 3 0 3))
;; STRATEGY: Structural Decomposition on NEListOf<PosInt> 
(define (get-pitchers-from-capacities pitcher-capacities-list)
  (cons (make-pitcher INITIAL-INDEX-VALUE
                      (first pitcher-capacities-list)
                      (first pitcher-capacities-list))
        (get-pitchers-from-capacities-helper 
         (rest pitcher-capacities-list) NEXT-INDEX-VALUE)))

;; =============================================================================
;; get-pitcher-from-capacities-helper: ListOf<PosInt> PosInt -> Pitchers
;; GIVEN: a list of positive integer and a number
;; RETURNS: a non empty list of pitcher
;; WHERE : index is the index of the picher and is incremented in each call and
;;         rermains true for each iteration,,satisfying the function.
;; EXAMPLES:
;;(get-pitchers-from-capacities-helper (list 10 7 3) 2) =
;;(list
;; (make-pitcher 2 0 10)
;; (make-pitcher 3 0 7)
;; (make-pitcher 4 0 3))
;; STRATEGY: Structural Decomposition on ListOf<PosInt>
(define (get-pitchers-from-capacities-helper lopi index)
  (cond 
    [(empty? lopi) empty]
    [else (cons (make-pitcher index INITIAL-CAPACITY (first lopi))
                (get-pitchers-from-capacities-helper 
                 (rest lopi) (+ index INITIAL-INDEX-VALUE)))]))
 
;; =============================================================================
;; generate-backward-moves : PosInt Pitchers -> ListOf<Move>
;; GIVEN: a source index and a list of pitchers
;; RETURNS : a list of backward moves
;; WHERE : src-index is the source index and is decremented at each call,
;;         remains true for each call,satisfying the function.
;; EXAMPLES : (generate-backward-moves 2 (list (make-pitcher 1 3 4) 
;;            (make-pitcher 2 5 6) (make-pitcher 3 8 10)))
;;            -> (list (make-move 2 1))
;; STRATEGY : FUNCTION COMPOSITION
(define (generate-backward-moves src-index nelop)
  (if (<= src-index INDEX)
      empty
      (append (generate-backward-moves-helper src-index 
                                              (- src-index INITIAL-INDEX-VALUE) 
                                              nelop)
              (generate-backward-moves (- src-index INITIAL-INDEX-VALUE)
                                       nelop))))
;; =============================================================================
;; generate-backward-moves-helper : PosInt PosInt Pitchers -> ListOf<Moves>
;; GIVEN : A source index, a target index an a list of pitchers
;; RETURNS : a list of backward moves from source to target
;; WHERE : trgt-index is the target index which is decremented in each call and 
;;         remains true for each call ,satisfying the function.
;; EXAMPLES : (generate-backward-moves-helper 2 1 (list (make-pitcher 1 3 4)
;;            (make-pitcher 2 5 6))) -> (list (make-move 2 1))
;; STRATEGY : FUNCTION COMPOSITION
(define (generate-backward-moves-helper src-index trgt-index nelop)
  (if (<= trgt-index INDEX)
      empty
      (if (move-valid? src-index trgt-index nelop)
          (cons (make-move src-index trgt-index)
                (generate-backward-moves-helper 
                 src-index (- trgt-index INITIAL-INDEX-VALUE) nelop))
          (generate-backward-moves-helper 
                 src-index (- trgt-index INITIAL-INDEX-VALUE) nelop))))
;; ============================================================================
;; move-valid? : PosInt PosInt Pitchers -> Boolean
;; GIVEN : a source index,a target index and a list of pitchers
;; RETURNS : false if any one condition holds true
;; EXAMPLES : (move-valid? 2 3 (list (make-pitcher 1 2 3) (make-pitcher 2 3 4)
;;            (make-pitcher 3 5 6))) -> true
;; STRATEGY :  FUNCTION COMPOSITION
(define (move-valid? src-index trgt-index list-of-pitcher)
    (not (or (= src-index trgt-index)
             (= (source-contents src-index list-of-pitcher) INDEX)
             (= (trgt-capacity-left trgt-index list-of-pitcher) INDEX))))
;; ============================================================================
;; source-contents : PosInt Pitchers -> PosInt
;; GIVEN : a source index and a list of pitchers
;; RETURNS : the contents of the pitcher
;; EXAMPLES : (source-contents 2 (list (make-pitcher 1 2 3) (make-pitcher 2 3 4)
;;           (make-pitcher 3 5 6)))  -> 3
;; STRATEGY : STRUCTURAL DECOMPOSITION of pitcher
(define (source-contents src-index list-of-pitcher)
  (pitcher-contents (list-ref list-of-pitcher
                              (- src-index INITIAL-INDEX-VALUE))))
;; ============================================================================
;; trgt-capacity-left : PosInt Pitchers -> PosInt
;; GIVEN : a target index and alist of pitchers
;; RETURNS : the remaining capacity which can be filled
;; EXAMPLES : (tgt-rem-capacity 2 (list (make-pitcher 1 2 3) 
;;            (make-pitcher 2 3 4) (make-pitcher 3 5 6)))  -> 1
;; STRATEGY : STRUCTURAL DECOMPOSITION of pitcher
(define (trgt-capacity-left trgt-index list-of-pitcher)
         (- (pitcher-capacity (list-ref list-of-pitcher 
                                        (- trgt-index INITIAL-INDEX-VALUE)))
            (pitcher-contents (list-ref list-of-pitcher 
                                        (- trgt-index INITIAL-INDEX-VALUE)))))

;; =============================================================================
;; generate-forward-moves-helper : PosInt PosInt PosInt Pitchers -> ListOf<Move>
;; GIVEN : a source index,a target index, the length of the list and a list of
;;        pitchers
;; RETURNS : a list of possible forward moves
;; EXAMPLES : (generate-forward-moves-helper 1 2 2 (list (make-pitcher 1 2 3) 
;;           (make-pitcher 2 3 4))) -> (list (make-move 1 2))
;; STRATEGY : FUNCTION COMPOSITION
(define (generate-forward-moves-helper src-index trgt-index length
                                       list-of-pitcher)
  (if (> trgt-index length)
      empty
      (if (move-valid? src-index trgt-index list-of-pitcher)
          (cons (make-move src-index trgt-index)
                (generate-forward-moves-helper
                 src-index (+ trgt-index INITIAL-INDEX-VALUE)
                 length list-of-pitcher))
          (generate-forward-moves-helper 
                 src-index (+ trgt-index INITIAL-INDEX-VALUE)
                 length list-of-pitcher))))
;; =============================================================================
;; generate-forward-moves : PosInt PosInt Pitchers -> ListOf<Move>
;; GIVEN : A source index,the length of list and a list of pitchers
;; RETURNS : a list of moves
;; EXAMPLES : (generate-forward-moves 1 2 (list (make-pitcher 1 2 3) 
;;             (make-pitcher 2 3 4)))-> (list (make-move 1 2))
;; STRATEGY : FUNCTION COMPOSITION
(define (generate-forward-moves src-index length list-of-pitcher)
  (if (> src-index length)
      empty
      (append (generate-forward-moves-helper src-index (+ src-index
                                                          INITIAL-INDEX-VALUE) 
                                             length list-of-pitcher)
              (generate-forward-moves (+ src-index INITIAL-INDEX-VALUE)
                                      length list-of-pitcher))))
;; =============================================================================
;; get-forward-and-backward-moves : Pitchers -> ListOf<Move>
;; GIVEN : A list of pitchers
;; RETURNS : a list of moves
;; EXAMPLES : (get-forward-and-backward-moves (list (make-pitcher 1 2 3) 
;;            (make-pitcher 2 3 4)))  ->(list (make-move 1 2) (make-move 2 1))
;; STRATEGY :FUNCTION COMPOSITION
(define (get-forward-and-backward-moves list-of-pitcher)
  (append (generate-forward-moves INITIAL-INDEX-VALUE
                                  (length list-of-pitcher) list-of-pitcher)
          (generate-backward-moves (length list-of-pitcher) list-of-pitcher)))
;; =============================================================================
;; solve : NEListOf<PosInt> PosInt -> Maybe<ListOf<Move>>
;; GIVEN: a list of the capacities of the pitchers and the goal amount
;; WHERE: initially the first pitcher is filled to capacity and the others
;; are empty
;; RETURNS: a sequence of moves which, when executed from left to right,
;; results in one pitcher (not necessarily the first pitcher) containing
;; the goal amount.  Returns false if no such sequence exists
;; EXAMPLES:solve (list 10 7 3) 5) = solve-results
;; STRATEGY: Function Composition

;; Trivial Cases - 
;; 1) if goal-amt is greater than all the capacities 
;; 2) if goal amount is odd and all capacities are even
;; 3) if list of capacities is empty --> return false
;; 4) if list of capacities is 1 then if capacity == goal-quantity or not

;; else use alorithm to find out solution,
;; if all possible routes in node-tree fail then return false
(define (solve nelopi goal-quantity)
  (using-depth-first-search (get-pitchers-from-capacities nelopi)
                            goal-quantity))
;; ============================================================================
;; is-pitcher-content-goal? : Pitcher PosInt ListOf<Move> -> Maybe<ListOf<Move>>
;; GIVEN : A Pitcher , the goal-quantity, and a list of moves
;; RETURNS : the moves list if pitcher contents is equal to goal quantity
;;           else returns false
;; EXAMPLES : (is-pitcher-content-goal? (make-pitcher 2 4 5) 3 
;;            (list (make-move 2 1))) -> false
;; STRATEGY : STRUCTURAL DECOMPOSITION of p : Pitcher
(define (is-pitcher-content-goal? p goal-quantity moves-list)
  (if (= (pitcher-contents p) goal-quantity)
      moves-list
      false))
;; =============================================================================
;; check-pitchers-for-goal: Pitchers PosInt ListOf<Move> -> Maybe<ListOf<Move>>
;; GIVEN: a list of pitchers, the goal quantity and a list of moves
;; RETURNS: false if pitcher content is equal to the goal
;;          else return the list of moves
;; EXAMPLES: (check-pitchers-for-goal (list (make-pitcher 1 2 3) 
;;           (make-pitcher 2 3 4) (make-pitcher 3 5 6)) 4 (list (make-move 1 2)
;;           (make-move 1 3) (make-move 2 3)))  -> false
;; STRATEGY: STRUCTURAL DECOMPOSITION of Pitchers 
(define (check-pitchers-for-goal nelop goal-quantity lom)
  (cond
    [(empty? (rest nelop)) (is-pitcher-content-goal? (first nelop)
                                                     goal-quantity lom)]
    [else (if (false? (is-pitcher-content-goal? (first nelop)
                                                goal-quantity lom))
              (check-pitchers-for-goal (rest nelop) goal-quantity lom)
              lom)]))
;; =============================================================================
;; goal-more-than-capacity? : Pitchers PosInt -> Boolean
;; GIVEN : a list of pitchers and a oal quantity
;; RETURNS : true iff the goal quantity is greater than the capacity
;; EXAMPLES : (goal-more-than-capacity? (list (make-pitcher 1 8 8)
;;(make-pitcher 1 0 5) (make-pitcher 1 0 3)) 4) = false
;; STRATEGY : HOFC
(define (goal-more-than-capacity? nelop goal-quantity)
  (andmap
   (lambda (p) (< (pitcher-capacity p) goal-quantity))
   nelop))
;; =============================================================================
;; check-if-capacity-even-and-goal-odd : Pitchers PosInt -> Boolean
;; GIVEN : List of pitchers and a goal quantity
;; RETURNS : true if all the pitcher capacities are even and the goal quantity 
;;           is odd, else returns false
;; EXAMPLES : (check-if-capacity-even-and-goal-odd (list (make-pitcher 1 2 4) 
;;            (make-pitcher 2 3 4) (make-pitcher 3 5 6)) 3) -> true
;; STRATEGY :HOFC
(define (check-if-capacity-even-and-goal-odd nelop goal-quantity)
  (and 
   (andmap 
    (lambda (p) (even? (pitcher-capacity p)))
    nelop)
   (odd? goal-quantity)))

;; =============================================================================
;; using-depth-first-search : Pitchers PosInt -> Maybe<ListOf<Move>>
;; GIVEN : Pitchers and the goal-quantity
;; RETURNS : empty if there are no moves,
;;           a list of moves if there is a solution
;;           else false
;; EXAMPLES : (using-depth-first-search (list (make-pitcher 1 5 5) 
;;            (make-pitcher 2 0 4)) 4)    -> (list (make-move 1 2))
;; TRIVIAL CASES for the problem :
;; 1) If the goal quantity is greater than the the first pitcher capacity
;; 2) If the length of the list of pitchers is 1
;; 3) If the list of capacities is 1 then if capacity equals goal-quantity or
;; not
;; 4) If goal amount is odd and all capacities are even
;; STRATEGY : STRUCTURAL DECOMPOSITION of Pitchers
(define (using-depth-first-search nelop goal-quantity)
  (cond
    [(goal-more-than-capacity? nelop goal-quantity) false]
    [(< (pitcher-capacity (first nelop)) goal-quantity) false]
    [(is-length-unit? nelop)
     (is-pitcher-content-goal? (first nelop) goal-quantity empty)]
    [(check-if-capacity-even-and-goal-odd nelop goal-quantity) false]
    [else
     (if (empty? (using-depth-first-search-helper nelop empty empty
                                                  goal-quantity))
              false
              (reverse (using-depth-first-search-helper nelop empty empty
                                                        goal-quantity)))]))
;; =============================================================================
;;is-length-unit? : Pitchers -> Boolean
;;GIVEN : a list of pitchers
;;RETURNS : true iff length of list is 1 else false
;;EXAMPLE : (list (make-pitcher 1 3 5) (make-pitcher 2 4 5))-> 2
;;STRATEGY : Domain Knowledge
(define (is-length-unit? nelop)
  (= (length nelop) INITIAL-INDEX-VALUE))
;; =============================================================================
;; using-depth-search-helper : Pitchers ListOf<Move> ListOf<Pitchers> PosInt ->
;;                             Maybe<ListOf<Move>> 
;; GIVEN : A list of pitchers, a list of moves a list of (list of pitchers) 
;;         denoting the state of the system and a goal value
;; WHERE : nelop is the list of pitchers that have been obtained from a previous
;;         state,
;;         list-of-answer-moves is the moves that have been taken to reach the 
;;         current state,
;;         past-pitcher-state-list is the list of pitchers obtained till now by
;;         havin the moves from list-of-answer-moves
;;         These values remain true for all the iterations at any given instance
;; RETURNS : A list of moves that is the solution of the problem or empty
;; EXAMPLES : (using-depth-first-search-helper (list (make-pitcher 1 3 4) 
;;(make-pitcher 1 5 6)) empty empty 3) = false
;; STRATEGY : FUNCTION COMPOSITION
(define (using-depth-first-search-helper nelop list-of-answer-moves
                                         past-pitcher-state-list goal-quantity)
  (cond 
    ;; Answer reached
    [(not (false? (check-pitchers-for-goal nelop
                                           goal-quantity list-of-answer-moves)))
     list-of-answer-moves]
    [(member nelop past-pitcher-state-list) 
     (check-if-list-empty? list-of-answer-moves)]
    [else (traverse-moves (get-forward-and-backward-moves nelop)
                          nelop
                          list-of-answer-moves 
                          past-pitcher-state-list goal-quantity)]))

;; =============================================================================
;; check-if-list-empty? : ListOf<Move> -> Maybe<ListOf<Move>>
;; GIVEN : A list of moves
;; RETURNS : empty if the list is empty else the list of moves
;; EXAMPLES : (check-if-list-empty? (list (make-move 2 3)(make-move 2 3)))
;;            -> (list (make-move 2 3))
;; STRATEGY : STRUCTURAL DECOMPOSITION of ListOf<Move>

(define (check-if-list-empty? list-of-answer-moves)
  (cond 
    [(empty? list-of-answer-moves) empty]
    [ else (rest list-of-answer-moves)]))

  
;; =============================================================================
;; traverse-moves : ListOf<Move> Pitchers ListOf<Move>  ListOf<Pitchers> PosInt 
;;                  -> Maybe<ListOf<Move>>
;; GIVEN : A list of moves, A list of pichers, a list of moves traversed till 
;;         now, a list of (list of pitchers) denoting the state of the system 
;;         and any given moment and a goal quantity
;; WHERE : nelop is the list of pitchers that have been obtained from a previous
;;         state,
;;         list-of-answer-moves is the moves that have been taken to reach the 
;;         current state,
;;         past-pitcher-state-list is the list of pitchers obtained till now by
;;         havin the moves from list-of-answer-moves
;;         These values remain true for all the iterations at any given instance
;; RETURNS : empty if the list of moves is empty else returns the solution to 
;;           the list of moves
;; EXAMPLES : (traverse-moves (list (make-move 1 2)) (list (make-pitcher 1 3 4)
;;            (make-pitcher 2 5 6)) empty empty 2) -> (list (make-move 1 2))
;; STRATEGY : STRUCTURAL DECOMPOSITION of ListOf<Move>
(define (traverse-moves lom nelop list-of-answer-moves past-pitcher-state-list
                         goal-quantity)
  (cond
    [(empty? lom)(check-if-list-empty? list-of-answer-moves)]
    [else
     (if (equal? list-of-answer-moves
                 (solution-moves-list(first lom) 
                                     nelop
                                     list-of-answer-moves
                                     past-pitcher-state-list
                                     goal-quantity))
         (traverse-moves (rest lom)
                         nelop
                         list-of-answer-moves 
                         past-pitcher-state-list
                         goal-quantity)
         (solution-moves-list (first lom)
                              nelop
                              list-of-answer-moves
                              past-pitcher-state-list
                              goal-quantity))]))
;; =============================================================================
;; solution-moves-list : Move Pitchers ListOf<Move> ListOf<Pitchers> PosInt
;;                       -> ListOf<Move>
;; GIVEN : a move, pitchers, list of moves, list of pitchers and goal quantity 
;; RETURNS : list of moves
;; EXAMPLES : (solution-moves-list (make-move 1 2) (list (make-pitcher 1 3 4)
;;(make-pitcher 1 5 6)) (list (make-move 1 2) (make-move 1 3)) 
;;(list (make-pitcher 1 3 4) (make-pitcher 1 5 6)) 4) =
;;(list (make-move 1 2) (make-move 1 3))
;; STRATEGY : Function Composition
(define (solution-moves-list move nelop list-of-answer-moves 
                             past-pitcher-state-list goal-quantity)
  (using-depth-first-search-helper (find-src-and-tgt nelop move) 
                                   (cons move list-of-answer-moves) 
                                   (cons nelop past-pitcher-state-list)
                                   goal-quantity))

;; =============================================================================
;;                               TEST
;; =============================================================================
(define-test-suite pitcher-after-moves-tests
  (check-equal? (pitchers-after-moves
                 (get-pitchers-from-capacities list-sample) 
                 sample-moves) pitcher-after-moves-result
                 "Should return the pitchers after move")) 
(run-tests pitcher-after-moves-tests)
(define-test-suite solve-tests
  (check-equal? (solve list-sample FIVE) solve-results 
                "Should return one pitcher containg goal amount")
  (check-equal? (solve list-sample-when-goal-more-than-capacity FOUR) false 
                "Should return false since goal is more than capacity")
  (check-equal? (solve list-for-goal-not-in-list FOUR) false
                "Should return false since goal is is not in the list")
  (check-equal? (using-depth-first-search list-for-dfs FOUR)
                false "Should return false")
  (check-equal? (traverse-moves empty list-sample empty list-traverse FIVE)
                empty "Should return empty")
  (check-equal? (check-if-capacity-even-and-goal-odd 
                 list-to-check-capacity FIVE)
                true "Should return true if capacity is odd or even")
  (check-equal? (solve  list-to-solve THREE) false 
                "Should return false")
  (check-equal? (using-depth-first-search list-for-dfs2 TEN)
                false) "Should return false")
(run-tests solve-tests)