#lang sicp

;; Use the *smallest-divisor* procedure to find the smallest divisor of each of the following numbers:
;; 199, 1999, 19999.
;; 使用 smallest-divisor 函数去找到如下数的最小因数:
;; 199, 1999, 19999.

(define (square n)
  (* n n))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n)
         n)
        ((divides? test-divisor n)
         test-divisor)
        (else (find-divisor
               n
               (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

;; Ans:

(smallest-divisor 199)
(smallest-divisor 1999)
(smallest-divisor 19999)
