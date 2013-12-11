;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname inventory) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require rackunit/text-ui)
(require "extras.rkt")



(provide inventory-potential-profit)
(provide inventory-total-volume)
(provide price-for-line-item)
(provide fillable-now?)
(provide days-til-fillable)
(provide price-for-order)
(provide inventory-after-order)
(provide increase-prices)
(provide reorder-present?)
(provide make-empty-reorder)
(provide make-reorder)
(provide make-book)
(provide make-line-item)


(define-struct book (isbn title author publisher unit-price unit-cost number-of-copies re-order-status cuft))
;; A Book is a 
;;  (make-book Number String String String Number Number Number "Re-oder status" Number)
;; Interpretation:
;; isbn, a number (the "international standard book number"). This serves as a unique identifier for this book.
;; title, a string
;; author, a string
;; publisher, a string
;; unit price: a number, the price at which we will sell the book
;; unit cost: a number, the cost of the book to the bookstore
;; number of copies on hand
;; re-order status. Our bookstore periodically reorders books from the publisher. 
;; For each book, there is at most one outstanding reorder. If there is no reorder,
;; the reorder status must represent this information. If there is a reorder,
;; the re-order status contains the number of days until the the next shipment 
;; of this book is expected to arrive, and the number of copies expected to
;; arrive at that time. Both of these are positive integers.
;; cuft: the volume taken up by one unit of this item, in cubic feet.

;; book-fn : Book -> ??
;; (define (book-fn b)
;;   (... (book-isbn b) (book-title b) (book-author b) (book-publisher b)
;;        (book-unit-price) (book-unit-cost b) (book-number-of-copies b)
;;        (book-reorder-status b) (book-cuft b)))

