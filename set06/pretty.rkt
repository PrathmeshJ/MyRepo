;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(provide make-sum-exp)
(provide sum-exp-exprs)
(provide make-mult-exp)
(provide mult-exp-exprs)
(provide expr-to-strings)

;; =============================================================================
;;                                CONSTANTS
;; =============================================================================
(define START-SUM-EXP "(+ ")
(define START-MULT-EXP "(* ")
(define EMPTY "")
(define ONE-SPACE " ")
(define GET-NEW-LINE "new")
(define ZERO-WHITE-SPACE 0)
(define ZERO-POST-SPACE 0)

;; =============================================================================
;;                            DATA DEFINITIONS
;; =============================================================================
;; Nat denotes the set of natural numbers (also called the non-negative 
;; integers) 0, 1, 2, etc.
;; *****************************************************************************
;; A LOExpr is a list of expression.
;; A LOExpr is one of
;; -- empty                       (interpretation: empty list)      
;; -- (cons Expr LOExpr)          (interpretation: list of
;;                                 [expression with a list of expressions])
;; Template:
;; loexpr-fn : LOExpr -> ??
;(define (loexpr-fn loe)
;  (cond
;    [(empty? loe) ...]
;    [else (... (first loe)
;               (loexpr-fn (rest loe)))]))
;; *****************************************************************************
;; A LOS i.e. ListOf<String> is a list of string 
;; A LOS is one of
;; -- empty                    (interpretation: empty list of string)      
;; -- (cons Expr LOS)          (interpretation: list of string has one
;;                                              or more strings)
;; Template:
;; los-fn : LOS -> ??
;(define (los-fn loe)
;  (cond
;    [(empty? los) ...]
;    [else (... (first los)
;               (los-fn (rest los)))]))
;; *****************************************************************************
;; A NELOExpr is a non-empty LOExpr, i.e. it will atleast contain one Expr i.e.
;; expression
;; A NELOExpr is 
;;(cons Expr LOExpr) (interp : List of an expression and a LOExpr)

;; Template 1:
;; neloexpr-fn : NELOExpr -> ??
;(define (neloexpr-fn neloe)
;  (... (exp-fn (first neloe))
;       (loexpr-fn (rest neloe))))
;; *****************************************************************************
;; A NELOExpr is either
;; -- (cons Expr empty)    (interp : list of expression)
;; -- (cons Expr NELOExpr) (interp : list of [expression and a non-empty list of
;;                                   expression])

;; Template 2:
;; neloexpr-fn : NELOExpr -> ??
;(define (neloexpr-fn neloe)
;  (cond
;    [(empty? (rest neloe)) ...]
;    [else (... (expr-fn (first neloe))
;               (neloexpr-fn (rest neloe)))]))
;; *****************************************************************************
;; 
(define-struct sum-exp  (exprs))
;; A SumExpr is a (make-sum-exp NELOExpr)
;; it is a sum expression
;; Template : 
;; sum-exp-fn : SumExpr -> ??
;; (define (sum-exp-fn e)
;;  (...(sum-exp-exprs e)))


(define-struct mult-exp (exprs))
;; A MultExpr is a (make-mult-exp NELOExpr)
;; it is a multiplication expression
;; Template : 
;; mult-exp-fn : MultExpr -> ??
;; (define (mult-exp-fn e)
;;  (...(mult-exp-exprs e)))

;; An Expr is one of
;; -- Number                      (interpretation: a number)
;; -- (make-sum-exp NELOExpr)     (interpretation: a sum expression)
;; -- (make-mult-exp NELOExpr)    (interpretation: a multiplication expression)

;; Interpretation: a sum-exp represents a sum and a mult-exp
;; represents a multiplication, and a number is a number. 

;; Template:
;; expr-fn : Expr -> ??
;(define (expr-fn e)
;  (cond
;    [(number? e) ...]     
;    [(sum-exp? e)  (...
;                    (sum-exp-exprs e))]
;    [(mult-exp? e) (...
;                    (mult-exp-exprs e))]))

(define LIST (make-mult-exp
              (list (make-sum-exp (list 20 40 10))
                    40)))

