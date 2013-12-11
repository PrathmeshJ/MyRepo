;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide initial-world
         world-after-key-event
         world-after-mouse-event
         world-to-roots
         node-to-center
         node-to-sons
         node-to-selected?)

;; =============================================================================
;;                            CONSTANTS
;; =============================================================================

(define NODE-LENGTH 20)
(define HALF-NODE-LENGTH (/ NODE-LENGTH 2))


(define NEW-UNSELECTED-NODE (square NODE-LENGTH "outline" "green"))
(define NEW-SELECTED-NODE (square NODE-LENGTH "solid" "green"))
(define SAME-NODE-RED (square NODE-LENGTH "solid" "red"))
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 300)

(define TOP-CENTER-X (/ CANVAS-WIDTH 2))
(define TOP-CENTER-Y (/ CANVAS-HEIGHT 2))

(define CHANGE-IN-mx 0)
(define CHANGE-IN-my 0)
<<<<<<< HEAD
=======

<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
(define CHECK-LEFT-BOUNDARY (+ ( * 2 NODE-LENGTH) HALF-NODE-LENGTH))

(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
;; =============================================================================
;;                      DATA DEFINITION
;; =============================================================================

(define-struct node (x-pos y-pos selected? lon))
;;A node is a (make-node Number Number Boolean ListOfNodes)
;; x-pos is the x-co-ordinate of the node on x-axis
;; y-pos is the y-co-ordinate of the node on y-axis
;; selected? true if node selected else false
;; lon is the list of child nodes that the particualr node has

;;template:
;; node-fn : Node -> ??
;;(define (node-fn n)
;; (... (node-x n)
;;      (node-y n)
;;      (node-selected? n)
;;      (node-lon n)))

;; A ListOfNodes (LON) which is one of
;; --empty                     (interpret: empty list of nodes)
;; --(cons node ListOfNodes)   (interpret: list of (nodes and LON)

;; Template
;;lon-fn : ListOfNodes -> ??
;;(define (lon-fn l)
;;  (cond
;;    [(empty? l)...]
;;    [else (... (node-fn (first l))
;;               (lon-fn (rest l)))]))

;; World is a ListOfNodes (LON)
;; --empty                     (interpret: empty list of nodes)
;; --(cons node ListOfNodes)   (interpret: list of (nodes and LON)

;; Template
;;world-fn : World -> ??
;;(define (world-fn w)
;;  (cond
;;    [(empty? w)...]
;;    [else (... (node-fn (first w))
;;               (world-fn (rest w)))]))


;; A TreesKeyEvent is a partition of KeyEvent into the following categories
;; -- t                  (interpret : new tree)
;; -- n                  (interpret : new node)
;; -- d                  (interpret : delete node)
;; -- any other KeyEvent (interpret : ignore)
;;Template
;;trees-key-event-fn : TreesKeyEvent -> ??
;;(define (trees-key-event-fn key)
;;  (cond
;;    [(key=? key "t")
;;     ...]
;;    [(key=? key "n")
;;     ...]
;;    [(key=? key "d")
;;     ...]
;;    [else
;;     ...]))

;;A TreesMouseEvent is a partition into the following categories:
;; -- "button-down"           (interp: maybe select the node)
;; -- "drag"                  (interp: maybe drag the node)
;; -- "button-up"             (interp: unselect the node)
;; -- any other mouse event   (interp: ignored)
;
;;(define (mev-fn mev)
;;  (cond
;;    [(mouse=? mev "button-down") ...]
;;    [(mouse=? mev "drag") ...]
;;    [(mouse=? mev "button-up") ...]
;;    [else ...]))

;; map : (X -> Y) ListOf<X> -> ListOf<Y>
;; construct a list by applying f to each item of the given list 
;; that is, (map f (list x_1 ... x_n)) 
;;            = (list (f x_1) ... (f x_n)) 

;; foldr : (X Y -> Y) Y ListOf<X> -> Y
;; apply f on the elements of the given list from right to left, starting
;; with base. 
;; (foldr f base (list x_1 ... x_n)) 
;;   = (f x_1 ... (f x_n base)) 

;; =============================================================================
;;                        EXAMPLES FOR TESTING
;; =============================================================================

(define list-of-nodes-for-testing
  (list
   (make-node 200 300 true (list (make-node 10 10 false empty)))
   (make-node 250 350 true (list (make-node 10 10 false empty)))
   (make-node 20 30 true (list (make-node 10 10 false empty)))))
(define node-for-testing
  (make-node 5 10 true list-of-nodes-for-testing))
(define list-for-node-to-sons
  (list
   (make-node 200 300 true (list (make-node 10 10 false empty)))
   (make-node 250 350 true (list (make-node 10 10 false empty)))
   (make-node 20 30 true (list (make-node 10 10 false empty)))))
(define result-for-node-to-center
  (make-posn 5 10))
(define empty-nodes-for-testing
  (make-node 200 300 true empty))
(define world-for-testing
  (list
   list-of-nodes-for-testing))
(define result-for-world-to-roots 
  (list
   (list
    (make-node 200 300 true (list (make-node 10 10 false empty)))
    (make-node 250 350 true (list (make-node 10 10 false empty)))
    (make-node 20 30 true (list (make-node 10 10 false empty))))))
(define button-down-mouse-event "button-down")
(define drag-mouse-event "drag")
(define button-up-mouse-event "button-up")
(define no-mouse-event "enter")   
(define list-for-button-down-event 
  (list 
   (make-node 200 300 false (list (make-node 200 340 false empty)))
   (make-node 250 350 false (list (make-node 10 10 false empty)))
   (make-node 20 30 false (list (make-node 10 10 false empty)))))
(define list-for-result-of-button-down-event
  (list
   (make-node 200 300 true (list (make-node 200 340 false empty)))
   (make-node 250 350 false (list (make-node 10 10 false empty)))
   (make-node 20 30 false (list (make-node 10 10 false empty)))))
(define list-for-result-of-button-down 
  (list
   (make-node 200 300 false (list (make-node 10 10 false empty)))
   (make-node 250 350 false (list (make-node 10 10 false empty)))
   (make-node 20 30 false (list (make-node 10 10 false empty)))))
(define new-node-key-event "t")
(define new-child-key-event "n")
(define delete-node-key-event "d")
(define no-key-event "s")
(define result-of-t-event 
  (list
   (make-node 200 (/ NODE-LENGTH 2) false empty)
   (make-node 200 300 true (list (make-node 10 10 false empty)))
   (make-node 250 350 true (list (make-node 10 10 false empty)))
   (make-node 20 30 true (list (make-node 10 10 false empty)))))
(define result-for-empty
  (list 
   (make-node 200 (/ NODE-LENGTH 2) false empty)))
(define list-for-n-event 
  (list
   (make-node 200 300 false (list (make-node 10 10 false empty)))
   (make-node 250 350 false (list (make-node 10 10 false empty)))
   (make-node 20 30 false (list (make-node 10 10 false empty)))))
(define result-of-d-event
  (list
   (make-node 200 300 false (list (make-node 10 10 false empty)))
   (make-node 250 350 false (list (make-node 10 10 false empty)))
   (make-node 20 30 false (list (make-node 10 10 false empty)))))
(define list-for-n-key-event
  (list
   (make-node 200 10 false empty)))
(define result-list-for-n-key-event
  (list
   (make-node 200 10 false empty)))
(define list-for-drag-result
  (list
   (make-node 210 310 true (list (make-node 20 20 false empty)))
   (make-node 210 310 true (list (make-node -30 -30 false empty)))
   (make-node 210 310 true (list (make-node 200 290 false empty)))))
(define list-for-nodes-with-child-unselected
  (list (make-node 100 66 false 
                   (list (make-node 17 126 false empty)
                         (make-node 57 126 false empty)
                         (make-node 97 126 false empty)))))

(define list-for-nodes-with-child-selected
  (list (make-node 100 66 true 
                   (list (make-node 17 126 false empty)
                         (make-node 57 126 false empty)
                         (make-node 97 126 false empty)))))
(define list-for-new-child-node
  (list (make-node 200 10 true empty)))
(define list-for-new-child-node-result
  (list (make-node 200 10 true (list (make-node 200 (+ 10 (* 3 NODE-LENGTH))
                                                false empty)))))
(define list-for-nodes-with-child-selected-for-world-toscene
  (list (make-node 100 66 true 
                   (list (make-node 17 126 false empty)))))



;; =============================================================================
;;                       INITIAL-WORLD
;; =============================================================================

;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: an initial world.  The given value is ignored.
;; EXAMPLES : (initial-world 5) = empty
;; STRATEGY : Domain Knowledge
(define (initial-world arg)
  empty)
;;test
(define-test-suite initial-world-tests
  (check-equal? (initial-world node-for-testing) empty 
                "Should return an empty world"))
(run-tests initial-world-tests)

;; =============================================================================
;;                      RUN
;; =============================================================================

;; run :  Any -> World
;;GIVEN : a world and any value
;; EFFECT: runs a copy of an initial world
;; RETURNS: the final state of the world.  The given value is ignored.
;; EXAMPLES : (run 1) creates a world

(define (run any-value) 
  (big-bang (initial-world any-value)
            (on-draw world->scene)
            ;(on-tick world-after-tick 0)
            (on-mouse world-after-mouse-event)
            (on-key  world-after-key-event)))

;; =============================================================================
;;                      WORLD-AFTER-KEY-EVENT
;; =============================================================================

;; world-after-key-event : World TreesKeyEvent -> World
;; GIVEN : a world and its key event
;; RETURNS : a world after te key event
;; EXAMPLES : (world-after-key-event list-of-nodes-for-testing
;;                 new-node-key-event) = result-of-t-event
;; STRATEGY : Structural Decomposition on TreesKeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev "t") (get-a-new-root-node w)]
    [(key=? kev "n") (create-new-child w)]
    [(key=? kev "d") (delete-nodes w)]
    [else w]))