;; A ListOfBooks (LOB) is either
;; --empty
;; --(cons (cons Book LOB)

;; TEMPLATE :
;; lob-fn : LOB -> ??
;; (define( lob-fn lob)
;;   (cond
;;     [(empty? lob) ...]
;;     [else (...
;;               (first lob)
;;               (lob-fn (rest lob)))]))

;; An Inventory is a list of ListOfBooks that the bookstore has, in any order
;; where there are no duplicate books, an isbn number has one or more number of
;; books

;; An Inventory is either
;; --empty                      (Interp : No of books)
;; --(cons (cons Inventory LOB) (Interp : Inventory has one or more no. of books)

;; TEMPLATE :
;; inventory-fn : Inventory -> ??
;; (define( inventory-fn inv)
;;   (cond
;;     [(empty? inv) ...]
;;     [else (...
;;               (first inv)
;;               (lob-fn (rest inv)))]))

(define-struct line-item (isbn quantity-ordered))
;; A ListOfLineItem (ListOf<LineItem>)is one of
;; -- empty                            :(interp : Empty List)
;; -- (cons LineItem ListOf<LineItem>) :(interp : list if one or more line items

;; line-item-fn : ListOf<LineItem> -> ??
;; (define( line-item-fn li)
;;   (cond
;;     [(empty? li) ...]
;;     [else (...
;;               (first li)
;;               (line-item-fn (rest li)))]))

;; An Order is a list of ListOfLineItems
;; 
;; --empty                : (interp : empty order)
;; --(cons LineItem Order): (interp : list of line-items)

;; TEMPLATE
;; order-fn : Order -> ??
;; (define( order-fn order)
;;   (cond
;;     [(empty? order) ...]
;;     [else (...
;;               (first order)
;;               (order-fn (rest order)))]))

;; A MaybeNumber is one of:
;; -- false   (interp : boolean value)
;; -- Number  (interp : number)

;; TEMPLATE :
;; maybenumber-fn : MayBeNumber -> ??
;; (define (maybenumber-fn mbn)
;;   (cond
;;     [(number? mbn) ...]
;;     {(false? mbn) ...]))

(define-struct reorder (days copies))
;; A reorderStatus is one of
;; --  false                        interp: no reorder has been made
;; -- (make-reorder PosInt PosInt)  interp : days is the number of days
;;                                  for theorder to process and copies is 
;;                                  the no. of copies in the order

;;Template
;; rs-fn : rs ->??
;  (define (rs-fn rs)
;    (cond
;      [(false? rs)...]
;      [else (...
;             (reorder-days rs)
;             (reorder-copies rs))]))

;; EXMAMPLES FOR TESTING
(define lob1
  (list
   (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 20 false 50)
   (make-book 12313 "Wand" "EFG" "HtDP/1" 122 221 20 false 40)
   (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 20 false 50)
   (make-book 64433 "Felleisen" "WHAT" "HtDP/1" 100 120 20 false 50)
   (make-book 22243 "Shakespeare" "Macbeth" "HtDP/1" 100 120 20 false 50)))

(define lob-changed
  (list
   (make-book 12345 "Felleisen" "ABC" "HtDP/1" 110 120 20 false 50)
   (make-book 12313 "Wand" "EFG" "HtDP/1" 134.2 221 20 false 40)
   (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 20 false 50)
   (make-book 64433 "Felleisen" "WHAT" "HtDP/1" 110 120 20 false 50)
   (make-book 22243 "Shakespeare" "Macbeth" "HtDP/1" 110 120 20 false 50)))

(define inventory
  (list
   (make-book 12345 "Felleisen" "ABC" "HtDP/1" 110 120 20 (make-reorder 10 30) 50)
   (make-book 12313 "Wand" "EFG" "HtDP/1" 134.2 221 20 (make-reorder 20 20) 3)
   (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 20 false 50)
   (make-book 64433 "Felleisen" "WHAT" "HtDP/1" 110 120 20 false 50)
   (make-book 22243 "Shakespeare" "Macbeth" "HtDP/1" 110 120 20 false 50)))

(define list-of-line-item
  (list
   (make-line-item 12345 10)
   (make-line-item 12313 5)
   (make-line-item 34534 10)
   (make-line-item 22243 2)))


(define  order1
  (list
   (make-line-item 12345 10)
   (make-line-item 12313 10)
   (make-line-item 34534 10)
   (make-line-item 00009 10)))

(define  order2
  (list
   (make-line-item 12345 100)
   (make-line-item 12313 100)
   (make-line-item 34534 10)
   (make-line-item 00009 10)))

(define  order3
  (list
   (make-line-item 12345 50)
   (make-line-item 12313 40)
   (make-line-item 34534 10)))

(define empty-ordr
  empty)


;; =============================================================================
;;                          inventory-potential-profit
;; =============================================================================

;; check-book-profit : Book ->  Number
;; GIVEN: a Book
;; RETURNS: the total profit for all the books in stock (i.e., how much
;; the bookstore would profit if it sold every book in the inventory).
;; EXAMPLES : 
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define(check-book-profit b)
  (* (- (book-unit-cost b) (book-unit-price b)) (book-number-of-copies b)))

;; inventory-potential-profit : Inventory ->  Number
;; GIVEN: an inventory
;; RETURNS: the total profit for all the items in stock (i.e., how much
;; the bookstore would profit if it sold every book in the inventory).
;; EXAMPLES : (inventory-potential-profit (inventory-potential-profit lob1))
;;            -> 3580
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define(inventory-potential-profit inv)
  (cond
    [(empty? inv) 0]
    [else (+ (check-book-profit (first inv))
             (inventory-potential-profit (rest inv)))]))

;; =============================================================================
;;                          inventory-total-volume
;; =============================================================================

;; check-book-volume : Book -> Number
;; GIVEN : A Book
;; RETURNS : The volume taken up by the total number of books
;; EXAMPLES : (check-book-volume (make-book 12345 "Felleisen" "ABC" "HtDP/1"
;;                                  110 120 20 (make-reorder 10 30) 50) -> 1000
;; STRUCTURAL DECOMPOSITION of Book
(define(check-book-volume b)
  (* (book-number-of-copies b) (book-cuft b)))

;; inventory-total-volume : Inventory -> Number
;; GIVEN : an Inventory
;; RETURNS: the total volume needed to store all the books in stock.
;; EXAMPLES : (inventory-total-volume lob1) -> 4800
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define (inventory-total-volume inv)
  (cond
    [(empty? inv) 0]
    [else (+ (check-book-volume (first inv))
             (inventory-total-volume (rest inv)))]))

;; =============================================================================
;;                              price-for-line-item
;; =============================================================================

;; price-for-line-item : Inventory LineItem -> MaybeNumber
;; GIVEN: an inventory and a line item
;; RETURNS: the price for that line item (the quantity times the unit
;; price for that item).  Returns false if that isbn does not exist in
;; the inventory. 
;; EXAMPLES : (price-for-line-item lob1 (make-line-item 12313 10 ) -> 1220
;; STRATEGY : STRUCTURAL DECOMPOSITION of LineItem
(define (price-for-line-item inv li)
  (check-line-item-isbn inv (line-item-isbn li) (line-item-quantity-ordered li)))

;; check-line-item-isbn : Inventory Number Number
;; GIVEN : an Inventory, a isbn and quantity of the books
;; RETURNS : false if inventory is empty
;; else returns ture if the isbn matches the provided isbn
;; EXAMPLES : (check-line-item-isbn lob1 00092 10) -> false
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define(check-line-item-isbn ivn isbn quantity)
  (cond
    [(empty? ivn) false]
    [else (if (check-inventory-isbn (first ivn) isbn)
              (calculate-total-price (first ivn) quantity)
              (check-line-item-isbn (rest ivn) isbn quantity))]))

;; check-inventory-isbn : Book Number -> Boolean
;; GIVEN : A Book and an isbn number
;; RETURNS : True if the isbn number matches the one in the inventory
;; else false 
;; EXAMPLES : (check-inventory-isbn (make-book 34534 "Shakespeare" "Hamlet" 
;;                                   "Pearson" 100 120 20 false 50) 00992)
;;             -> false
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define (check-inventory-isbn b isbn)
  (if (= (book-isbn b) isbn) true false))

