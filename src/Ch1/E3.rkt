#lang sicp
;; Define a procedure that takes three numbers as arguments and returns the sum of the squares of the two larger numbers.

;; Ans;

(define sum
  (lambda (a b)
    (+ a b)))

(define square
  (lambda (v)
    (* v v)))

(define sum-of-squares
  (lambda (a b)
    (sum (square a)
         (square b))))

;; Using max/ min defined in environment
(define max max)
(define min min)

;; Target function
(define p
  (lambda (a b c)
    (let ([m (min a b c)])
      (cond
        [(= m a)
         (sum-of-squares b c)]
        [(= m b)
         (sum-of-squares a c)]
        [(= m c)
         (sum-of-squares a b)]))))