<<<<<<< HEAD
<<<<<<< HEAD

 ;; STRATEGY: structural decomposition on lot: LOT
(define (get-a-new-root-node lon)
=======
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
;; get-a-new-node : World -> World
;; GIVEN : a world
;; RETURNS : a world after the occurence of that key event
;; EXAMPLE : (get-a-new-node list-of-nodes-for-testing) =
;; (list
;; (make-node 200 10 false empty)
;; (make-node 200 300 true (list (make-node 10 10 false empty)))
;; (make-node 250 350 true (list (make-node 10 10 false empty)))
;; (make-node 20 30 true (list (make-node 10 10 false empty))))
;; STRATEGY : Structural Decomposition on World

(define (get-a-new-node w)
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
  (cond
    [(empty? w) (cons (make-node
                       TOP-CENTER-X
                       HALF-NODE-LENGTH
                       false empty)
                      empty)]
    [else (cons (make-node
                 TOP-CENTER-X 
                 HALF-NODE-LENGTH 
                 false empty) w)]))

;; create-new-child : World -> World
;; GIVEN : a world
;; RETURNS : a world after the occurence of that key event
;; EXAMPLE : (create-new-child list-of-nodes-for-testing) =
;; (list
;; (make-node 200 300 true (list (make-node 10 10 false empty)))
;; (make-node 250 350 true (list (make-node 10 10 false empty)))
;; (make-node 20 30 true (list (make-node 10 10 false empty))))
;; STRATEGY : HOFC

(define (create-new-child w)
  (map
   ;;Node -> Node
   ;;GIVEN: a child node
   ;;RETURNS: updated node
   (lambda (node)
     (create-sons-on-left node))
   w))

 
;;create-sons-on-left : Node -> Node
;;GIVEN : a node
;;RETURNS : a new node which is created on the left 
;;EXAMPLE : (create-sons-on-left node-for-testing) =
;;(make-node 5 10 true
;; (list
;;  (make-node 200 300 true (list (make-node 10 10 false empty)))
;;  (make-node 250 350 true (list (make-node 10 10 false empty)))
;;  (make-node 20 30 true (list (make-node 10 10 false empty)))))
;;STRATEGY: Structural Decomposition n : Node

(define (create-sons-on-left node)
<<<<<<< HEAD
<<<<<<< HEAD
  (if (node-to-selected? node)
      (if (< CHECK-LEFT-BOUNDARY (calculate-min-x-position (node-x-pos node) (node-LON node)))
          
          (make-node (node-x-pos node)
                     (node-y-pos node) 
                     true
                     (cons (make-node (- (calculate-min-x-position (node-x-pos node) (node-LON node)) 40) 
                                      (+ 60 (node-y-pos node)) 
                                      false empty)
                           (node-LON node)))
          node)
=======
  (if (node-selected? node)
      (node-to-left node)
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
  (if (node-selected? node)
      (node-to-left node)
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
      (make-node (node-x-pos node)
                 (node-y-pos node)
                 false 
                 (create-new-child (node-lon node)))))

;;node-to-left : Node -> Node
;;GIVEN : a selected node
;;RETURNS : a new node at a new position
;;EXAMPLE : (node-to-left node-for-testing) =
;;(make-node 5 10 true 
;;(list
;;  (make-node 200 300 true (list (make-node 10 10 false empty)))
;;  (make-node 250 350 true (list (make-node 10 10 false empty)))
;;  (make-node 20 30 true (list (make-node 10 10 false empty)))))
;;STRATEGY : Structural Decomposition n : Node

(define (node-to-left node)
  (if (< CHECK-LEFT-BOUNDARY(calculate-min-x-position 
                             (node-x-pos node)
                             (node-lon node)))
      (make-node (node-x-pos node)
                 (node-y-pos node)
                 true
                 (cons (make-node 
                        (- (calculate-min-x-position
                            (node-x-pos node) (node-lon node))
                           (* 2 NODE-LENGTH)) 
                        (+ ( * 3 NODE-LENGTH) (node-y-pos node)) 
                        false empty)
                       (node-lon node)))
      node))


;;calculate-min-x-position : Number LON -> Number
;;GIVEN : the x-position of current node and list of its child nodes
;;RETURNS : a new x-position
;;EXAMPLES : (calculate-min-x-position 5 (list
;;  (make-node 200 300 true (list (make-node 10 10 false empty)))
;;  (make-node 250 350 true (list (make-node 10 10 false empty)))
;;  (make-node 20 30 true (list (make-node 10 10 false empty))))) = 20
;;STRATEGY: HOFC

(define (calculate-min-x-position x-pos list-of-children)
<<<<<<< HEAD
<<<<<<< HEAD
  (cond
    [(empty? list-of-children) (+ 40 x-pos)]
    [else (min (get-child-with-min-x (first list-of-children))
               (calculate-min-x-position x-pos (rest list-of-children)))]))

=======
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
  (foldr
   ;; Node Number -> Number
   ;; GIVEN : a node and number
   ;; RETURNS : minimum number
   (lambda (n no) 
     (min (get-child-with-min-x n) no))
   (+ (* 2 NODE-LENGTH) x-pos)
   list-of-children))  

;;get-child-with-min-x : Node -> Number
;;GIVEN : a structure node
;;RETURNS : the x position of the node
;;EXAMPLES : (get-child-with-min-x node-for-testing) = 5
;;STRATEGY : Structural Decomposition on n : Node
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b

(define (get-child-with-min-x node)
  (node-x-pos node))

<<<<<<< HEAD
<<<<<<< HEAD


(define (delete-nodes w)
  (foldr 
   (lambda (n x)
     (if (node-to-selected? n)
         x
         (cons (delete-child-node n) (delete-nodes x))))
   empty
   w))


(define (delete-child-node n)
  (make-node (node-x-pos n)
             (node-y-pos n)
             (node-selected? n)
             (delete-nodes (node-LON n))))


=======
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
;;delete-nodes : World -> World
;;GIVEN : a world
;;RETURNS : a world after the nodes are deleted
;;EXAMPLES : (delete-nodes list-of-nodes-for-testing) = empty
;;STRATEGY : HOFC 
(define (delete-nodes w)
  (foldr 
   ;;Node LON -> LON
   ;;GIVEN : a node and LON
   ;;RETURNS : an updated list of nodes
   (lambda (n x)
     (if (node-selected? n)
         x
         (cons (delete-child-node n) x)))
   empty
   w)) 
 
;;delete-child-node : Node -> Node
;;GIVEN : a node 
;;RETURNS : a new node 
;;EXAMPLES : (delete-child-node node-for-testing) =
;;           (make-node 5 10 true empty)
;;STRATEGY : Structural Decomposition on n : Node
(define (delete-child-node n)
  (make-node (node-x-pos n) (node-y-pos n) (node-selected? n)
             (delete-nodes (node-lon n))))


;;tests
(define-test-suite world-after-key-event-tests
  (check-equal? (world-after-key-event list-of-nodes-for-testing
                 new-node-key-event) result-of-t-event
                "Should create a new node")
  (check-equal? (world-after-key-event empty new-node-key-event)
                result-for-empty
                "Should create a new node")
  (check-equal? (world-after-key-event list-of-nodes-for-testing
                 new-child-key-event) list-of-nodes-for-testing
                 "Should return the select node")
  (check-equal? (world-after-key-event list-for-n-event
                 new-child-key-event) list-for-n-event
                 "Should return the unselected node")
  (check-equal? (world-after-key-event list-of-nodes-for-testing
                 delete-node-key-event) empty
                 "Should return empty world")
  (check-equal? (world-after-key-event list-for-n-event delete-node-key-event)
                result-of-d-event
                "Should delete the node")
  (check-equal? (world-after-key-event list-of-nodes-for-testing no-key-event)
                list-of-nodes-for-testing
                "Should have no effect on the world")
  (check-equal? (world-after-key-event list-for-new-child-node
                 new-child-key-event) list-for-new-child-node-result
                "Should return world after n key event"))

(run-tests world-after-key-event-tests)
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
;; =============================================================================
;;                                 world->scene
;; =============================================================================

;; world->scene : World -> Scene
;; GIVEN: a world
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world->scene select-for-drag)=>node-selected-scene
;; STRATEGY: Function Composition

(define (world->scene w)
  (get-list-of-trees  w EMPTY-CANVAS 0 0))

;;get-list-of-trees :LON Scene Number Number -> Scene
;;GIVEN : a scene and initial x and y positions as 0
;;RETURNS : a scene 
;;EXAMPLE : (get-list-of-trees empty 
;;(place-image-with-scene-and-line (make-node 10 10 false empty)
;;SAME-NODE-RED EMPTY-CANVAS 50 50) 200 10) = 
;;(place-image-with-scene-and-line (make-node 10 10 false empty)
;;SAME-NODE-RED EMPTY-CANVAS 50 50)
;;STRATEGY: Structural Decomposition on lon: ListOfNodes

(define (get-list-of-trees lon scene x y)
  (cond
    [(empty? lon) scene]
    [else (get-each-node (first lon)
<<<<<<< HEAD
<<<<<<< HEAD
                         (get-list-of-trees (rest lon) scene x y ) x y)])) 


;;STRATEGY: structural decomposition n:Node
(define (get-each-node n scene x y)
  (if (and  (= 0 x) (= 0 y))
      (if (node-selected? n)
          (if (< CHECK-LEFT-BOUNDARY (calculate-min-x-position (node-x-pos n) (node-LON n)))
              
              (place-image NEW-SELECTED-NODE
                           (node-x-pos n)
                           (node-y-pos n)
                           (get-list-of-trees (node-LON n)
                                              scene
                                              (node-x-pos n)
                                              (node-y-pos n)))
              (place-image SAME-NODE-RED
                           (node-x-pos n)
                           (node-y-pos n)
                           (get-list-of-trees (node-LON n)
                                              scene
                                              (node-x-pos n)
                                              (node-y-pos n))))
          (place-image NEW-UNSELECTED-NODE
                       (node-x-pos n)
                       (node-y-pos n)
                       (get-list-of-trees (node-LON n)
                                          scene 
                                          (node-x-pos n)
                                          (node-y-pos n))))
      (if (node-selected? n)
          (scene+line (place-image NEW-SELECTED-NODE
                                   (node-x-pos n)
                                   (node-y-pos n)
                                   (get-list-of-trees (node-LON n)
                                                      scene
                                                      (node-x-pos n)
                                                      (node-y-pos n))) 
                      (node-x-pos n)
                      (node-y-pos n)
                      x
                      y
                      "blue" )
          (scene+line (place-image NEW-UNSELECTED-NODE
                                   (node-x-pos n)
                                   (node-y-pos n)
                                   (get-list-of-trees (node-LON n) 
                                                      scene
                                                      (node-x-pos n) 
                                                      (node-y-pos n)))
                      (node-x-pos n)
                      (node-y-pos n)
                      x
                      y
                      "blue" ))))
=======
                         (get-list-of-trees (rest lon) scene x y ) x y)]))



