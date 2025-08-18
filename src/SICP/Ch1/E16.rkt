#lang sicp

;; Design a procedure that evolves an
;; iterative exponentiation process that
;; uses successive squaring and uses a
;; logarithmic number of steps, as does
;; *fast-expt*. (Hint: Using the observation
;; that (b^{n/2})^2 = (b^2)^{n/2} ,
;; keep, along with the exponent n and the
;; base b , an additional state variable a ,
;; and define the state transformation in
;; such a way that the product ab^n is
;; unchanged from state to state. At the
;; beginning of the process a is taken to be
;; 1, and the answer is given by the value
;; of a at the end of the process. In
;; general, the technique of defining an
;; /invariant quantity/ that remains
;; unchanged from state to state is a
;; powerful way to think about the design of
;; iterative algorithms.)
;; 设计一个对数步骤(产生)迭代指数进程的函数,
;; 就像 fast-expt.
;; (提示: (b^{n/2})^2 = (b^2)^{n/2},
;; 需要维护, 指数 n, 基数 b,
;; 和一个额外的状态变量 a,
;; 并且定义一个 ab^n
;; 不会随状态改变而改变的转化过程.
;; 在进程的一开始, a 是 1,
;; 而答案是 a 在进程结束时的值.
;; 普遍的,
;; 这种定义一个保持在状态之间不变的 "常量"
;; 的方法是一种思考如何设计迭代算法的有力途径)

;; Ans:
;; Works only for integer
;; did not concerning about hint
(define expt
  (lambda (base exponential)
    ((if (negative? exponential) / *)
     1
     (let ([exponential (abs exponential)]
           [remainder (remainder exponential 2)])
       (* (if (even? exponential) 1 base)
       (let iter ([e (- exponential remainder)]
                  [b base])
         (cond
           [(eqv? 0 e) 1]
           [(eqv? 1 e) b]
           [else
            (iter (/ e 2)
                  (* b b))])))))))
