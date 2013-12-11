;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:9) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
; even-? : Number -> Boolean
    ; GIVEN: A number
    ; RETURNS: Whether the number is even or not
    ; Examples:
    ; (even-? 4)  => true
    ; (even-? 3)  => false

(define (even-? x) 
  (cond
    [ (= (remainder x 2) 0 ) true]
    [ else false]))

(even-? 4)
(even-? 3)