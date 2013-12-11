;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
 ; tip : Number Number -> Number
    ; GIVEN: the amount of the bill in dollars and the
    ; percentage of tip
    ; RETURNS: the amount of the tip in dollars.
    ; Examples:
    ; (tip 10 0.15)  => 1.5
    ; (tip 20 0.17)  => 3.4

(define (tip x y)
  (* x y ))

(check-expect (tip 10 0.15) 1.5)
"Bill of 10 and percentage tip 0.15 should give tip as 1.5"

(check-expect (tip 20 0.17) 3.4)
"Bill of 20 and percentage tip 0.17 should give tip as 3.4"
