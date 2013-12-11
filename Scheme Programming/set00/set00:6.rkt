;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:6) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
 ; quad : Number Number Number -> Number
    ; GIVEN: Values of constants a b and c
    ; RETURNS: one of the solution of the quadratic equation
    ; Examples:
    ; (quad 1 0 -1)  => 1
    ; (quad -1 0 1)  => -1

(define (quad a b c)
  (/ (- (sqrt (- (* b b) (* 4 a c))) b) 2 a) )

(check-expect (quad 1 0 -1) 1)
"The solution for the quadratic equation is 1"

(check-expect (quad -1 0 1) -1)
"The solution for the quadratic equation is -1"
