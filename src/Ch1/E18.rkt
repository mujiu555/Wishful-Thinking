#lang sicp

;; Using the results of [[Exercise 1.16]] and
;; [[Exercise 1.17]]
;; , devise a procedure that
;; generates an iterative process for
;; multiplying two integers in terms of
;; adding, doubling, and halving and uses a
;; logarithmic number of steps[fn:6].
;; 使用 [[Exercise 1.16]] 和
;; [[Exercise 1.17]] 中的结果,
;; 用 adding, doubling 和 halving
;; 设计一个产生计算两整数之积,
;; 只需要对数步骤的迭代进程的函数[fn:6]

;; Ans:

(define add
  (lambda (a b)
    (+ a b)))

(define double
  (lambda (a)
    (* 2 a)))

(define halve
  (lambda (x)
    (/ x 2)))

(define product
  (lambda (m n)
    (let ([n (abs n)]
          [remainder (remainder n 2)])
      (add (if (even? n) 0 m)
           (let iter ([n (- n remainder)]
                      [m m])
             (cond
               [(eqv? 1 n) m]
               [else
                (iter (halve n)
                      (double m))]))))))
