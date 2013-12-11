;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:7) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
 ( * 2 pi)
 ; circumference : Number -> Number
    ; GIVEN: the radius r of a circle 
    ; RETURNS: its circumference, using the formula 2 * pi * r.
    ; Examples:
    ; (circumference 1)  =>  6.283185307179586 
    ; (circumference 0)  =>  0

(define (circumference r)
  (* 2 pi r) )

(check-expect (circumference 1) 6.283185307179586)
"The circumference is 6.283185307179586"

(check-expect (circumference 0) 0)
"The circumference is is 0"