;; calculate-total-price : Book Number -> Number
;; GIVEN : A Book and the quantity
;; RETURNS : The total price of the given number of books
;; EXAMPLES : (calculate-total-price (make-book 34534 "Shakespeare" "Hamlet" 
;;                                   "Pearson" 100 120 20 false 50) 10)
;;             -> 1000
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define (calculate-total-price b quantity)
  (* (book-unit-price b) quantity))

;; =============================================================================
;;                               fillable-now?
;; =============================================================================

;; fillable-now? : Order Inventory -> Boolean.
;; GIVEN: an order and an inventory
;; RETURNS: true iff there are enough copies of each book on hand to fill
;; the order.  If the order contains a book that is not in the inventory,
;; then the order is not fillable.
;; EXAMPLES : (fillable-now? order1 lob1 ) -> true
;;            (fillable-now? empty-ordr lob1 ) -> false
;; STRATEGY : STRUCTURAL DECOMPOSITION of Order
(define (fillable-now? order inv)
  (cond
    [(empty? order) true]
    [else (if (check-books-in-order (first order) inv)
              (fillable-now? (rest order) inv)
              false)]))

;; check-books-in-order : Line-Item Inventory -> Boolean.
;; GIVEN: A Line-Item and an inventory
;; RETURNS: true iff there are enough copies of the book on hand to fill
;; the line-item.  If the line-item contains a book that is not in the inventory,
;; then returns false.
;; EXAMPLES : (check-books-in-order (make-line-item 12345 10) lob1)-> true
;; STRATEGY : STRUCTURAL DECOMPOSITION of Line-Item
(define( check-books-in-order li inv)
  (check-book-list? (line-item-isbn li) (line-item-quantity-ordered li) inv))

;; check-book-list? : Number Number -> Boolean.
;; GIVEN: an order and an inventory
;; RETURNS: true iff the book has a matching isbn in the inventory.  
;; If the inventory is empty, then returns false.
;; EXAMPLES : (check-book-list? 12345 10 lob1) -> true
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define(check-book-list? isbn quantity inv)
  (cond
    [(empty? inv) false]
    [else (if (check-book-in-inventory isbn quantity (first inv)) true
              (check-book-list? isbn quantity (rest inv)))]))