;;place-image-on-scene : Image Node Scene -> Scene
;;GIVEN : a node and scene
;;RETURNS : the placed on the scene
;;EXAMPLE : (place-image-on-scene (place-image-with-scene-and-line
;;(make-node 10 10 false empty) SAME-NODE-RED EMPTY-CANVAS 50 50))
;;(scene+line (place-image NEW-SELECTED-NODE 200 10
;;(get-list-of-trees empty EMPTY-CANVAS 200 10)) 200 10 50 50 "blue")
;;STRATEGY : Structural Decomposition on n : Node
(define (place-image-on-scene node-type node scene)
  (place-image node-type (node-x-pos node)
               (node-y-pos node)
               (get-list-of-trees (node-lon node)
                                  scene
                                  (node-x-pos node)
                                  (node-y-pos node))))


;;place-image-with-scene-and-line : Node Image Scene Number Number -> Scene
;;GIVEN : a node with its scene and type of node to be placed on given positions 
;;RETURNS : a scene with lines connecting the nodes
;;EXAMPLE : (place-image-with-scene-and-line
;;(make-node 200 10 true empty) NEW-SELECTED-NODE EMPTY-CANVAS 50 50)=
;;(scene+line (place-image NEW-SELECTED-NODE 200 10
;;(get-list-of-trees empty EMPTY-CANVAS 200 10)) 200 10 50 50 "blue")
;;STRATEGY : Structural Decomposition on n : Node
(define (place-image-with-scene-and-line node node-type scene x y)
  (scene+line (place-image node-type
                           (node-x-pos node)
                           (node-y-pos node)
                           (get-list-of-trees (node-lon node)
                                              scene
=======
                         (get-list-of-trees (rest lon) scene x y ) x y)]))



