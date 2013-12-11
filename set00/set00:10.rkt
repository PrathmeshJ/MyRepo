;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(define (compare x y z)
  ( cond 
     [(and (< x y) (< x z)) (+ z y) ]
     [(and (< y x) (< y z)) (+ z x) ]
     [(and (< z x) (< z y)) (+ x y) ]
   )
 )

(compare 14 4 20)
         
         
         