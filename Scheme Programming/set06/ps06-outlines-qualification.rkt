<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ps06-outlines-qualification) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)

(require "outlines.rkt")

;; this only tests to see if its argument evaluates successfully.
(define (check-provided val)
  (check-true true))

(define-test-suite outlines-tests
  ;; this only tests to see if required functions were provided. 
  ;; This does not test correctness at all.
  (check-provided (flat-rep? 3))

  (check-provided (nested-to-flat
                   '(("The first section"
                      ("A subsection"
                       ("This is a subsection of 1.1")))
                     ("Another section"
                      ("More stuff")
                      ("Still more stuff"))))))



=======
=======
>>>>>>> 4af5497928c2aeadbb599a01734771a2436e5181
=======
>>>>>>> 4af5497928c2aeadbb599a01734771a2436e5181
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ps06-outlines-qualification) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)

(require "outlines.rkt")

;; this only tests to see if its argument evaluates successfully.
(define (check-provided val)
  (check-true true))

(define-test-suite outlines-tests
  ;; this only tests to see if required functions were provided. 
  ;; This does not test correctness at all.
  (check-provided (flat-rep? 3))

  (check-provided (nested-to-flat
                   '(("The first section"
                      ("A subsection"
                       ("This is a subsection of 1.1")))
                     ("Another section"
                      ("More stuff")
                      ("Still more stuff"))))))



<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 4af5497928c2aeadbb599a01734771a2436e5181
=======
>>>>>>> 4af5497928c2aeadbb599a01734771a2436e5181
=======
>>>>>>> 4af5497928c2aeadbb599a01734771a2436e5181
(run-tests outlines-tests)