(define LIST-WITH-STRINGS 
  (list "(* (+ 20" "      40" "      10)" "   40)"))

(define LIST-FOR-NO-ROOM-SUM  
  (make-mult-exp (list 
                  (make-sum-exp (list 20 40 10))
                  40 (make-mult-exp (list 20 40 10)))))

(define LIST-FOR-NO-ROOM-MULT
  (make-sum-exp (list 
                 (make-mult-exp (list 20 40 10))
                 40 (make-sum-exp (list 20 40 10)))))

(define LIST-AFTER-LENGTH-VALID
  (list "(* (+ 20 40 10) 40 (* 20 40 10))"))
;; ============================================================================
;;                             expr-to-strings
;; ============================================================================

;; expr-to-strings : Expr Nat -> ListOf<String>
;; GIVEN: An expression and a width, i.e. line width limit
;; RETURNS: A representation of the expression as a sequence of lines, with
;; each line represented as a string of length not greater than the width.
;; Examples:
;; (expr-to-strings (make-sum-exp (list 22 (make-sum-exp (list 23 24)))) 10)
;;                    -> (list "(+ 22" "   (+ 23" "      24))")

;; Strategy: Function Composition 
(define (expr-to-strings e width)
  (get-list-on-new-line EMPTY 
                        (check-expr-to-string ZERO-WHITE-SPACE
                                              ZERO-POST-SPACE width e)))


;; *****************************************************************************
;; get-list-on-new-line : String ListOf<String> -> ListOf<String>
;; GIVEN: A string representing the concatenated list and a ListOf<String>
;; WHERE: initial-concatenated-string is the context parameter that contains
;;        the concatenated string from the previous iteration
;; RETURNS: a list of strings
;; EXAMPLES: (get-list-on-new-line "" (check-expr-to-string 0 0 15 
;;           (make-sum-exp (list 20 30 40 50)))) -> (list "(+ 20 30 40 50)") 
;; STRATEGY: Structural Decomposition on los:[ListOf<String>]
(define (get-list-on-new-line initial-concatenated-string los)
  (cond
    [(empty? los) (cons initial-concatenated-string empty)]
    [else (if (string=? (first los) GET-NEW-LINE)
              ;; if the element is a "new" element cons the previous string
              ;; with the rest of the list
              (cons initial-concatenated-string 
                    (get-list-on-new-line EMPTY (rest los)))
              ;; if element is not a newline char string then append
              ;; this element string to merged context parameter value,
              (get-list-on-new-line 
               (string-append initial-concatenated-string (first los)) 
               (rest los)))]))

;; *****************************************************************************
;; check-expr-to-string : Nat Nat Nat Expr -> ListOf<String>
;; GIVEN : the initial-white-space, post-list-chars, width and an expression
;; WHERE : initial white space is the spaces before start of each entity,
;;         post-list-chars is the space after each expr. Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code
;; RETURNS : a list of strings representing the expression
;; EXAMPLES : (check-expr-to-string 3 2 15 (make-sum-exp (list 20 50)))
;;            -> (list "(+ 20 50)")
;; STARTEGY : STRUCTURAL DECOMPOSTION on e: Expr
(define (check-expr-to-string initial-white-space post-list-chars width e)
  (cond
    [(number? e)  (if-entity-fits? initial-white-space post-list-chars width e)]
    [(sum-exp? e) (check-sum-expr-to-string initial-white-space 
                                            post-list-chars width e)]
    [(mult-exp? e) (check-mult-expr-to-string initial-white-space
                                              post-list-chars width e)]))
;; *****************************************************************************
;; if-entity-fits? : Nat Nat Nat Number -> ListOf<String>
;; GIVEN : the initial-white-space, post-list-chars, width and a number
;; RETURNS : a list of strings of the given number
;; EXAMPLES : (if-entity-fits? 3 2 15 3) -> (list "3")
;;            (if-entity-fits? 3 2 1 32) -> not enough room
;; STARTEGY : DOMAIN KNOWLEDGE
(define (if-entity-fits? initial-white-space post-list-chars width n)
  (if (> (+ (string-length (number->string n))
            initial-white-space post-list-chars) width)
      (error "not enough room")
      (list (number->string n))))