;; check-book-in-inventory : Number Number Book -> Boolean.
;; GIVEN: An Isbn numer, quantity of books and a Book
;; RETURNS: true if the isbn matches the book's isbn and the quantity is greater
;; or qual to the numbet of copies in the inventory else returns false.
;; then returns false.
;; EXAMPLES : (check-book-in-inventory 12345 5 (make-book 12345 
;;                      "Felleisen" "ABC" "HtDP/1" 110 120 20 false 50)) -> true
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define (check-book-in-inventory isbn quantity b)
  (if (and (= isbn (book-isbn b)) (<= quantity (book-number-of-copies b)))
      true false))
;; =============================================================================
;;                               days-til-fillable
;; =============================================================================

;; days-til-fillable : Order Inventory -> MaybeNumber
;; GIVEN: an order and an inventory
;; RETURNS: the number of days until the order is fillable, assuming all
;; the shipments come in on time.  Returns false if there won't be enough
;; copies of some book, even after the next shipment of that book comes
;; in.
;; EXAMPLES: if the order contains one book that is out of stock, with a
;; reorder status showing 2 days until delivery, then the order is
;; refillable in 2 days.  If the order is for 10 copies of the book, and
;; the next order consists of only 5 books, then should return false.
;; STRATEGY : STRUCTURAL DECOMPOSITION of Order
(define (days-til-fillable order inv)
  (cond
    [(empty? order) 0]
    [else (check-if-number-or-false
           (fillable-check-books-in-order (first order) inv)
           (days-til-fillable (rest order) inv))]))


;; check-if-number-or-false : MayBeNumber MayBeNumber -> MayBeNumber
;; GIVEN : two arguments which are of type MayBeNumber
;; RETURNS : False if any one is a Boolean else returns the 
;;           maximum of the teo numbers
;; EXAMPLES : (check-if-number-or-false false 10) -> false
;;            (check-if-number-or-false 20 10) -> 20
;; STRATEGY : Domain Knowledge
(define (check-if-number-or-false arg1 arg2)
  (if (or (boolean? arg1) (boolean? arg2)) false
      (max arg1 arg2)))

;; fillable-check-books-in-order : Line-Item Inventory -> MaybeNumber
;; GIVEN : Line order and an Inventory
;; RETURNS : Returns false if inventory is empty, 0 if the 
;;           book copies is greater than the quantity ordered
;;           else returns the days left for the order to come
;; EXAMPLES : (fillable-check-books-in-order (make-line-item 10 20) inventory)
;;            -> 0
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define (fillable-check-books-in-order li inv)
  (fillable-check-book-list? (line-item-isbn li) (line-item-quantity-ordered li) inv))

;; fillable-check-book-list? Number Number Inventory -> MayBeNumber
;; GIVEN : isbn quantity and an Inventory
;; RETURNS : a maybenumber
;; EXAMPLES : (fillable-check-book-list? 12345 10 lob1) -> 0
;; STRATEGY : STRUCTURAL DeCOMPOSITION of Inventory
(define (fillable-check-book-list? isbn quantity inv)
  (cond
    [(empty? inv) false]
    [else (if (return-maybe-number (fillable-check-book-in-inventory isbn quantity (first inv)))
              (fillable-check-book-in-inventory isbn quantity (first inv))
              (fillable-check-book-list? isbn quantity (rest inv)))]))

;; return-maybe-number : MayBeNumber -> Boolean
;; GIVEN : an argument which is of type MayBeNumber
;; RETURNS : true if it is a Number else returns the false
;; EXAMPLES : (return-maybe-number 10) -> true
;;            (return-maybe-number false) -> false
;; STRATEGY : Domain Knowledge
(define (return-maybe-number arg)
  (if (number? arg)
      true
      false))

