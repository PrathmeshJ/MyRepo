;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname snacks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(provide initial-machine
  machine-next-state 
  check-chocolates
  check-carrots
  check-release
  machine-chocolates 
  machine-carrots
  machine-bank)


;; DATA DEFINITION

(define carrot-amount 70)
(define chocolate-amount 175)
(define INITIAL-BANK 0)
(define INITIAL-TRANSACTION-AMOUNT 0)

(define-struct machine (chocolate-bars carrot-packages bank-container current-transaction))

;; A Machine is a 
;; (make-machine Number Numer Number)
;; chocoloate-bars : The no of chocolate bars in the machine
;; carrot-packages : The no of carrot packages in the machine
;; bank : The container in the machine where all the money is
;; current-transaction : Shows the current transaction amount before 
;; adding upto the bank or before returning to user
;; TEMPLATE :
;; machine-fn : machine -> ??
; (define (machine-fn m)
;  (... (machine-chocolate-bars machine)
;       (machine-carrot-packages machine)
;       (machine-bank-container machine)
;       (machine-current-transaction machine)
;  )
; )

;; initial-machine : Number Number -> Machine
;; GIVEN: the number of chocolate bars and the number of packages of
;; carrot sticks
;; RETURNS: a machine loaded with the given number of chocolate bars and
;;          carrot sticks, with an empty bank.
;; EXAMPLES :
;; (initial-machine 200 300) -> make-machine 200 300 
;; (initial-machine 10 50) -> make-machine 10 50 "NORTH"
;; STRATEGY : STRUCTURAL DECOMPOSITION

(define (initial-machine chocolate-bar carrots)
  (make-machine chocolate-bar carrots INITIAL-BANK INITIAL-TRANSACTION-AMOUNT)
  )

; A CustomerInput is one of
;  -- a positive Number interp: insert the specified number of cents
;  -- "chocolate"       interp: request a chocolate bar
;  -- "carrots"         interp: request a package of carrot sticks
;  -- "release"         interp: return all the coins that the customer has put in

; cInput-fn : CInput -> ??
;(define (ci->fn cInput)
;  (cond
;    [(> cInput 0) ...]
;    [(string=? cInput "chocolate") ...]
;    [(string=? cInput "carrots") ...]
;    [(string=? cInput "release") ...]
;    ))
 
;  machine-next-state : Machine CustomerInput -> Machine
;  GIVEN: a machine state and a customer input
;  RETURNS: the state of the machine that should follow the customer's
;  input
;; EXAMPLES :
;; (machine-next-state (make-machine 20 30 0 100) "carrots") -> (make-machine 20 29 70 0) 
;; (machine-next-state (make-machine 20 30 0 200) "chocolates") -> (make-machine 19 30 175 0)
;; (machine-next-state (make-machine 20 30 0 200) "chocolates") -> (make-machine 19 30 175 0)
;; STRATEGY : 


(define (machine-next-state machine customer-input)
  (cond
    [(number? customer-input)  (make-machine (machine-chocolate-bars machine)
                   (machine-carrot-packages machine) (machine-bank-container machine)
                   (+ (machine-current-transaction machine) customer-input))]
    [(string=? customer-input "chocolate") (check-chocolates machine customer-input)]
    [(string=? customer-input "carrots") (check-carrots machine customer-input)]
    [(string=? customer-input "release") (check-release machine customer-input)]
   )
  )
 
;; check-chocolates : Machine CustomerInput -> Machine
;; GIVEN: The machine in a particular state and a
;; Customer Input
;; RETURNS: a loaded machine after having a check on the number of
;; chocolates
;; STRATEGY : STRUCTURAL DECOMPOSITION
(define (check-chocolates machine customer-input)
  (cond
    [(and (> (machine-chocolates machine) 0) (> (machine-current-transaction machine) chocolate-amount)) 
     (make-machine (-(machine-chocolates machine) 1) (machine-carrots machine) (+ (machine-bank machine) chocolate-amount) INITIAL-TRANSACTION-AMOUNT)]
    [else (make-machine (machine-chocolate-bars machine) (machine-carrot-packages machine) (machine-bank-container machine) (machine-current-transaction machine))]
    )
   )