;;place-image-on-scene : Image Node Scene -> Scene
;;GIVEN : a node and scene
;;RETURNS : the placed on the scene
;;EXAMPLE : (place-image-on-scene (place-image-with-scene-and-line
;;(make-node 10 10 false empty) SAME-NODE-RED EMPTY-CANVAS 50 50))
;;(scene+line (place-image NEW-SELECTED-NODE 200 10
;;(get-list-of-trees empty EMPTY-CANVAS 200 10)) 200 10 50 50 "blue")
;;STRATEGY : Structural Decomposition on n : Node
(define (place-image-on-scene node-type node scene)
  (place-image node-type (node-x-pos node)
               (node-y-pos node)
               (get-list-of-trees (node-lon node)
                                  scene
                                  (node-x-pos node)
                                  (node-y-pos node))))


;;place-image-with-scene-and-line : Node Image Scene Number Number -> Scene
;;GIVEN : a node with its scene and type of node to be placed on given positions 
;;RETURNS : a scene with lines connecting the nodes
;;EXAMPLE : (place-image-with-scene-and-line
;;(make-node 200 10 true empty) NEW-SELECTED-NODE EMPTY-CANVAS 50 50)=
;;(scene+line (place-image NEW-SELECTED-NODE 200 10
;;(get-list-of-trees empty EMPTY-CANVAS 200 10)) 200 10 50 50 "blue")
;;STRATEGY : Structural Decomposition on n : Node
(define (place-image-with-scene-and-line node node-type scene x y)
  (scene+line (place-image node-type
                           (node-x-pos node)
                           (node-y-pos node)
                           (get-list-of-trees (node-lon node)
                                              scene
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
                                              (node-x-pos node)
                                              (node-y-pos node))) 
              (node-x-pos node) (node-y-pos node) x y "blue"))
              
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b


