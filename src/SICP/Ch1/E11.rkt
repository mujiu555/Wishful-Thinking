#lang sicp

;; A function f is defined by the rule that f(n) = n if n < 3 and f(n) = f(n−1) + 2f(n−2) + 3f(n−3) if n ≥ 3 .
;; Write a procedure that computes f by means of a recursive process.
;; Write a procedure that computes f by means of an iterative process.

;; 一个函数 f 用
   ;; { f(n) = n                          if n < 3
   ;; { f(n) = f(n−1) + 2f(n−2) + 3f(n−3) if n ≥ 3 .
;; 定义. 写出一个函数通过递归进程计算 f. (再)写出一个函数用迭代进程.

;; Ans:

(define f
  (lambda (n)
    (if (< n 3)
        n
        (+ (f (- n 1))
           (* 2 (f (- n 2)))
           (* 3 (f (- n 3)))))))

;; assume exists
;; f(n) = f(n−1) + 2f(n−2) + 3f(n−3)
;; f(n-1) = f(n-2) * 2f(n-3) + 3f(n-4)
;; f(n-2) = f(n−3) + 2f(n−4) + 3f(n−5)
;; f(n-3) = f(n−4) + 2f(n−5) + 3f(n−6)
;; ...
;; f(5) = f(4) + 2f(3) + 3f(2)
;; f(4) = f(3) + 2f(2) + 3f(1)
;; f(3) = f(2) + 2f(1) + 3f(0)
;; f(2) = 2
;; f(1) = 1
;; f(0) = 0
;; ...
;;
;; let old n-2 = f(n-2), old n-1 = f(n-1), old n = f(n)
;; then new n = old n + 2 * old n-1 + 3 * old n-2
;; for which new n-1 is old n and new n-2 is old n-1
(define f-iter
  (lambda (n)
    (let iter ((n (if (< n 2) n 2))
               (n-1 1)
               (n-2 0)
               (target n))
      (if (< target 3)
          n
          (iter
           (+ n (* 2 n-1) (* 3 n-2))    ; new n = n + 2 * n-1 + 3 * n-2
           n                            ; new n-1 = n
           n-1                          ; new n-2 = n-1
           (- target 1))))))

(display (eqv? (f -1) (f-iter -1)))
(display (eqv? (f 1) (f-iter 1)))
(display (eqv? (f 2) (f-iter 2)))
(display (eqv? (f 3) (f-iter 3)))
(display (eqv? (f 4) (f-iter 4)))
(display (eqv? (f 5) (f-iter 5)))
(display (eqv? (f 6) (f-iter 6)))
(display (eqv? (f 7) (f-iter 7)))