;; fillable-check-book-in-inventory : Number Number Book -> MayBeNumber
;; GIVEN : An ISBN , quantity of books and a Book
;; RETURNS : 0 if no of copies of the book is greater than quantity in order
;;           else no of days
;;           and false if the ISBN number does not match
;; EXAMPLES : (fillable-check-book-in-inventory 12345 10 (make-book 12345
;;            "Felleisen" "ABC" "HtDP/1" 110 120 20 (make-reorder 10 30) 50))
;;            -> 0
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define (fillable-check-book-in-inventory isbn quantity b)
  (if (= isbn (book-isbn b))
      (if (>= (book-number-of-copies b) quantity) 0
          (return-days-after-reorder 
           (- quantity (book-number-of-copies b)) (book-re-order-status b)))
      false))

;; return-days-after-reorder Number ReOrderStatus -> MaybeNumber
;; GIVEN : A quantity of books and a reorderstatus
;; RETURNS : False if ts not a reorder, false if the quantity is greater than copies
;;           in the reorder status else returns the no. of days.
;; EXAMLPES : (return-days-after-reorder 3 (make-reorder 10  5))-> 10
;; STRATEGY : STRUCTURAL DECOMPOSITION of ReOrderStatus
(define (return-days-after-reorder quantity rs) 
  ( if (reorder? rs)
       (if( > quantity (reorder-copies rs))
          false
          (reorder-days rs))
       false))



;; =============================================================================
;;                              price-for-order
;; =============================================================================
;; price-for-order : Inventory Order -> Number
;; GIVEN : An Inventory and a Order that is placed
;; RETURNS: the total price for the given order.  The price does not
;; depend on whether any particular line item is in stock.  Line items
;; for an ISBN that is not in the inventory count as 0.
;; EXAMPLES : (price-for-order lob1 order1) -> 3220
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define (price-for-order inv order)
  (cond
    [(empty? inv) 0]
    [else (+ (compare-isbn (first inv) order)
             (price-for-order  (rest inv) order))]))

;; compare-isbn : Book Order -> Number
;; GIVEN : An Book and a Order that is placed
;; RETURNS: the total price for the given order haing the given book.
;; EXAMPLES : (compare-isbn  (make-book 12313 "Wand" "EFG" "HtDP/1"
;;                             122 221 20 false 40) order1) -> 1220
;; STRATEGY : STRUCTURAL DECOMPOSITION of Order
(define (compare-isbn b order)
  (cond
    [(empty? order) 0]
    [else (if (check-order-element b (first order))
              (get-the-quantity-ordered b (first order))
              (compare-isbn b (rest order)))]))

;; check-order-element : Book List-Item -> Boolean
;; GIVEN : A Book and a Line-Item
;; RETURNS : true if the isbn's matches else false
;; EXAMPLES : (check-order-element (make-book 12313 "Wand" "EFG" "HtDP/1" 
;;             122 221 20 false 40) (make-line-item 34534 10)) -> false
;; STRATEGY : STRUCTURAL DECOMPOSITION of Line-Item
(define(check-order-element b li)
  (check-inventory-isbn b (line-item-isbn li)))


;; get-the-quantity-ordered : Book Line-Item -> Number
;; GIVEN : A Book and a Line-Item 
;; RETURNS : The total price of the selected book
;; EXAMPLES : (get-the-quantity-ordered (make-book 12313 "Wand" "EFG" "HtDP/1" 
;;            122 221 20 false 40) (make-line-item 12313 10)) ->1220
;; STRATEGY : STRUCTURAL DECOMPOSITION of Line-Item
(define(get-the-quantity-ordered b li)
  (get-total-price-of-order b (line-item-quantity-ordered li)))

;; get-total-price-of-order : Book Number -> Number
;; GIVEN : A Book and the quantity in the order
;; RETURNS : The total price of the selected book
;; EXAMPLES : (get-total-price-of-order (make-book 12313 "Wand" "EFG"
;;            "HtDP/1" 122 221 20 false 40) 50) -> 6100
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define(get-total-price-of-order b quantity )
  (* quantity (book-unit-price b)))


;; =============================================================================
;;                              inventory-after-order
;; =============================================================================


