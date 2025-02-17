#lang sicp


;; The exponentiation algorithms in this
;; section are based on performing
;; exponentiation by means of repeated
;; multiplication. In a similar way, one can
;; perform integer multiplication by means
;; of repeated addition. The following
;; multiplication procedure (in which it is
;; assumed that our language can only add,
;; not multiply) is analogous to the *expt*
;; procedure:
;; 本节中的指数算法基于执行重复的乘方而计算指数的方法.
;; 另一个相似的方法中, 可以通过重复相加实现整数乘法.
;; 如下的乘法函数(假设我们的语言仅可以加合而无法乘方)
;; 是对于 expt 函数的模拟(模仿):

(define (* a b)
  (if (= b 0)
      0
      (+ a (* a (- b 1)))))

;; This algorithm takes a number of steps
;; that is linear in b. Now suppose we
;; include, together with addition,
;; operations *double*, which doubles an
;; integer, and *halve*, which divides an
;; (even) integer by 2. Using these, design
;; a multiplication procedure analogous to
;; *fast-expt* that uses a logarithmic number
;; of steps.
;; 这个算法需要的步骤随 b 线性.
;; 假设我们现在有加合, double, 翻倍整数,
;; 和 halve, 将偶数除二. 通过这些,
;; 设计一个乘法函数模拟只需要对数步骤的 fast-expt.

;; Ans:
(define double
  (lambda (n)
    (* 2 n)))

(define halve
  (lambda (n)
    (/ n 2)))

(define mutiple
  (lambda (m n)
    (cond
      [(= n 0)
       0]
      [(even? b)
       (double (mutiple a (halve b)))]
      [(odd? b)
       (+ a (multiple a (- b 1)))])))
