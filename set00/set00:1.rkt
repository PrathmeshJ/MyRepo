;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname set00:1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;seconds-leap-year Number ->Number
; GIVEN : A leap year has 366 days
; RETURNS : The no of seconds in a leap year
; EXAMPLE : 
; (seconds-leap-year 366) => 31622400

(define
  (seconds-leap-year d) (* d 24 60 60 1))

( check-expect ( seconds-leap-year 366) 31622400)
"The no of seconds in a leap year are 31622400"