;; *****************************************************************************
;; check-sum-expr-to-string : Nat Nat Nat Expr -> ListOf<String>
;; GIVEN : the initial-white-space, post-list-chars, width and an expression
;; WHERE : initial white space is the spaces before start of each entity,
;;         post-list-chars is the space after each expr. Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code 
;; RETURNS : a list of strings
;; EXAMPLES : (check-sum-expr-to-string 3 2 20 (make-sum-exp (list 20 101 30)))
;;            -> (list "(+ 20 101 30)")
;; STARTEGY : STRUCTURAL DECOMPOSTION on SumExp
(define (check-sum-expr-to-string initial-white-space post-list-chars width e)
  (if (next-line-required? initial-white-space post-list-chars width e)
      (create-new-expr initial-white-space post-list-chars width 
                       (sum-exp-exprs e) true)
      ;; false indicates expression can fit on same line
      (list (expr-to-strings-as-it-is e))))
;; *****************************************************************************
;; check-mult-expr-to-string : Nat Nat Nat Expr -> ListOf<String>
;; GIVEN : the initial-white-space, post-list-chars, width and an expression
;; WHERE : initial white space is the length of spaces before start of each expr,
;;         post-list-chars is the length of space after each expr.
;;         Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code
;; RETURNS : a list of strings
;; EXAMPLES : (check-mult-expr-to-string 3 2 20 (make-mult-exp(list 20 101 30)))
;;             -> (list "(* 20 101 30)")
;; STARTEGY : STRUCTURAL DECOMPOSTION on MultExp
(define (check-mult-expr-to-string initial-white-space post-list-chars width e)
  (if (next-line-required? initial-white-space post-list-chars width e)
      ;; true indicates expression can't fit on same line
      (create-new-expr initial-white-space
                       post-list-chars 
                       width 
                       (mult-exp-exprs e) 
                       false)
      ;; else just print the expression as it is
      (list (expr-to-strings-as-it-is e))))
;; *****************************************************************************
;; create-new-expr : Nat Nat Nat Expr Boolean -> ListOf<String>
;; GIVEN : the whitespace,post characters, limit a non-empty list and a boolean
;; WHERE : initial white space is the length of spaces before start of each expr,
;;         post-list-chars is the length of space after each expr.
;;         Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code
;; RETURNS : a list of strings
;; EXAMPLES : (create-new-expr 3 2 15 (list 29 03 03) false)
;;            ->   (list "(* " "29" "new" "      " "3" "new" "      " "3" ")")
;; STRATEGY : STRUCTURAL DECOMPOSITION of NELOExpr
;; Note:- Using Template 1 of NELOExpr
(define (create-new-expr initial-space post-chars width neloe sum?)
  (append (get-expr-start initial-space post-chars width sum?)
          (check-expr-to-string (+ initial-space 3)
                                post-chars
                                width
                                (first neloe))
          (list GET-NEW-LINE)
          (check-if-empty (+ initial-space 3)
                                          post-chars
                                          width (rest neloe))))

;; *****************************************************************************
;; To calculate if total length of expression to string exceed line-limit
;; next-line-required? : Nat Nat Nat Expr -> Boolean
;; GIVEN : the pre-expr-length, post-list-chars, width within which the string
;;         needs to fit in and an expression
;; RETURNS : true if the string does not fit the width
;;           else false
;; EXAMPLES : (next-line-required? 3 2 15 (make-mult-exp (list 20 101 30)))
;;             -> true
;; STRATEGY : FUNCTION COMPOSITION
(define (next-line-required? pre-expr-length post-list-chars width e)
  (if (> (+ (expression-length pre-expr-length e) post-list-chars) width)
      true
      false))
;; *****************************************************************************

;; check-if-empty : Nat Nat Nat LOE -> LisOf<String>
;; GIVEN : pre-expression length, post list char length, width limit and a list
;;         of expression
;; RETURNS : a list of String
;; EXAMPLES : (check-if-empty 3 2 15 (list 2 3 4))
;;            -> (list "   " "2" "new" "   " "3" "new" "   " "4" ")")
;; STRATEGY : FUNCTION COMPOSITION
(define (check-if-empty init post width loe)
  (if (empty? loe) (list ")")
     (create-new-expr-helper init post width loe)))

