;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname regexp) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")

(provide initial-state
         check-key-event-length
         next-state
         accepting-state?
         error-state?
         )
         
; DATA DEFINITION
; A State is one of the
; -- START       : Starting state of the machine
; -- S1          : State S1 of the machine
; -- S2          : State S2 of the machine
; -- S3          : State S3 of the machine
; -- ERROR       : The Error State 

; TEMPLATE
; state-fn : State ->??
; (define( state-fn state)
;  (cond
;    [(string=? state "START") ...]
;    [(string=? state "S1") ...]
;    [(string=? state "S2") ...]
;    [(string=? state "S3") ...]
;    [(string=?) state "ERROR" ...]
;   )
;  )

(define S1 "S1")
(define S2 "S2")
(define S3 "S3")
(define START "START")
(define ERROR "ERROR")


; initial-state : Number -> State
; GIVEN: a number
; RETURNS: a representation of the initial state
; of your machine.  The given number is ignored.
; EXAMPLES : (initial-state 100) -> START
; STRATEGY : STRUCTURAL DECOMPOSITION OF State

(define (initial-state num)
  START
  )
(initial-state 1)

; check-key-event-length : MyKeyEvent -> Boolean
; GIVEN: a KeyEvent of the user
; RETURNS: true if string length is =1 and
; returns false if greater
; EXAMPLES :
; (check-key-event-length "a") -> true
; (check-key-event-length "b1212") -> false
;  STRATEGY :STRUCTURAL DECOMPOSITION OF MyKeyEvent

(define (check-key-event-length key-event)
  (cond
    [(= (string-length key-event) 1) true]
    [else false]
    )
  )

; next-state : State MyKeyEvent -> State
; GIVEN: a state of the machine
; RETURNS: the state that should follow the given key event.  A key
; event that is to be discarded should leave the state unchanged.
; EXAMPLES :
; (next-state START "a") -> S1
; (next-state START "b") -> S1
; (next-state START "c") -> S2
; (next-state S1 "a") -> S1
; (next-state S1 "b") -> S1
; (next-state S1 "c") -> S2
; (next-state S1 "z") -> ERROR
;  STRATEGY :STRUCTURAL DECOMPOSITION OF State AND MyKeyEvent

(define (next-state state key-event)
  (cond
    [(string=? state START) (state-START key-event)]
    [(string=? state S1) (state-S1 key-event)]
    [(string=? state S2) (state-S2 key-event)]

    )
  )

;state-START : MyKeyEvent -> State
;GIVEN: A key event
;RETURNS: The actual state after giving input as the key event to the START state
; EXAMPLE : (state-START "a")-> S1
; STRATEGY : Functional Composition
(define (state-START key-event)
  (cond
    [(not  (check-key-event-length key-event)) START]
    [(and  (check-key-event-length key-event) (string=? key-event "a")) S1]
    [(and  (check-key-event-length key-event) (string=? key-event "b")) S1]
    [(and  (check-key-event-length key-event) (string=? key-event "c")) S2]
    [else ERROR]
    )
  )

;state-START : MyKeyEvent -> State
;GIVEN: A key event
;RETURNS: The actual state after giving input as the key event to the state S1
; EXAMPLE : (state-S1 "a")-> S1
; STRATEGY : Functional Composition
(define (state-S1 key-event)
  (cond
    [(not (check-key-event-length key-event)) S1]
    [(and (check-key-event-length key-event)  (string=? key-event "a")) S1]
    [(and (check-key-event-length key-event)  (string=? key-event "b")) S1]
    [(and (check-key-event-length key-event)  (string=? key-event "c")) S2]
    [else ERROR]
    )
  )

;state-START : MyKeyEvent -> State
;GIVEN: A key event
;RETURNS: The actual state after giving input as the key event to the state S1
; EXAMPLE : (state-S2 "c")-> S3
; STRATEGY : Functional Composition
(define (state-S2 key-event)
  (cond
    [(not (check-key-event-length key-event)) S2]
    [(and (check-key-event-length key-event)  (string=? key-event "d")) S2]
    [(and (check-key-event-length key-event)  (string=? key-event "e")) S3]
    [else ERROR]
    )
  )
;accepting-state? : State -> Boolean
;GIVEN: a state of the machine
;RETURNS: true iff the given state is a final (accepting) state
; EXAMPLE : (accepting-state? START)-> true1
; STRATEGY : DOMAIN KNOWLEDGE
(define (accepting-state? state)
  (cond
    [(string=? state S3) true]
    [else false]
    )
  )

;error-state? : State -> Boolean
;GIVEN: a state of the machine
;RETURNS: true iff the string seen so far does not match the specified
;regular expression and cannot possibly be extended to do so.
; STRATEGY : DOMAIN KNOWLEDGE
(define (error-state? state)
  (cond
    [(string=? state ERROR) true]
    [else false]
    )
  )

;; TESTS

(define-test-suite regular-expression
  (check-equal? (error-state? ERROR) true "This is not the ERROR state")
  (check-equal? (error-state? S2) false "This is not the ERROR state")
  
  (check-equal? (accepting-state? S3) true "This is not the ERROR state")
  (check-equal? (accepting-state? S2) false "This is not the ERROR state")
  
  (check-equal? (next-state START "a") S1 "This is not the ERROR state")
  (check-equal? (next-state START "b") S1 "This is not the ERROR state")
  (check-equal? (next-state START "c") S2 "This is not the ERROR state")
  (check-equal? (next-state START "cadd") START "This is not the ERROR state")
  (check-equal? (next-state START "e") ERROR "This is not the ERROR state")
  
  (check-equal? (next-state S1 "a") S1 "This is not the ERROR state")
  (check-equal? (next-state S1 "b") S1 "This is not the ERROR state")
  (check-equal? (next-state S1 "c") S2 "This is not the ERROR state")
  (check-equal? (next-state S1 "casd") S1 "This is not the ERROR state")
  (check-equal? (next-state S1 "d") ERROR "This is not the ERROR state")
  
  
  (check-equal? (next-state S2 "a") ERROR "This is not the ERROR state")
  (check-equal? (next-state S2 "b") ERROR "This is not the ERROR state")
  (check-equal? (next-state S2 "c") ERROR "This is not the ERROR state")
  (check-equal? (next-state S2 "d") S2 "This is not the ERROR state")
  (check-equal? (next-state S2 "e") S3 "This is not the ERROR state")
  (check-equal? (next-state S2 "eda") S2 "This is not the ERROR state")
  
  
  )
(run-tests regular-expression)
                    
