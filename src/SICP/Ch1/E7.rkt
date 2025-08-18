#lang sicp

;; The good-enough? test used in computing square roots
;; will not be very effective for finding the square
;; roots of very small numbers. Also, in real computers,
;; arithmetic operations are almost always performed
;; with limited precision. This makes our test inadequate
;; for very large numbers. Explain these statements,
;; with examples showing how the test fails for small
;; and large numbers. An alternative strategy for
;; implementing good-enough? is to watch how guess
;; changes from one iteration to the next and to stop
;; when the change is a very small fraction of the
;; guess. Design a square-root procedure that uses this
;; kind of end test. Does this work better for small
;; and large numbers?

;; Ch1.1.7 Ver good-enough?

(define (square x)
  (* x x))

;; (define (sqrt-iter guess x)
;;   (if (good-enough? guess x)
;;       guess
;;       (sqrt-iter (improve guess x) x)))

;; (define (improve guess x)
;;   (average guess (/ x guess)))

;; (define (average x y)
;;   (/ (+ x y) 2))

;; (define (good-enough? guess x)
;;   (< (abs (- (square guess) x)) 0.001))

;; (define (sqrt x)
;;   (sqrt-iter 1.0 x))

;; Ans:
;;
;; When met large number:
;;
;; When met small number:
;; (sqrt 0.09)
;; => 0.3000299673226795
;; (sqrt 100000000000000000000000000000000000000000000000000000000000000000000)
;; => for racket, it implement bignumber, and always true ...
;; but it takes time ...

(define good-enough?
  (lambda (old new)
    (< (/ (abs (- old new))
          old)
       0.00000001)))

(define average
  (lambda args
    (/ (apply + args)
       (length args))))

(define improve
  (lambda (target guess)
    (average guess (/ target guess))))

(define sqrt-iter
  (lambda (target guess)
    (let ([new (improve target guess)])
      (if (good-enough? guess new)
        guess
        (sqrt-iter target new)))))

(define sqrt
  (lambda (x)
    (sqrt-iter x 1.0)))