;; inventory-after-order : Inventory Order -> Inventory.
;; GIVEN: an order and an inventory
;; WHERE: the order is fillable now
;; RETURNS: the inventory after the order has been filled.
;; EXAMPLES : (inventory-after-order lob1 order1)-> 
;;  (cons
;;  (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 10 false 50)
;;  (cons
;;  (make-book 12313 "Wand" "EFG" "HtDP/1" 122 221 10 false 40)
;;  (cons
;;  (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 10 false 50)
;;  (cons
;;  (make-book 64433 "Felleisen" "WHAT" "HtDP/1" 100 120 20 false 50)
;;  (cons (make-book 22243 "Shakespeare" "Macbeth" "HtDP/1" 100 120 20 false 50)
;;   empty)))))
;; STRATEGY : STRUCTURAL DECOMPOSITION of Inventory
(define (inventory-after-order inv order)
  (cond
    [(empty? inv) empty]
    [else (cons (check-book-and-line-isbn (first inv) order)
                (inventory-after-order  (rest inv) order))]))


;; check-book-and-line-isbn : Book Order -> Book
;; GIVEN : A Book and an Order
;; RETURNS : a book
;; EXAMPLES : 
;; STRATEGY : STRUCTURAL DECOMPOSITION of Order
(define (check-book-and-line-isbn b order)
  (cond
    [(empty? order) b]
    [else (if (check-first-order b (first order))
              (get-quantity-ordered b (first order))
              (check-book-and-line-isbn b (rest order)))]))

;; check-first-order : Book List-Item -> Boolean
;; GIVEN : A Book and a Line-Item
;; RETURNS : true if the isbn's matches else false
;; EXAMPLES : (check-first-order 
;;        (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 10 false 50)
;;        list-of-line-item -> true
;; STRATEGY : STRUCTURAL DECOMPOSITION of Line-Item
(define(check-first-order b li)
  (check-inventory-isbn b (line-item-isbn li)))

;; get-quantity-ordered : Book Line-Item -> Book
;; GIVEN : A Book and a Line-Item 
;; RETURNS : The updated book
;; EXAMPLES :
;; STRATEGY : STRUCTURAL DECOMPOSITION of Line-Item
(define(get-quantity-ordered b li)
  (updated-inventory b (line-item-quantity-ordered li))) 

;; updated-inventory : Book Number -> Book
;; GIVEN : A Book and the quantity of Books that are ordered
;; RETURNS : The updated Book with the changed no of books
;; EXAMPLES : (updated-inventory 
;;          (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 20 false 50) 10)
;;        -> (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 10 false 50)
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define(updated-inventory b quantity )
  (make-book (book-isbn b)
             (book-title b)
             (book-author b)
             (book-publisher b)
             (book-unit-price b)
             (book-unit-cost b)
             (- (book-number-of-copies b) quantity)
             (book-re-order-status b)
             (book-cuft b)))

;; =============================================================================
;;                             increase-prices
;; =============================================================================


;; increase-prices : Inventory String Number -> Inventory
;; GIVEN: an inventory, a publisher, and a percentage,
;; RETURNS: an inventory like the original, except that all items by that
;; publisher have their unit prices increased by the specified
;; percentage.
;; EXAMPLE: (increase-prices inventory1 "MIT Press" 10)
;; returns an inventory like the original, except that all MIT Press
;; books in the inventory have had their prices increased by 10%.
;; STRATEGY :STRUCTURAL DECOMPOSITION of Inventory
(define (increase-prices inv publisher percent-increase)
  (cond
    [(empty? inv) empty]
    [else (cons (inventory-with-changed-prices (first inv) publisher percent-increase)
                (increase-prices (rest inv) publisher percent-increase))]))


;; inventory-with-changed-prices : Book String Number -> Book
;; GIVEN : A Book , a publisher and a percentage by which the 
;;         price needs to be increased
;; RETURNS : The updated book
;; EXAMPLES :(make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 20 false 50) 10)
;;            "HtDP/1" 10 ->
;;           (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 10 false 50) 10)
;; STRATEGY : STRUCTURAL DECOMPOSITION of Book
(define(inventory-with-changed-prices b pub incr)
  (if (string=? (book-publisher b) pub)
      (make-book (book-isbn b)
                 (book-title b)
                 (book-author b)
                 pub
                 (* (book-unit-price b)(+ 1 (/ incr 100)))
                 (book-unit-cost b)
                 (book-number-of-copies b)
                 (book-re-order-status b)
                 (book-cuft b))
      b))


