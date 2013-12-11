;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |3|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require rackunit)
(require racket)
(require rackunit/text-ui)
(require "extras.rkt")



(provide make-diff-exp 
         diff-exp-rand1 
         diff-exp-rand2
         make-mult-exp
         mult-exp-rand1
         mult-exp-rand2
         expr-to-image
         )


(define-struct diff-exp (rand1 rand2))
;; A diff-expr is a (make-diff-expr Number Number)
;; rand1 and rand2 are Numbers,
;; TEMPLATE:
; (define (diff-exp-fn b)
;   (...
;     (diff-exp-rand1 b)
;     (diff-exp-rand2 b)
;    )
;  )

(define-struct mult-exp (rand1 rand2))

;; A mult-exp is a (mult-exp Number Number)
;; rand1 and rand2 are Numbers,
;; TEMPLATE:
; (define (mult-exp-fn b)
;   (...
;     (mult-exp-rand1 b)
;     (mult-exp-rand2 b)
;    )
;  )


;; An Expr is one of
;; -- (make-diff-exp Number Number)
;; -- (make-mult-exp Number Number)
;; Interpretation: a diff-exp represents a difference,
;; and a mult-exp represents a multiplication

(define (expr-to-image e b)
  (cond
    [(mult-exp? e) (mult-image e b)]
    [(diff-exp? e) (diff-image e b)]
   )
  )

;; diff-image : Expr Boolean -> Image
;; GIVEN: Expession and a boolean value
;; RETURNS: image of the expression
;; STRATEGY: Domain Knowledge

(define(diff-image e b)
  (cond
     [(equal? b true)
     (beside (text "(" 11 "black")
             (text (number->string (diff-exp-rand1 e)) 11 "black")
             (text " " 11 "black")
             (text "-" 11 "black")
             (text " " 11 "black")
             (text (number->string (diff-exp-rand2 e)) 11 "black")
             (text ")" 11 "black")
     )]
     
    [(equal? b false)
     (beside (text "(" 11 "black")
             (text "-" 11 "black")
             (text " " 11 "black")
             (text (number->string (diff-exp-rand1 e)) 11 "black")
             (text " " 11 "black")
             (text (number->string (diff-exp-rand2 e)) 11 "black")
             (text ")" 11 "black")
     )]
    )
  )
;; mult-image : Expr Boolean -> Image
;; GIVEN: Expession and a boolean value
;; RETURNS: image of the expression
;; STRATEGY: Domain Knowledge

(define(mult-image e b)
  (cond
    [(equal? b true) 
     (beside (text "(" 11 "black")
             (text (number->string (mult-exp-rand1 e)) 11 "black")
             (text " " 11 "black")
             (text "*" 11 "black")
             (text " " 11 "black")
             (text (number->string (mult-exp-rand2 e)) 11 "black")
             (text ")" 11 "black")
     )]
    
    [(equal? b false)
     (beside (text "(" 11 "black")
             (text "*" 11 "black")
             (text " " 11 "black")
             (text (number->string (mult-exp-rand1 e)) 11 "black")
             (text " " 11 "black")
             (text (number->string (mult-exp-rand2 e)) 11 "black")
             (text ")" 11 "black")
     )]      
   
   )
  )

(define-test-suite expression-image

(check-equal? (expr-to-image (make-mult-exp 33 22) false) (text "(* 33 22)" 11 "black") )
(check-equal? (expr-to-image (make-diff-exp 33 22) false)(text "(- 33 22)" 11 "black") )
(check-equal? (expr-to-image (make-mult-exp 33 22) true)(text "(33 * 22)" 11 "black") )
(check-equal? (expr-to-image (make-diff-exp 33 22) true)(text "(33 - 22)" 11 "black") )
)
  (run-tests expression-image)




