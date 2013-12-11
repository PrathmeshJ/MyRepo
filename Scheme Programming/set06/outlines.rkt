;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname outlines) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")
(provide flat-rep?
         nested-to-flat)


;;An Sexp is one of the following
;;-- a String      [interp: maybe string]
;;-- a Nat         [interp: maybe natural number which is a integer
;;                 and greated than 1]
;;-- a ListOfSexp  [interp: maybe list of sexp]

;;template
;;sexp-fn : Sexp -> ??
;(define (sexp-fn s)
;  (cond
;    [(string? s)...]
;    [(number? s)...]
;    [else (...(los-fn s))]))


;;A ListOfSexp(LOSX) is one of
;;-- empty                  [interpret : list with no sexp]
;;-- (cons Sexp ListOfSexp) [interpret : a sexp and list of sexp]

;;template
;;losx-fn : LOSX -> ??
;;(define (losx-fn l)
;;  (cond
;;    [(empty? l) ...]
;;    [else (... (sex-fn (first l))
;;               (losx-fn (rest l))...)]))


;;A Section is either a
;;-- String        [interp: string in a section]
;;-- ListOfSection [interp: it is list of sections]

;;section-fn : Section -> ??
;;template
;(define (section-fn sec)
;  (cond 
;    [(string? sec) ...]
;    [else (... (los-fn sec))]))

;;A ListOfSection(LOS) is either of
;;-- empty                        [interp : empty list]
;;-- (cons Section ListOfSection) [interp : a section and LOS]

;;template
;;los-fn : LOS -> ??
;;(define (los-fn l)
;;  (cond
;;    [(empty? l) ...]
;;    [else (... (section-fn (first l))
;;               (los-fn (rest l))...)]))

;;NestedRep is a ListOfSection(LOS) where a section 
;;contains a string and a list of subsection

;;A ListOfNumber(LON) is one of 
;;--empty            [interp : empty list of numbers]
;;--LON              [interp : maybe list of numbers]

;;template
;;lon-fn : LON -> ??
;;(define (lon-fn ln)
;;  (cond
;;    [(empty? ln) ...]
;;    [else (lon-fn ln)...]))

;;A ListOfNaturalNumbers(LONN) is one of 
;;--empty             [interp : empty list of numbers]
;;--LONN              [interp : maybe list of natural numbers]

;;template
;;lonn-fn : LONN -> ??
;;(define (lonn-fn ln)
;;  (cond
;;    [(empty? ln) ...]
;;    [else (lonn-fn ln)...]))

;;An Element is one of
;;-- (cons LONN String)           [interp: List of LONN and String]
;;-- ListOfElements               [interp: maybe list of elements]