;; =============================================================================
;;                          Also provide the functions:
;; =============================================================================

;; reorder-present? : ReorderStatus -> Boolean
;; GIVEN : A Reorder
;; RETURNS: true iff the given ReorderStatus shows a pending re-order.
;; EXAMPLES : (reorder-present? false) -> false
;; STRATEGY : DOMAIN KNOWLEDGE
  (define (reorder-present? rs)
    (cond
      [(false? rs) false]
      [else true]))

;; make-empty-reorder : Any -> ReorderStatus
;; Ignores its argument
;; GIVEN : any argument
;; RETURNS: a ReorderStatus showing no pending re-order. 
;; EXAMPLES : (make-empty-reorder 3) -> false
;; STARTEGY : DOMAIN KNOWLEDGE
(define (make-empty-reorder arg)
  false)

;; make-reorder : PosInt PosInt -> ReorderStatus
;; GIVEN: a number of days and a number of copies
;; RETURNS: a ReorderStatus with the given data.
;; EXAMPLES : (make-reorder 10 10) -> 
;; STRATEGY : DOMAIN KNOWLEDGE
;(define (make-reorder days copies)
;  ( make-reorder days copies))

;;==============================================================================
;;                                TESTS
;;==============================================================================

(define-test-suite get-inventory-tests
  (check-equal? (inventory-potential-profit lob1) 3580 "The profit is 3580")
  
  (check-equal? (price-for-line-item lob1 (make-line-item 12313 10 ))
                1220 "The price ofr line item is 1220")
  (check-equal? (price-for-line-item lob1 (make-line-item 00099 10 ))
                false "The ISBN does not exist")
  (check-equal? (fillable-now? order1 lob1) false "The order is fillable")
  (check-equal? (fillable-now? empty-ordr lob1) true "The order is fillable")
  
  
  (check-equal? 
   (inventory-after-order lob1 order1) 
   (cons
    (make-book 12345 "Felleisen" "ABC" "HtDP/1" 100 120 10 false 50)
    (cons
     (make-book 12313 "Wand" "EFG" "HtDP/1" 122 221 10 false 40)
     (cons
      (make-book 34534 "Shakespeare" "Hamlet" "Pearson" 100 120 10 false 50)
      (cons
       (make-book 64433 "Felleisen" "WHAT" "HtDP/1" 100 120 20 false 50)
       (cons (make-book 22243 "Shakespeare" "Macbeth" "HtDP/1" 100 120 20 
                        false 50)
             empty))))) "The Inventory after order is updated")
  
  (check-equal?(increase-prices lob1 "HtDP/1" 10) lob-changed "Changed prices")
  
  (check-equal? (inventory-total-volume lob1) 4800 "The total Volume is 4800")
  
  (check-equal? (price-for-order lob1 order1) 3220 "The price for the order is 3220")
  
  (check-equal? (fillable-check-book-in-inventory 12345 75 
               (make-book 12345 "Felleisen" "ABC" "HtDP/1" 110 120 20 
                          (make-reorder 10 30) 50))
                false "Quantity greater thanreorder copies")
  
  (check-equal? (return-days-after-reorder 3 (make-reorder 10  5))
                10 "These are the days remaining") 
  (check-equal? (return-days-after-reorder 4 false) false "There is no reorder")
  
  (check-equal? (fillable-check-books-in-order (make-line-item 10 20) inventory)
                false "False is returned")
  
  (check-equal? (days-til-fillable list-of-line-item inventory)
                0 "0 days till fillable")
  
  (check-equal? (days-til-fillable order1 inventory)
                false "No Fillable")
  
  (check-equal? (days-til-fillable list-of-line-item lob-changed)
                0 "0 days till fillable")
  
  
  (check-equal? (reorder-present? (make-reorder 20 20))
                true "The reorder is present")
  
  (check-equal? (reorder-present? false)
              false "The reorder is absent")
  
  (check-equal? (make-empty-reorder 2) false "Empth reorder created")

  
  )

(run-tests get-inventory-tests)

