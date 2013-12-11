;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:8) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
; circ-area : Number -> Number
; Given : The radius of the circle
; Returns : The Area of the circle
; Examples :
; (circ-area 1) => 3.1415
;(circ-area 5) => 78.5375
;(circ-area 7) => 153.9335
(define (circ-area r) (* 3.1415 r r))

(check-expect (circ-area 1) 3.1415 )
"The area of circle is 3.1415"

(check-expect (circ-area 5) 78.5375 )
"The area of circle is 78.5375"

(check-expect (circ-area 7) 153.9335 )
"The area of circle is 153.9335"