(check-equal? (check-if-empty 2 0 10 empty) (list ")")
              "if its an empty list then just the closing ) appears")

;; *****************************************************************************
;; get-expr-start : Nat Nat Nat Boolean -> ListOf<String>
;; GIVEN : the initial-white-space, post-list-chars, width and a boolean
;; RETURNS : A list of strings with the start expression as "(+" or "(*"
;; EXAMPLES : (get-expr-start 3 2 15 true) -> (list "(+ ")
;; STRATEGY : Domain knowledge
(define (get-expr-start initial-white-space post-list-chars width sum?)
  (if (> (+ 3 initial-white-space post-list-chars) width) 
      (error "not enough room")
      (if sum? 
          (list START-SUM-EXP)
          (list START-MULT-EXP))))
;; *****************************************************************************
;; create-new-expr-helper : Nat Nat Nat NELOExpr -> ListOf<String>
;; GIVEN : The initial white-space, the post list characters the allowed limit
;;         width and a non empty list of expression
;; WHERE : initial white space is the length of spaces before start of each expr,
;;         post-list-chars is the length of space after each expr.
;;         Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code
;; RETURNS : A list of strings having the delimiter "new"
;; EXAMPLES : (create-new-expr-helper 3 2 15 (list 201 01 293))
;;             ->  (list "   " "201" "new" "   " "1" "new" "   " "293" ")")
;; STRATEGY : STRUCTURAL DECOMPOSITION OF NELOExpr using second template
(define (create-new-expr-helper initial-white-space post-list-chars width neloe)
  (cond
    [(empty? (rest neloe)) 
     (append (list (create-white-spaces initial-white-space))
             (check-expr-to-string initial-white-space
                                   (+ 1 post-list-chars)
                                   width (first neloe))
             (list ")"))]
    [else 
     (append (list (create-white-spaces initial-white-space)) 
             (check-expr-to-string initial-white-space
                                   post-list-chars
                                   width (first neloe)) 
             (list GET-NEW-LINE)
             (create-new-expr-helper initial-white-space
                                             post-list-chars
                                             width 
                                             (rest neloe)))]))

;; *****************************************************************************
;; To calculate total length of expression to string
;; expression-length : Number Expr ->  Number
;; GIVEN    : the pre-space and an expression
;; WHERE : initial white space is the length of spaces before start of each expr,
;;         post-list-chars is the length of space after each expr.
;;         Both of these are used
;;         context variables which keep a track of the spaces throughout the 
;;         code
;; RETURNS  : the length of the expression
;; EXAMPLES : (expression-length 3 (make-sum-exp (list 10 20 30))) -> 15
;; STRATEGY : STRUCTURAL DECOMPOSITION OF Expr
(define (expression-length pre-wspace-length e)
 (cond
   ;; if its a number
   [(number? e) (+ pre-wspace-length (string-length (number->string e)))]
   ;; if its a addition expression
   [(sum-exp? e) (list-expr-length (+ 3 pre-wspace-length) 
                                   (type-of-expression e true))]
   ;; if its a multiplication expression
   [(mult-exp? e) (list-expr-length (+ 3 pre-wspace-length) 
                                    (type-of-expression e false))]))

;; *****************************************************************************

;; type-of-expression : Expr Boolean -> NELOExpr
;; GIVEN    : An expression and a boolean
;; RETURNS  : a sum-expr if true else a mult-expr
;; EXAMPLES : (type-of-expression (make-sum-exp (list 20 30 40)) true)
;;            -> (list 20 30 40)
;; STRATEGY : Structural Decomposition of SumExpr
(define (type-of-expression e sum-exp?)
  (if sum-exp? 
      (sum-exp-exprs e)
      (call-mult-exp e)))


;; call-mult-exp : MulExpr -> NELOExpr
;; GIVEN : A MultExpr
;; RETURNS : a NELOExpr
;; EXAMPLES : (call-mult-exp (make-mult-exp (list 20 30 40)))-> (list 20 30 40)
;; STRATEGY : Structural Decomposition of MultExpr
(define (call-mult-exp e)
  (mult-exp-exprs e))


