#lang sicp

;; The following procedure computes a mathematical function called Ackermann’s function.
;; 以下函数计算了一个被称作 Ackermann 函数的数学函数.

(define (A x y)
  (cond ((= y 0) 0)
        ((= x 0) (* 2 y))
        ((= y 1) 2)
        (else (A (- x 1)
                 (A x (- y 1))))))

;; What are the values of the following expressions?
;; 以下表达式的值是什么?

(A 1 10)
(A 2 4)
(A 3 3)

;; Consider the following procedures, where A is the procedure defined above:
;; 对于以下函数, A定义如上:

(define (f n) (A 0 n))
(define (g n) (A 1 n))
(define (h n) (A 2 n))
(define (k n) (* 5 n n))

;; Give concise mathematical definitions for the functions computed by the procedures f, g, and h for positive integer values of n . For example, (k n) computes 5n^2 .
;; 给出对于用函数 f, g, 和 h 对于正整数 n 计算的函数的简要的数学定义. 如, (k n)计算 5n^2.

;; Ans:
;;

;; (define (A x y)
;;   (cond ((= y 0) 0)
;;         ((= x 0) (* 2 y))
;;         ((= y 1) 2)
;;         (else (A (- x 1)
;;                  (A x (- y 1))))))
;;
;;           { 0,                y = 0,
;; A(x, y) = { 2y,               x = 0,
;;           { A(x-1,A(x, y-1)), else
;; }}}
;; 1024
;; 65536
;; 65536

;; f => 2n
;; g => 2*2* ...(n-1) * 2 = 2^n
;; h =>