;; check-chocolates : Machine CustomerInput -> Machine
;; GIVEN: The machine in a particular state and a
;; Customer Input
;; RETURNS: a loaded machine after having a check on the number of
;; carrots
;; STRATEGY : STRUCTURAL DECOMPOSITION
(define (check-carrots machine customer-input)
  (cond
    [(and (> (machine-carrots machine) 0) (> (machine-current-transaction machine) carrot-amount)) 
     (make-machine (machine-chocolates machine) (- (machine-carrots machine) 1) (+ (machine-bank-container machine) carrot-amount) INITIAL-TRANSACTION-AMOUNT)]
    [else (make-machine (machine-chocolate-bars machine) (machine-carrot-packages machine) (machine-bank-container machine) (machine-current-transaction machine)) ]
    )
   )
;; check-release : Machine CustomerInput -> Machine
;; GIVEN: The machine in a particular state and a
;; Customer Input
;; RETURNS: Returns the money to the customer and
;; sets the transaction to 0
;; STRATEGY : STRUCTURAL DECOMPOSITION
(define (check-release machine customer-input)
  (cond
    [(string=? customer-input "release") (make-machine (machine-chocolate-bars machine) (machine-carrot-packages machine) (machine-bank machine) 0) ]
    )
   )

;  machine-chocolates : Machine -> Number
;  GIVEN: a machine state
;  RETURNS: the number of chocolate bars left in the machine
;; EXAMPLES :
;; (machine-chocolates 10 12 100 0) ->10 
;; (machine-chocolates 21 12 100 0) -> 21
;; STRATEGY : STRUCTURAL DECOMPOSITION

(define ( machine-chocolates machine)
  ( machine-chocolate-bars machine
   )
  )

;  machine-carrots : Machine -> Number
;  GIVEN: a machine state
;  RETURNS: the number of carrot packages left in the machine
;; EXAMPLES :
;; (machine-carrots 10 12 100 0) -> 12 
;; (machine-carrots 21 21 100 0) -> 21
;; STRATEGY : STRUCTURAL DECOMPOSITION

(define ( machine-carrots machine)
  (machine-carrot-packages machine)
  )

;  machine-bank : Machine -> Number
;  GIVEN: a machine state
;  RETURNS: the number of cents left in the machine's bank
;; EXAMPLES :
;; (machine-bank 10 12 100 0) -> 100 
;; (machine-bank 21 21 0 10) -> 0
;; STRATEGY : STRUCTURAL DECOMPOSITION
(define ( machine-bank machine)
  ( machine-bank-container machine)
  )

;; TESTS

(define-test-suite snacks-vending-tests

(check-equal? (initial-machine 3 6) (initial-machine 3 6))
(check-equal? (machine-next-state (make-machine 13 4 0 0) 10) (make-machine 13 4 0 10))
  (check-equal? (machine-next-state (make-machine 13 4 0 0) 10) (make-machine 13 4 0 10))
  (check-equal? (machine-next-state (make-machine 13 4 0 500) "chocolate") (make-machine 12 4 175 0))
  (check-equal? (machine-next-state (make-machine 13 4 0 500) "carrots") (make-machine 13 3 70 0))
  (check-equal? (machine-next-state (make-machine 12 4 175 500) "release") (make-machine 12 4 175 0))
  (check-equal? (machine-next-state (make-machine 12 0 0 50) "chocolate") (make-machine 12 0 0 50))
  (check-equal? (machine-next-state (make-machine 12 0 0 0) "carrots") (make-machine 12 0 0 0))

)
(run-tests snacks-vending-tests)