;;get-each-node : Node Scene Number Number -> Scene
;;GIVEN : a node and scene along with x and y position 
;;RETURNS : a scene with a node placed
;;EXAMPLE : (get-each-node (make-node 10 10 false empty)
;;EMPTY-CANVAS 0 0) = (place-image NEW-UNSELECTED-NODE 10 10 EMPTY-CANVAS)
;;STRATEGY: Structural Decomposition on n : Node

(define (get-each-node node scene x y)
  (if (and  (= 0 x) (= 0 y))
      (if (node-selected? node)
          (node-selected-initially node scene)  
          (place-image-on-scene NEW-UNSELECTED-NODE node scene))
      (if (node-selected? node)
          (node-with-lines node scene x y)
          (place-image-with-scene-and-line node NEW-UNSELECTED-NODE
                                           scene x y))))

;;node-selected-initially : Node Scene -> Scene
;;GIVEN : a a node and scene
;;RETURNS : node placed on a scene
;;EXAMPLE :(node-selected-initially (make-node 10 10 false empty)
;;EMPTY-CANVAS) = (place-image-on-scene SAME-NODE-RED
;;(make-node 10 10 false empty) EMPTY-CANVAS)
;;Strategy : Structural Decomposition on n : Node
(define (node-selected-initially node scene)
  (if (< CHECK-LEFT-BOUNDARY (calculate-min-x-position 
                              (node-x-pos node) (node-lon node)))
      (place-image-on-scene NEW-SELECTED-NODE node scene)
      (place-image-on-scene SAME-NODE-RED node scene)))

;;node-with-lines: Node Scene Number Number -> Scene
;;GIVEN : a a node and scene with x and y positions
;;RETURNS : node with lines placed on a scene
;;EXAMPLE : (node-with-lines (make-node 10 10 true empty) EMPTY-CANVAS 50 50)
;;(place-image-with-scene-and-line (make-node 10 10 false empty)=
;;SAME-NODE-RED EMPTY-CANVAS 50 50)
;;Strategy : Structural Decomposition on n : Node
(define (node-with-lines node scene x y)
  (if (< CHECK-LEFT-BOUNDARY (calculate-min-x-position 
                              (node-x-pos node) (node-lon node)))
      (place-image-with-scene-and-line node NEW-SELECTED-NODE scene x y)
      (place-image-with-scene-and-line node SAME-NODE-RED scene x y)))

;test

(define NODE-FOR-SCENE-LINES 
  (make-node 176 88 false (list (make-node 176 148 false empty))))

(check-equal? (node-with-lines NODE-FOR-SCENE-LINES EMPTY-CANVAS 50 50)
              (place-image-with-scene-and-line 
               NODE-FOR-SCENE-LINES NEW-SELECTED-NODE EMPTY-CANVAS 50 50)
              "Node with scene + line")

(check-equal? (node-selected-initially NODE-FOR-SCENE-LINES EMPTY-CANVAS)
              (place-image-on-scene 
               NEW-SELECTED-NODE
               NODE-FOR-SCENE-LINES EMPTY-CANVAS)
              "Node selected initially with place image only")

