#lang sicp

;; The process that a procedure generates is of course dependent on the rules used by the interpreter.
;; As an example, consider the iterative gcd procedure given above.
;; Suppose we were to interpret this procedure using normal-order evaluation, as discussed in [[file:Chapter1.1.5.org][1.1.5]].
;; (The normal-order-evaluation rule for *if* is described in [[file:Chapter1.1.6.org][Exercise 1.5]].)
;; Using the substitution method (for normal order),
;; illustrate the process generated in evaluating *(gcd 206 40)* and indicate the *remainder* operations that are actually performed.
;; How many *remainder* operations are actually performed in the normal-order evaluation of *(gcd 206 40)*?
;; In the applicative-order evaluation?
;; 一个函数生成的过程是与解释器使用的规则相关的.
;; 例如, 考虑到以上的 gcd 函数.
;; 假设我们使用正常序求值解释这个函数的, 就像 [[file:Chapter1.1.5.org][1.1.5]] 节所讨论的.
;; (if 的正常序求值规则已经在 [[file:Chapter1.1.6.org][练习 1.5]] 中被讨论.).
;; 使用代换方法 (正常顺序),
;; 展示求值 (gcd 206 40) 时产生的进程, 并指出实际执行的 remainder 操作.
;; 在正常序求值 (gcd 206 40) 时有多少 remainder 操作被实际执行了?
;; 对于应用序求值呢?

(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))

;; Ans:

(gcd 206 40)
(gcd 40 (remainder 206 40))
(gcd 6 (remainder 40 6))
(gcd 4 (remainder 6 4))
(gcd 2 (remainder 4 2))
;; => 2

(gcd 206 40)
;; =>
(if (= 40 0)
    206
    (gcd 40 (remainder 206 40)))
(if (= 40 0)
    206
    (if (= 6 0)                         ; (remainder 206 40)
        40
        (gcd 6 (remainder 40 6))))
;; ...