;;template 
;;element-fn : Element -> ??
;;(define (element-fn e)
;;  (cond
;;    [string? s]
;;    [else (... (loe-fn e))]))
;;
;;A ListOfElements(LOE) is one of
;;-- empty                       [interp: list is empty]
;;--(cons Element ListOfElements [interp: element or LOE]
;;
;;template
;;loe-fn : LOE->??
;;(define (loe-fn l)
;;  (cond
;;    [(empty? l)...]
;;    [else(... (element-fn (first l))
;;              (loe-fn(rest l)))]))

;;A FlatRep is a ListOfElements where element is a natural number and string
     
;;Examples for testing
(define nested-rep-example 
  (list(list "The first section"
             (list "A subsection with no subsections")
             (list "Another subsection"
                   (list "This is a subsection of 1.2")
                   (list "This is another subsection of 1.2"))
             (list "The last subsection of 1"))
       (list "Another section"
             (list "More stuff")
             (list "Still more stuff"))))

(define flat-rep-example 
  (list
   (list (list 1) "The first section")
   (list
    (list 1 1)
    "A subsection with no subsections")
   (list (list 1 2) "Another subsection")
   (list
    (list 1 2 1)
    "This is a subsection of 1.2")
   (list
    (list 1 2 2)
    "This is another subsection of 1.2")
   (list (list 1 3) "The last subsection of 1")
   (list (list 2) "Another section")
   (list (list 2 1) "More stuff")
   (list (list 2 2) "Still more stuff")))

(define example-flat-rep-fail 
   (list
   (list (list 1) "The first section")
   (list
    (list "")
    "A subsection with no subsections")
   (list (list 1 2) "Another subsection")
   (list
    (list 1 2 1)
    "This is a subsection of 1.2")
   (list
    (list 1 2 2)
    "This is another subsection of 1.2")
   (list (list 1 3) "The last subsection of 1")
   (list (list 2) "Another section")
   (list (list 2 1) "More stuff")
   (list (list 2 2) "Still more stuff")))

;;flat-rep? : Sexp -> Boolean
;;GIVEN: An Sexp
;;RETURNS: true iff it is the flat representation of some outline
;;EXAMPLES:(flat-rep? flat-rep-example) = true
;;STRATEGY:Function composition

(define (flat-rep? sexp)
  (if (cons? sexp)
      (check-if-list sexp)
      false))

;check-if-list : Sexp -> Boolean
;GIVEN: an sexp
;RETURN: true if it is flat-rep
;EXAMPLE: (check-if-list flat-rep-example) = true
;STRATEGY: Structural Decomposition on Sexp
(define (check-if-list sexp)
  (cond
    [(empty? sexp) true]
    [else (if (flat-rep-helper (first sexp))
                (check-if-list (rest sexp))
          false)]))

;flat-rep-helper : Sexp -> Boolean
;GIVEN: an sexp
;RETURN: true if it is flat-rep
;EXAMPLE: (flat-rep-helper flat-rep-example) = true
;STRATEGY: Function Composition
(define (flat-rep-helper sexp)
  (cond
    [(empty? sexp) false]
    [else (if (and (= (length sexp) 2)
                    (check-nat (first sexp))
                    (check-if-string? (second sexp)))
          true
          false)]))

;check-nat : LONN -> Boolean
;GIVEN: a list
;RETURN: true if it has all values as numbers
;EXAMPLE: (check-nat (list 1 2 )) = true
;STRATEGY:Function Composition

(define (check-nat lon)
  (cond
    [(empty? lon) false]
    [else (if (cons? lon)
              (check-if-no lon)
              (if(and (number? lon) (> lon 0))
                 true
                 false))]))

;check-if-no : LON -> Number
;GIVEN: a list
;RETURN: first number
;EXAMPLE: (check-if-no (list 1)) = 1
;STRATEGY: Function Composition
(define (check-if-no lon) 
   (check-nat (first lon))) 
      
;check-if-string? : Sexp -> Boolean
;GIVEN: a sexp
;RETURN: a true if it is a string
;EXAMPLE:(check-if-string flat-rep-example) = true
;STRATEGY: Function Composition     
(define (check-if-string? s)
  (if (cons? s)
      (flat-rep-helper s)
      (if (string? s)
          true
          false))) 

(define-test-suite flat-rep?-tests
  (check-equal? (flat-rep? flat-rep-example) true)
  (check-equal? (flat-rep? example-flat-rep-fail) false))
(check-equal? (check-if-string? 20) false "Not a String")
(check-equal? (check-if-string? (list 20 "abc")) true 
              "checking if the list contains a string or nor")
(check-equal? (check-nat empty) false "Empty-nat")
(check-equal? (flat-rep-helper empty) false "Empty list")
(check-equal? (flat-rep? 90) false "Not a flat Rep")
(run-tests flat-rep?-tests)

;nested-to-flat : NestedRep -> FlatRep
;GIVEN: the representation of an outline as a nested list
;RETURNS: the flat representation of the outline
;EXAMPLE: (nested-to-flat nested-rep-example) = flat-rep-example
;STRATEGY: Function Composition 

(define (nested-to-flat l)
  (decompose-list l (list 1)))

;decompose-list : NestedRep ListOfNumbers -> FlatRep
;GIVEN:a nested representation of list and list of numbers initialized to 1
;RETURNS:a flat representation of a list
;EXAMPLE: (decompose-list nested-rep-example (list 1))
;= (list
; (list (list 1) "The first section")
; (list
;  (list 1 1)
;  "A subsection with no subsections")
; (list (list 1 2) "Another subsection")
; (list
;  (list 1 2 1)
;  "This is a subsection of 1.2")
; (list
;  (list 1 2 2)
;  "This is another subsection of 1.2")
; (list (list 1 3) "The last subsection of 1")
; (list (list 2) "Another section")
; (list (list 2 1) "More stuff")
; (list (list 2 2) "Still more stuff"))
;STRATEGY: Structural Decomposition on NestedRep

(define (decompose-list l n)
  (cond
    [(empty? l) empty]  
    [else (append (update-list (first l) n)
                  (decompose-list (rest l) (new-list-of-numbers n)))]))

;update-list : NestedList ListOfNumbers -> FlatRep
;GIVEN: a nested-list and lon
;RETURNS: flat-rep
;EXAMPLE: (update-list nested-rep-example (list 1))=
;(list
; (list
;  (list 1)
;  (list
;   "The first section"
;   (list "A subsection with no subsections")
;   (list
;    "Another subsection"
;    (list "This is a subsection of 1.2")
;    (list
;     "This is another subsection of 1.2"))
;   (list "The last subsection of 1")))
; (list (list 1 1) "Another section")
; (list (list 1 1 1) "More stuff")
; (list (list 1 1 2) "Still more stuff"))
;STRATEGY: Structural Decomposition on NestedRep
(define (update-list s n)
  (cond
    [(empty? (rest s)) (list (list n (first s)))]
    [else
     (append (list (list n (first s))) 
             (decompose-list (rest s) (append n (list 1))))]))

;new-list-of-numbers : ListOfNumber -> ListOfNumber
;GIVEN: a list of number
;RETURNS: an updated list of number
;EXAMPLE: (new-list-of-numbers (list 1 2 3))
;= (list 1 2 4)
;STRATEGY: Structural Decomposition on LON
(define (new-list-of-numbers n)
  (cond
    [(empty? (rest n)) (list (+ 1 (first n)))]
    [else 
     (cons (first n)
           (new-list-of-numbers (rest n)))]))


;tests
(define-test-suite nested-to-flat-tests
  (check-equal? (nested-to-flat nested-rep-example) flat-rep-example 
                "converts nested-rep to flat-rep"))

(run-tests nested-to-flat-tests)


     
     