;; create-white-spaces : Number -> String
;; GIVEN: the white space length
;; RETURNS: a string of white spaces
;; EXAMPLES:(create-white-spaces 9)-> "         "
;; STRATEGY: Function Composition
(define (create-white-spaces total-length)
  (if (=  0 total-length)
      EMPTY 
      (string-append (create-white-spaces (- total-length 1)) ONE-SPACE)))

;; *****************************************************************************
;; list-expr-length : Nat NELOExpr -> Nat
;; GIVEN : the initial whitespace and anon empty list of expression
;; WHERE : pre-wspace-length is the context used to keep a track of the pre
;;         white spaces
;; RETURNS : the length of the expression
;; EXAMPLES : (list-expr-length 0 (list 20 30 40)) -> 9
;; STRATEGY : STRUCTURAL DECOMPOSITION OF NELOExpr using template which treats
;;            rest as special
(define (list-expr-length pre-wspace-length neloe)
  (cond
    [(empty? (rest neloe))
     (expression-length (+ 1 pre-wspace-length) (first neloe))]
    [else (list-expr-length 
           (expression-length 
            (+ 1 pre-wspace-length) (first neloe))
           (rest neloe))]))

;; *****************************************************************************
;; expr-to-strings-as-it-is : Expr -> String
;; GIVEN    : An Expr 
;; RETURNS  : a string of the expression
;; EXAMPLES : (expr-to-strings-as-it-is 23) -> "23"
;; STRATEGY : STRUCTURAL DECOMPOSITION on Expr

(define (expr-to-strings-as-it-is e)
  (cond
    [(number? e) (number->string e)]
    [(sum-exp? e) (string-append 
                   "(+" (list-to-expr-string-as-it-is 
                         (type-of-expression e true)) ")")]
    [(mult-exp? e) (string-append 
                    "(*" (list-to-expr-string-as-it-is
                          (type-of-expression e false)) ")")]))
;; *****************************************************************************
;; list-to-expr-string-as-it-is : NELOExpr -> String
;; GIVEN    : A NELOExpr
;; RETURNS  : A String
;; EXAMPLES : (list-to-expr-string-as-it-is (list 20 30 40 5)) -> " 20 30 40 5"
;; STRATEGY : STRUCTUAL DECOMPOSITION OF NELOExpr using second template
;;            which treats the second part as special
(define (list-to-expr-string-as-it-is neloe)
  (cond
    [(empty? (rest neloe)) 
     (string-append ONE-SPACE 
                    (expr-to-strings-as-it-is (first neloe)))]
    [else (string-append ONE-SPACE
                         (expr-to-strings-as-it-is (first neloe))
                         (list-to-expr-string-as-it-is (rest neloe)))]))

;; *****************************************************************************
;; =============================================================================
;;                                   TESTS
;; =============================================================================
(define-test-suite pretty-tests
  (check-equal? (expr-to-strings LIST 10) LIST-WITH-STRINGS 
                "Valid list of string with whitespaces")
  
  (check-error (expr-to-strings LIST-FOR-NO-ROOM-SUM 5) "not enough room")
  
  (check-error (expr-to-strings LIST-FOR-NO-ROOM-MULT 5) "not enough room")
  
  (check-equal? (expr-to-strings LIST-FOR-NO-ROOM-SUM  50) 
                LIST-AFTER-LENGTH-VALID
                "List of string if the string satisfies the validity")
  
  (check-equal? (expr-to-strings 
                 (make-mult-exp (list 
                                 (make-sum-exp (list 20 40 10)) 
                                 40 (make-mult-exp (list 20 40 10))))  50)
                (list "(* (+ 20 40 10) 40 (* 20 40 10))")
                "The list of string representing the expression")
  
  (check-equal? (check-sum-expr-to-string 3 2 20 (make-sum-exp 
                                                  (list 10 20 30 )))
                (list "(+ 10 20 30)")
                "the sum expression converted to string")
  
  (check-error (if-entity-fits? 3 2 2 234) "not enough room")
  )
(run-tests pretty-tests)