(define-test-suite node-trees
  (check-equal? (world-after-key-event (list
                                        (make-node 200 50 false empty)) "t")
                (list
                 (make-node 200 (/ NODE-LENGTH 2) false empty)
                 (make-node 200 50 false empty))
                "List for t-key event"))

(check-equal? (world-after-key-event list-of-nodes-for-testing "n")
              (list
               (make-node 200 300 true (list (make-node 10 10 false empty)))
               (make-node 250 350 true (list (make-node 10 10 false empty)))
               (make-node 20 30 true (list (make-node 10 10 false empty))))
              "List for n-key event")
(run-tests node-trees)

(check-equal? (world-after-key-event list-for-nodes-with-child-unselected "d")
              (list (make-node 100 66 false 
                               (list (make-node 17 126 false empty)
                                     (make-node 57 126 false empty)
                                     (make-node 97 126 false empty))))
              "unselected node for delete")
(check-equal? (world-after-key-event list-for-nodes-with-child-selected "d")
              empty "list after deletion")

(check-equal? (create-sons-on-left 
               (make-node 20 30 false (list (make-node 10 10 false empty))))
              (make-node 20 30 false (list (make-node 10 10 false empty)))
              "Create son fails since node unselected")

(check-equal?(world->scene list-for-nodes-with-child-selected-for-world-toscene)
             (place-image-on-scene
              SAME-NODE-RED
              (make-node 100 66 true (list (make-node 17 126 false empty)))
              EMPTY-CANVAS)
             "World-> scene for nodes with child selected")

(check-equal? (node-with-lines (make-node 10 10 true empty) EMPTY-CANVAS 50 50)
              (place-image-with-scene-and-line (make-node 10 10 false empty)
                                               SAME-NODE-RED EMPTY-CANVAS 50 50)
              "Node with no child possible")

(check-equal? (get-each-node (make-node 10 10 false empty) EMPTY-CANVAS 0 0)
              (place-image NEW-UNSELECTED-NODE 10 10 EMPTY-CANVAS)
              "Unselected node with checkboundary invalid")

(check-equal? (get-each-node (make-node 10 10 true empty) EMPTY-CANVAS 10 10)
              (scene+line (place-image SAME-NODE-RED
                                       10 10 
                                       (get-list-of-trees empty
                                                          EMPTY-CANVAS
                                                          10 10)) 
                          10 10 10 10 "blue")
              "Node with no child possible for a scene+line")

(check-equal? (node-with-lines (make-node 0 0 false empty) EMPTY-CANVAS 30 30)
              (place-image-with-scene-and-line (make-node 0 0 false empty)
                                               SAME-NODE-RED EMPTY-CANVAS 30 30)
              "No child possible")

(check-equal? (node-selected-initially (make-node 10 10 false empty)
                                       EMPTY-CANVAS)
              (place-image-on-scene SAME-NODE-RED
                                    (make-node 10 10 false empty) EMPTY-CANVAS) 
              "Node selected")

(check-equal? (node-with-lines (make-node 10 10 false empty) EMPTY-CANVAS 50 50)
              (scene+line (place-image SAME-NODE-RED
                                       10 10 
                                       (get-list-of-trees empty
                                                          EMPTY-CANVAS
                                                          10 10)) 
                          10 10 50 50 "blue"))


;; =============================================================================
;;                            world-after-mouse-event
;; =============================================================================


;; world-after-mouse-event : World Number Number MouseEvent -> World
;; GIVEN: A world , x and y coordinate of the mouse and a mouseevent
;; RETURNS: the world that follows the given mouse event.
;; EXAMPLES: (world-after-mouse-event list-of-nodes-for-testing 30 30 "drag") =
;; (list
;; (make-node 30 30 true (list (make-node -160 -260 false empty)))
;; (make-node 30 30 true (list (make-node -210 -310 false empty)))
;; (make-node 30 30 true (list (make-node 20 10 false empty))))
;; STRATEGY: Structural Decomposition on mev : TreesMouseEvent

(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "button-up")(world-after-button-up w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [else w]))

;; world-after-button-down : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a button-down at the given location.
;; if the button-down is inside the node, return a outlined node that it is
;; selected.
;; EXAMPLE: (world-after-button-down list-of-nodes-for-testing 30 30) =
;; (list
;; (make-node 200 300 false (list (make-node 10 10 false empty)))
;; (make-node 250 350 false (list (make-node 10 10 false empty)))
;; (make-node 20 30 true (list (make-node 10 10 false empty))))
;; STRATEGY : Function Composition 

(define (world-after-button-down w mx my)
  (fetch-list w mx my))

;; fetch-list : LON Number Number -> LON
;; GIVEN: a LON , x and y coordinates of the mouse pointer.
;; RETURNS: the LON following a button-down at the given location.
;; if the button-down is inside the node, return a solid node that it
;; is selected.
;; EXAMPLE: (fetch-list list-of-nodes-for-testing 40 40) =
;; (list
;; (make-node 200 300 false (list (make-node 10 10 false empty)))
;; (make-node 250 350 false (list (make-node 10 10 false empty)))
;; (make-node 20 30 false (list (make-node 10 10 false empty))))
;; STRATEGY : HOFC

(define (fetch-list list mx my)
  (map
   ;;Node -> Node 
   ;;GIVEN : a node
   ;;RETURNS : node after button down
   (lambda (node) 
     (select-node node mx my))
   list))

