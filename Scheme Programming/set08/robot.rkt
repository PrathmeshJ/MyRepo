;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; =============================================================================
;;                                    ALGORITHM 
;; =============================================================================

;; The search technique that we implement in this problem is the
;; Breadth First Search.

;; As a trivial case we first check if the source or target position is a
;; block or not, if any one is a block we return a false

;; Else we see the source position and start processing.
;; We have a list of postion maintained with the list of moves to be taken
;; to reach the position from source.

;; We also maintain a list of visited positions considering their adjacent
;; positions. Everytime when a new adjacent position is generated we make sure 
;; that the adjacent position is not in the given list of blocks or in the
;; list of already visited positions.

;; There can be acondition where our algorithm may take us to infinite length
;; of the chessboard without the goal being reached. So to avoid such conditions
;; we maintain a boundary condition which has a list of boundary positions
;; denoting the area that is sufficient for the robot to move around for the
;; given problem.
;; =============================================================================
;; =============================================================================
;;                           REQUIREs and PROVIDEs
;; =============================================================================

(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")
(provide path)
;; =============================================================================
;; =============================================================================
;;                                   CONSTANTS
;; =============================================================================

(define ONE 1)
(define TWO 2)
(define MIN-BOUNDARY 0)
;; =============================================================================
;; =============================================================================
;;                               DATA DEFINITIONS
;; =============================================================================
;; A Position is a (list PosInt PosInt)
;; (x y) represents the position at position x, y.
;; Note: this is not to be confused with the built-in data type Posn.

;; Template:
;; position-fn : Position -> ??
;; (define (position-fn p)
;;   (...(first p)
;;		 (second p)))
;; =============================================================================
;; A ListOf<Position> (LOP) is either
;; -- empty
;; -- (cons Position LOP)
;; INTERP:
;; empty		    (interp : empty list)
;; (cons Position LOP) (interp : list of Position and a [list of position])

;; TEMPLATE
;; lop-fn : LOP -> ??
;; (define (lop-fn lop)
;;   (cond
;;     [(empty? lop) ...]
;;     [else (...
;;             (first lop)
;;             (lop-fn (rest lop)))]))
;; =============================================================================
;; A ListOf<BoundaryPosition> (LOBP) is either
;; -- empty
;; -- (cons Position Position)
;; INTERP:
;; empty		          (interp : empty list)
;; (cons Position Position)  (interp : list of two boundary positions)

;; TEMPLATE
;; lobp-fn : LOBP -> ??
;;(define (lobp-fn lobp)
;; (...(fn (first lobp)
;;         (second lobp)))
;; =============================================================================
;; A Move is a (list Direction PosInt)
;; Interp: a move of the specified number of steps in the indicated
;; direction.

;; Template:
;; move-fn : Move -> ??
;; (define (move-fn m)
;;   (...(first m)
;;		 (second m)))

;; =============================================================================
;; A Direction is one of
;; -- "north" (interp: shows north or upward direction)
;; -- "south" (interp: shows south or downward direction)
;; -- "east"  (interp: shows east or right direction)
;; -- "west"  (interp: shows west or left direction)
;;
;; TEMPLATE
;; direction-fn : Direction -> ??
;(define (direction-fn d)
;  (cond
;    [(string=? d "north") ...]
;    [(string=? d "south") ...]
;    [(string=? d "east") ...]
;    [(string=? d "west") ...]))

;; =============================================================================
;; A NonEmptyListOf<Move> (NELOM)
;; -- (cons Move LOM)
;; INTERP:
;; (cons Move LOM)   (interp : a non empty list of Move and [a list of moves])

;; TEMPLATE
;; nelom-fn : NELOM -> ??
;; (define (nelom-fn nelom)
;;   (cond
;;     [(empty? (rest nelom)) ...]
;;     [else (...
;;             (first nelom)
;;             (nelom-fn (rest nelom)))]))

;; =============================================================================
;; A ListOf<Move> (LOM) is either
;; -- empty
;; -- (cons Move LOM)
;; INTERP:
;; empty             (interp : list is empty)
;; (cons Move LOM)   (interp : list of a move and [list of moves])

;; TEMPLATE
;; lom-fn : LOM -> ??
;; (define (lom-fn lom)
;;   (cond
;;     [(empty? lom) ...]
;;     [else (...
;;             (first lom)
;;             (lom-fn (rest lom)))]))
;; =============================================================================
;; A Plan is a ListOf<Move>
;; WHERE: the list does not contain two consecutive moves in the same
;; direction.

;; Maybe<Plan> is either
;;-- false  (interp : boolean value false)
;;-- LOM    (interp : a list of moves)

;; Template:
;; mbep-fn: Maybe<Plan> -> ??
;; (define (mbep-fn mbep)
;;  (cond
;;    [(false? mbep) ...]
;;    [else (... (mbep-fn mbep))])

;; =============================================================================
;; A NonEmptyListOf<State> (NELOS) is

;; -- (cons State LOS (interp : non empty list of State and a [list of states])

;; nelos-fn : NELOS -> ??
;; (define (nelos-fn nelos)
;;   (cond
;;     [(empty? (rest nelos)) ... (first nelos)]
;;     [else (...
;;             (state-fn (first nelos))
;;             (nelos-fn (rest nelos)))]))

;; =============================================================================
;; A ListOf<State> (LOS) is
;; -- empty             (interp : empty list)
;; -- (cons State LOS)  (interp : A list of state and a [list of states])

;; los-fn : LOS -> ??
;; (define (los-fn los)
;;   (cond
;;     [(empty? los) ...]
;;     [else (...
;;             (state-fn (first los))
;;             (los-fn (rest los)))]))

;; =============================================================================

;; State is (list Position LOM)

;; Position is the position repesenting
;; x and y co-ordinates
;; LOM is the ListOf<Move> taken to reach the position

;; Template
;; state-fn : State -> ??
;; (define (state-fn s)
;;   (...
;;		(position-fn (first s))
;;		(lom-fn (second s))))
;; =============================================================================
;; =============================================================================
;;                               path
;; =============================================================================
;; path : Position Position ListOf<Position> -> Maybe<Plan>
;; GIVEN:
;; 1. the starting position of the robot,
;; 2. the target position that robot is supposed to reach
;; 3. A list of the blocks on the board
;; RETURNS: a plan that, when executed, will take the robot from
;; the starting position to the target position without passing over any
;; of the blocks, or false if no such sequence of moves exists.
;; EXAMPLE : (path (list 2 6) (list 1 5) (list (list 1 3)))
;;           -> (list (list "west" 1) (list "north" 1))
;; STRATEGY: function composition
(define (path src tgt lop)
      (search-using-bfs src (list (list src empty))
                   (list src)
                   tgt lop
                   (fix-boundary-limits lop src tgt)))

;; =============================================================================
;; search-using-bfs : Position ListOf<State> ListOf<Position> Position
;;				 ListOf<State> ListOf<State> -> Maybe<Plan>
;; GIVEN: starting position, list of new states,list of visited postions,
;;         the target, list of blocks,list of boundary positions
;; RETURNS: Is the plan to reach tgt from the given Position in the
;; first state-list , if not reachable then returns false
;; WHERE : state-list will have position which is a subset of
;; nodes
;; and (there is a path from src to tgt with the lop as a condition)
;; iff (there is a path from newest to tgt)
;; HALTING MEASURE: no new position available to visit 
;; EXAMPLE:
;; see tests below

;; TRIVIAL CASE : 
;; 1) Check if source and target is a block or not
;; STRATEGY: general recursion
(define (search-using-bfs src state-list nodes tgt lop lobp)
  (cond
    ;; check if the source or target is a block or not
    [(or (member src lop) (member tgt lop)) false]
    [(empty? state-list) false]
    ;; if the tgt is in the state-list list then get the move of the member 
    ;; of the state-list
    [(is-position-in-states-list? tgt state-list) 
     (list-of-move-for-target state-list tgt)]
    [else (local
            ;; get the neighboring positions with moves to reach them ,
            ;; for the first of state-list
            ((define next-not-visited-states (nodes-not-visited
                                             (get-adjacent-states-with-moves 
                                              (first state-list) lop lobp)
                                             nodes)))
            (if (empty? next-not-visited-states)
                ;; if there are no nieghboring states for the first state-list
                ;; then recurse with the rest list
                (search-using-bfs src (rest state-list) nodes tgt lop lobp)
                ;; else add the new states to the state-list
                (search-using-bfs src
                                  (append (rest state-list) 
                                          next-not-visited-states)
                                  (add-state-positions-to-lop
                                   next-not-visited-states nodes)
                                  tgt
                                  lop lobp)))]))
;; =============================================================================
;; get-adjacent-states-with-moves : State LOP LOP -> LOS
;; GIVEN: a State s, List of blocks , and the boundary-pair
;; RETURNS: the list of states with neighboring positions 
;; along with the moves to reach it.
;; WHERE: The boundary-pair are list of positions always of length of 2
;; denoting the minimum boundary of the chessboard
;; EXAMPLE: (get-adjacent-states-with-moves (list (list 3 4) 
;;          (list (list "north" 2))) (list (list 1 1) (list 2 2)) 
;;          (list (list 0 0) (list 6 6)))    ->
;;  (list
;;   (list (list 4 4) (list (list "north" 2) (list "east" 1)))
;;   (list (list 2 4) (list (list "north" 2) (list "west" 1)))
;;   (list (list 3 5) (list (list "north" 2) (list "south" 1)))
;;   (list (list 3 3) (list (list "north" 3))))

;; STRATEGY: HOFC + structural decomposition on state : State +
;;			 structural decomposition on lobp : ListOf<Position>
(define (get-adjacent-states-with-moves s lop lobp)
  (filter
   ;; State -> Boolean
   ;; GIVEN: a State
   ;; RETURNS: true iff the Position in the state is
   ;; with-in the boundry and it is not a block
   (lambda (state)
     (check-if-member-and-within-boundary state lop lobp))
   (create-adjacent-positions-with-moves (first (first s)) (second (first s))
                                         (second s))))

;; =============================================================================
;; check-if-member-and-within-boundary : State ListOf<Position> 
;;                                       ListOf(BoundaryPosition) -> Boolean
;; GIVEN : A state, a list of positions and a list of boundary positions
;; RETURNS : true if the position is not a block and within the boundary
;; EXAMPLES : (check-if-member-and-within-boundary (list (list 3 4) 
;;          (list (list "north" 2))) (list (list 1 1) (list 2 2)) 
;;          (list (list 0 0) (list 6 6)))  -> true
;; STRATEGY : Structural decomposition of state: State
(define (check-if-member-and-within-boundary state lop lobp)
  (and (not (member (first state) lop))
          (check-state-with-boundary-positions state lobp)))

;; =============================================================================
;; check-state-with-boundary-positions : State ListOf<BoundaryPosition>->Boolean
;; GIVEN : A state and a boundary list
;; RETURNS : true if the state position does not match the boundary position
;; EXAMPLES : (check-state-with-boundary-positions (list (list 3 4) 
;;            (list (list "north" 2))) (list (list 0 0) (list 6 6))) -> true
;; STRATEGY : structural decomposition on state: State  and 
;;             boundary-pair: ListOf<BoundaryPosition>
(define (check-state-with-boundary-positions state boundary-pair)
  (and (not (= (first (first state)) (first (first boundary-pair))))
       (not (= (first (first state)) (first (second boundary-pair))))
       (not (= (second (first state)) (second (first boundary-pair))))
       (not (= (second (first state)) (second (second boundary-pair))))))

;; =============================================================================
;; create-adjacent-positions-with-moves :
;;		PosInt PosInt LOM -> LOS
;; GIVEN: x and y position, and list of previous moves
;; RETURNS: the adjacent position with the moves (i.e adjacent
;; position states)
;; WHERE: lom represents the moves to reach the position formed
;; by the x and y values
;; EXAMPLE: (create-adjacent-positions-with-moves 2 3 (list (list "north" 1) 
;;                                                    (list "east" 1)))
;;          -> (list
;;               (list (list 3 3) (list (list "north" 1) (list "east" 2)))
;; (list (list 1 3) (list (list "north" 1) (list "east" 1) (list "west" 1)))
;; (list (list 2 4) (list (list "north" 1) (list "east" 1) (list "south" 1)))
;; (list (list 2 2) (list (list "north" 1) (list "east" 1) (list "north" 1))))
;; STRATEGY: function composition
(define (create-adjacent-positions-with-moves xcord ycord lom)
  (list
   (list (list (+ xcord ONE) ycord) 
         (add-new-moves-to-already-traversed lom (list "east" 1)))
   (list (list (- xcord ONE) ycord)
         (add-new-moves-to-already-traversed lom (list "west" 1)))
   (list (list xcord (+ ycord ONE))
         (add-new-moves-to-already-traversed lom (list "south" 1)))
   (list (list xcord (- ycord ONE)) 
         (add-new-moves-to-already-traversed lom (list "north" 1)))))

;; =============================================================================
;; add-new-moves-to-already-traversed : LOM Move -> LOM
;; GIVEN: a list of moves and a move
;; RETURNS: the list of moves after merging the last move with
;; the given move (if the directions are same)
;; EXAMPLE: (add-new-moves-to-already-traversed (list (list "north" 1) 
;;          (list "east" 1)) (list "west" 1))  ->
;;          (list (list "north" 1) (list "east" 1) (list "west" 1))
;; STRATEGY: Structural decomposition on LOM
(define (add-new-moves-to-already-traversed lom m)
  (cond
  [(empty? lom) (list m)]
  [else (if (string=? (first (first (reverse lom))) (first m))
            (append (list-without-the-last-element lom)
                    (list (move-ahead-by-1 (first (reverse lom)))))
            (append lom (list m)))]))

;; =============================================================================
;; move-ahead-by-1 : Move -> Move
;; GIVEN: a Move
;; RETURNS: the given move with the move steps increased
;; by one
;; EXAMPLE:(move-ahead-by-1 (list "north" 1)) -> (list "north" 2)
;; see tests below
;; STRATEGY: structural decomposition on m : Move
(define (move-ahead-by-1 m)
  (list (first m) (+ (second m) ONE)))
;; =============================================================================
;; list-without-the-last-element : NELOM -> NELOM
;; GIVEN: a non-empty list of moves
;; RETURNS: the first lenght - 1 moves from the
;; list of moves
;; EXAMPLE: (list-without-the-last-element (list (list "north" 1) 
;;          (list "east" 1)))  -> (list (list "north" 1))
;; STRATEGY: structural decomposition on nelom : NELOM
;; treating the rest as speial
(define (list-without-the-last-element nelom)
  (cond
    [(empty? (rest nelom)) empty]
    [else (cons (first nelom) 
                (list-without-the-last-element (rest nelom)))]))

;; =============================================================================
;; list-of-move-for-target : NELOS Position -> LOM
;; GIVEN: a list of states and a position
;; WHERE: the given position has to be there in given
;; ListOf<State>
;; RETURNS: LOM associated with the given Position in the
;; given ListOf<state>
;; EXAMPLE: 
;;(list-of-move-for-target (list (list (list 2 3) (list (list "west" 1) 
;;                                                 (list "north" 1)))
;;                          (list (list 3 3) (list "east" 1)))  (list 2 3))
;;(list (list "west" 1) (list "north" 1))
;; STRATEGY: structural decomposition on nelos : NELOS

(define (list-of-move-for-target nelos p)
  (cond
    [(empty? (rest nelos)) (second (first nelos))]
    [else (if (equal? (first (first nelos)) p)
              (second (first nelos))
              (list-of-move-for-target (rest nelos) p))]))

;; =============================================================================
;; add-state-positions-to-lop : LOS LOP -> LOP
;; GIVEN: a list of states and a list of positions
;; RETURNS: the list of positions along with the positions
;; in the LOS added
;; EXAMPLE: (add-state-positions-to-lop (list (list (list 2 3) 
;;          (list "north" 1))) (list (list 2 3)(list 3 3)))
;;          ->  (list (list 2 3) (list 2 3) (list 3 3))
;; STRATEGY: HOFC
(define (add-state-positions-to-lop los lop)
  (foldr
   ; State -> LOP
   ; GIVEN : A state and a position
   ; RETURNS : a list of positions
   (lambda (s base) (cons (first s) base))
   lop
   los))
;; =============================================================================

;; is-position-in-states-list? : Position LOS -> Boolean
;; GIVEN: a position and list of states
;; RETURNS: true iff the given position is found in
;; given list of states
;; EXAMPLE: (is-position-in-states-list? (list 3 5) (list (list (list 3 4) 
;;          (list "north" 2))))   ->  false
;; STRATEGY: HOFC
(define (is-position-in-states-list? tgt los)
  (ormap 
   ; State -> Boolean
   ; GIVEN : A state
   ; RETURNS : true is the positio is in the state else false
   (lambda (s) (equal? (first s) tgt))
   los))
;; =============================================================================
;; nodes-not-visited : LOS LOP -> LOS
;; GIVEN: a list of states and list of positions
;; RETURNS: the given LOS with all the states with
;; position in given list of positions filtered
;; EXAMPLE: (nodes-not-visited (list (list (list 3 4) (list "north" 2))) 
;;          (list (list 2 3) (list 4 5)))  -> (list (list (list 3 4) 
;;                                            (list "north" 2)))
;; STRATEGY: HOFC
(define (nodes-not-visited los lop)
  (filter
   (lambda (s)
     ;; State -> Boolean
     ;; GIVEN: a State
     ;; RETURNS: true iff the Position in the state is
     ;; not in the list of positions 
     (not (member (first s) lop)))
   los))

;; =============================================================================
;; fix-boundary-limits : LOP Position Position -> LOP
;; GIVEN: a list of positions, source position and
;; target position
;; RETURNS: the min and max positions with 2 subtracted
;; and added respectively
;; EXAMPLE: (fix-boundary-limits (list (list 5 4) (list 4 5)) (list 3 4) 
;;          (list 4 5))  -> (list (list 1 2) (list 7 7))
;; STRATEGY: structural decomposition on src : Position
;;           structural decomposition on tgt : Position
(define (fix-boundary-limits lop src tgt)
  (set-min-boundary-coordinates (boundary-padding
                                 (list (calculate-min-or-max-boundary 
                                        (cons src (cons tgt lop)) < (first src)
                                        (second src))
                                       (calculate-min-or-max-boundary 
                                        (cons src (cons tgt lop)) > (first tgt)
                                        (second tgt))))))
;; =============================================================================
;; calculate-min-or-max-boundary : LOP (X X -> X) PosInt PosInt -> LOP
;; GIVEN: a list of positions, a function (+ or -), and
;; two PosInt (x and y of a position from LOP)
;; WHERE: x and y will be the minimum or maximum from the
;; previous values of LOP
;; RETURNS: the min and max from the given list of positions
;; EXAMPLE: (calculate-min-or-max-boundary (list (list 2 3) (list 2 4)) > 5 7)
;;           -> (list 5 7) 
;; STRATEGY: structural decomposition on lop : LOP
(define (calculate-min-or-max-boundary lop opr xcord ycord)
  (cond
    [(empty? lop) (list xcord ycord)]
    [else (calculate-min-or-max-boundary (rest lop) opr
                               (if (opr (first (first lop)) xcord)
                                   (first (first lop))
                                   xcord)
                               (if (opr (second (first lop)) ycord)
                                   (second (first lop))
                                   ycord))]))
;; =============================================================================

;; boundary-padding : LOP -> LOP
;; GIVEN: a list of positions
;; WHERE: the length of list of positions is always two
;; RETURNS: the given min and max positions with 2 subtracted
;; and added respectively
;; EXAMPLE: (boundary-padding (list (list 3 3) (list 6 4)))
;;           - >    (list (list 1 1) (list 8 6))
;; STRATEGY: structural decompsition on lop : LOP
;;           structural decompsition on Position
(define (boundary-padding lop)
  (list (list (- (first (first lop)) TWO)
              (- (second (first lop)) TWO))
        (list (+ (first (second lop)) TWO)
              (+ (second (second lop)) TWO))))

;; =============================================================================
;; set-min-boundary-coordinates : LOP -> LOP
;; GIVEN: a list of positions
;; WHERE: the length of list of positions is always two
;; RETURNS: the given list of positions with the min position
;; changed to origin if it has gone beyond the origin
;; EXAMPLE: (set-min-boundary-coordinates (list (list 2 3) (list 2 4)))
;;          ->  (list (list 2 3) (list 2 4))
;; STRATEGY: structural decompsition on lop : LOP
;;           structural decompsition on Position
(define (set-min-boundary-coordinates lop)
  (if (and (< (second (first lop)) MIN-BOUNDARY) (< (first (first lop)) MIN-BOUNDARY))
      (list (list MIN-BOUNDARY MIN-BOUNDARY)
            (list (first (second lop)) (second (second lop))))
      (if (< (second (first lop)) MIN-BOUNDARY)
          (list (list (first (first lop)) MIN-BOUNDARY)
                (list (first (second lop)) (second (second lop))))
          (if (< (first (first lop)) MIN-BOUNDARY)
              (list (list MIN-BOUNDARY (second (first lop)))
                    (list (first (second lop)) (second (second lop))))
              lop))))
;; =============================================================================
;; =============================================================================
;;                                        TESTS
;; =============================================================================
(define-test-suite path-tests
  (check-equal? 
   (path (list 2 2) (list 4 6) (list (list 3 2) (list 2 4) (list 4 3) (list 4 5)
                                     (list 3 5) (list 1 3) (list 2 3)))
   (list (list "north" 1) (list "east" 3) (list "south" 5) (list "west" 1))
   "The path with given set of blocks")
  
  (check-equal?
   (path (list 3 4) (list 2 2) (list (list 3 4)))
   false
   "sorurce or target is a block")
  
  (check-equal?
   (path (list 3 5) (list 1 4) empty)
   (list (list "west" 2) (list "north" 1))
   "check for path with no blocks on chessboard")
  
  (check-equal?
   (path (list 6 1) (list 2 4) empty)
   (list (list "west" 4) (list "south" 3))
   "check for path with no blocks on chessboard with y less than 0")

  (check-equal?
   (path (list 1 6) (list 7 3) empty)
   (list (list "east" 6) (list "north" 3))
   "check for path with no blocks on chessboard with x less than 0")
  
  (check-equal?
   (path (list 3 3) (list 4 4) empty)
   (list (list "east" 1) (list "south" 1))
   "check for path with no blocks on chessboard with no less than 0")

  (check-equal?
   (path (list 1 2) (list 4 4) (list (list 1 1) (list 1 3) (list 2 2) 
                                     (list 2 4)))
   false
   "position covered with blocks"))


(run-tests path-tests)