;;select-node : Node Number Number -> Node
;;GIVEN: a node and mouse x and y position
;;RETURNS: an updated node
;;EXAMPLE: (select-node node-for-testing 200 200) =
;;(make-node 5 10 false
;; (list
;;  (make-node 200 300 false (list (make-node 10 10 false empty)))
;;  (make-node 250 350 false (list (make-node 10 10 false empty)))
;;  (make-node 20 30 false (list (make-node 10 10 false empty)))))
;;STRATEGY: Structural Decomposition on n : Node

(define (select-node node mx my)
  (if (in-node? node mx my)
      (make-node (node-x-pos node)
                 (node-y-pos node)
                 true 
                 (fetch-list (node-lon node) mx my))
      (make-node (node-x-pos node)
                 (node-y-pos node)
                 false
                 (fetch-list (node-lon node) mx my))))


;; world-after-button-up : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a button-up at the given location.
;; if the node is selected, return a node just like the given one,
;; except that it is no longer selected.
;; EXAMPLE: (world-after-button-up list-of-nodes-for-testing 40 40)
;;(list
;; (make-node 200 300 false (list (make-node 10 10 false empty)))
;; (make-node 250 350 false (list (make-node 10 10 false empty)))
;; (make-node 20 30 false (list (make-node 10 10 false empty))))
;; STRATEGY:  Function Composition
(define (world-after-button-up w mx my)
  (fetch-button-up-list w mx my))


;; fetch-button-up-list : LON Number Number -> LON
;; GIVEN : A List anf the x and y cooridinates of the mouse pointer
;; RETURNS : an unselected node
;; EXAMPLES : (fetch-button-up-list list-of-nodes-for-testing 200 200) =
;; (list
;; (make-node 200 300 false (list (make-node 10 10 false empty)))
;; (make-node 250 350 false (list (make-node 10 10 false empty)))
;; (make-node 20 30 false (list (make-node 10 10 false empty))))
;; STRATEGY : HOFC

(define (fetch-button-up-list list mx my)
  (map
   ;;Node -> Node
   ;;GIVEN: a node
   ;;RETURNS: node after button up
   (lambda (node)
     (fetch-button-up-child node mx my))
   list))

;;fetch-button-up-child : Node Number Number -> Node
;;GIVEN: a node and mouse x and y position
;;RETURNS: an unselected node
;;EXAMPLE: (fetch-button-up-child node-for-testing 5 10) =
;;(make-node 5 10 false
;; (list
;;  (make-node 200 300 false (list (make-node 10 10 false empty)))
;;  (make-node 250 350 false (list (make-node 10 10 false empty)))
;;  (make-node 20 30 false (list (make-node 10 10 false empty)))))
;;STRATEGY: Structural Decomposition on n : Node
(define (fetch-button-up-child node mx my)
  (make-node (node-x-pos node)
             (node-y-pos node)
             false
             (fetch-button-up-list (node-lon node) mx my)))



;; world-after-drag : World Number Number -> World
;; GIVEN: a world , x-axis and y-axis coordinates of the mouse pointer.
;; RETURNS: the world following a drag at the given location.
;; if the world is selected, then return a world just like the given
;; one, except that it is now centered on the position relative to the
;; selected point on the node by the mouse position.
;; EXAMPLE: (world-after-drag list-of-nodes-for-testing 5 10)=
;;(list
;; (make-node 5 10 true (list (make-node -185 -280 false empty)))
;; (make-node 5 10 true (list (make-node -235 -330 false empty)))
;; (make-node 5 10 true (list (make-node -5 -10 false empty))))
;; STRATEGY : Function Composition.

(define (world-after-drag w mx my)
  (get-the-drag-event-list w mx my CHANGE-IN-mx CHANGE-IN-my))

;; get-the-drag-event-list : LOB Number Number LOB
;; GIVEN : A List , xcoordinate, y-coordinate
;; RETURNS : An updated List or an empty list
;; EXAMPLES : (get-the-drag-event-list list-of-nodes-for-testing 5 10 5 10) =
;;(list
;; (make-node 5 10 true (list (make-node -185 -280 false empty)))
;; (make-node 5 10 true (list (make-node -235 -330 false empty)))
;; (make-node 5 10 true (list (make-node -5 -10 false empty))))
;; STRATEGY : HOFC

(define (get-the-drag-event-list list mx my del-mx del-my)
  (map
   ;; Node -> Node
   ;; GIVEN : a node
   ;; RETURNS : a node after drag
   (lambda (node) (get-the-node-to-drag node mx my del-mx del-my))
   list))


;;get-the-node-to-drag : Node Number Number Number Number -> Node
;;GIVEN: a node and positions to drag
;;RETURNS: a node at new position
;;EXAMPLE: (get-the-node-to-drag node-for-testing 5 10 5 10) =
;;(make-node 5 10 true
;;(list
;;  (make-node 5 10 true (list (make-node -185 -280 false empty)))
;;  (make-node 5 10 true (list (make-node -235 -330 false empty)))
;;  (make-node 5 10 true (list (make-node -5 -10 false empty)))))
;;STRATEGY:Structural Decomposition on n : Node

(define (get-the-node-to-drag node mx my del-mx del-my)
  (if (node-selected? node)   
      (make-node mx
                 my
                 true
                 (get-the-drag-event-list (node-lon node)
                                          mx
                                          my
                                          (- mx (node-x-pos node))
                                          (- my (node-y-pos node))))
      (make-node (+ (node-x-pos node) del-mx)
                 (+ (node-y-pos node) del-my)
                 false
                 (get-the-drag-event-list (node-lon node)
                                          mx
                                          my
                                          del-mx
                                          del-my))))


;; in-node? : Node Number Number -> Boolean
;; RETURNS true iff the given coordinate is inside the bounding box of
;; the given node.
;; EXAMPLES: (in-node? node-for-testing 5 10) = true
;; STRATEGY: Structural Decomposition on n : Node
(define (in-node? n x y)
  (and
   (<= 
    (- (node-x-pos n) HALF-NODE-LENGTH)
    x
    (+ (node-x-pos n) HALF-NODE-LENGTH))
   (<= 
    (- (node-y-pos n) HALF-NODE-LENGTH)
    y
    (+ (node-y-pos n) HALF-NODE-LENGTH))))


;tests
(define-test-suite world-after-mouse-event-tests
  (check-equal? (world-after-mouse-event list-for-button-down-event
                                         210 310 button-down-mouse-event) 
                list-for-result-of-button-down-event 
                "Should return a selected node when mouse in the node")
  (check-equal? (world-after-mouse-event list-of-nodes-for-testing
                                         210 310 button-up-mouse-event) 
                list-for-result-of-button-down
                "Should return a unselected node when mouse in the node")
  (check-equal? (world-after-mouse-event list-of-nodes-for-testing
                                         210 310 drag-mouse-event) 
                list-for-drag-result
                "Should return a node dragged to new position")
  (check-equal? (world-after-mouse-event list-of-nodes-for-testing
                                         210 310 no-mouse-event)
                list-of-nodes-for-testing
                "Should return node same as the given one"))

(run-tests world-after-mouse-event-tests)



;; =============================================================================
;;                WORLD-T0-ROOTS
;; =============================================================================

;; world-to-roots : World -> ListOf<Node>
;; GIVEN: a World
;; RETURNS: a list of all the root nodes in the given world.
<<<<<<< HEAD
<<<<<<< HEAD

(define (world-to-roots world)
  world)
=======
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
;; EXAMPLE: (world-to-roots list-of-nodes-for-testing) = 
;; list-of-nodes-for-testing
;; STRATEGY: Domain Knowledge
(define (world-to-roots world)
  world)

;;tests
(define-test-suite world-to-roots-for-testing 
  (check-equal? (world-to-roots list-of-nodes-for-testing)
                list-of-nodes-for-testing
                "Should return the given world")) 
(run-tests world-to-roots-for-testing)

;; =============================================================================
;;                NODE-TO-CENTER
;; =============================================================================
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
 
;; node-to-center : Node -> Posn
;; GIVEN : a node
;; RETURNS: the center of the given node as it is to be displayed on the scene.
<<<<<<< HEAD
<<<<<<< HEAD
(define (node-to-center node)
  (make-posn (node-x-pos node) (node-y-pos node)))

(node-to-center (make-node 172 134 false empty))

;; node-to-sons : Node -> ListOf<Node>
(define (node-to-sons node)
  (if (empty? (node-LON node)) empty
      (node-LON node)))
      
=======
;; EXAMPLE:(node-to-center (make-node 172 134 false empty)) = (make-posn 172 134)
;; STRATEGY: Structural Decomposition on n : Node
(define (node-to-center node)
  (make-posn (node-x-pos node) (node-y-pos node)))

;;tests
(define-test-suite node-to-center-tests
  (check-equal? (node-to-center node-for-testing) result-for-node-to-center))
(run-tests node-to-center-tests)

;; =============================================================================
;;                NODE-TO-SONS
;; =============================================================================

=======
;; EXAMPLE:(node-to-center (make-node 172 134 false empty)) = (make-posn 172 134)
;; STRATEGY: Structural Decomposition on n : Node
(define (node-to-center node)
  (make-posn (node-x-pos node) (node-y-pos node)))

;;tests
(define-test-suite node-to-center-tests
  (check-equal? (node-to-center node-for-testing) result-for-node-to-center))
(run-tests node-to-center-tests)

;; =============================================================================
;;                NODE-TO-SONS
;; =============================================================================

>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
;; node-to-sons : Node -> ListOfNode
;; GIVEN: a node
;; RETURNS: list of the given nodes
;; EXAMPLE: (node-to-sons node-for-testing) = list-for-node-to-son
;; STRATEGY: Structural Decomposition on n : Node 
(define (node-to-sons node)
  (if (empty? (node-lon node)) empty
      (node-lon node)))
;;tests
(define-test-suite node-to-sons-test
  (check-equal? (node-to-sons node-for-testing) list-for-node-to-sons
                "Should return list of child nodes")
  (check-equal? (node-to-sons empty-nodes-for-testing) empty
                "Should return empty when there is empty list in the node"))
(run-tests node-to-sons-test)

;; =============================================================================
;;                NODE-TO-SELECTED
;; =============================================================================
<<<<<<< HEAD
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b
=======
>>>>>>> 7f330b3436a7ccfbe8e6791e961cc5b1a4d2b16b

;; node-to-selected? : Node -> Boolean
;; GIVEN: a node
;; RETURNS: true iff node is selected else returns false
;; EXAMPLE: (node-to-selected? node-for-testing) = true
;; STRATEGY: Structural Decomposition on n : Node 
(define (node-to-selected? n)
  (cond 
    [(empty? n) false]
    [else (node-selected? n)]))

;tests
(define-test-suite node-to-selected-tests
  (check-equal? (node-to-selected? node-for-testing)
                true "Should return true if node is selected")
  (check-equal? (node-to-selected? empty) false))
(run-tests node-to-selected-tests)




