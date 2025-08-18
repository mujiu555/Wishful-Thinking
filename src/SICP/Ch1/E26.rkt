#lang sicp

;; Louis Reasoner is having great difficulty doing [[Exercise 1.24:]].
;; His *fast-prime?* test seems to run more slowly than his *prime?* test.
;; Louis calls his friend Eva Lu Ator over to help.
;; When they examine Louis’s code,
;; they find that he has rewritten the *expmod* procedure
;; to use an explicit multiplication,
;; rather than calling *square*:
;; Louis Reasoner 在做 [[Exercise 1.24:][练习 1.24]] 时遇到了很大的困难.
;; 他的 fast-prime? 测试似乎比 prime? 测试运行得更慢.
;; Louis 叫来他的朋友 Eva Lu Ator 帮忙.
;; 当他们检查 Louis 的代码时,
;; 发现他重写了 expmod 函数,
;; 使用了显式的乘法,
;; 而不是调用 square:

(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder
          (* (expmod base (/ exp 2) m)
             (expmod base (/ exp 2) m))
          m))
        (else
         (remainder
          (* base
             (expmod base (- exp 1) m))
          m))))

;; “I don’t see what difference that could make,” says Louis.
;; “I do.” says Eva. “By writing the procedure like that, you have transformed the Θ(log⁡n) process into a Θ(n) process.”
;; Explain.
;; "我不明白这有什么区别," Louis 说.
;; "我明白," Eva 说. "编写这样的函数, 你已经将 Θ(log n) 的进程变成了 Θ(n) 的."
;; 请解释.

;; Ans:

;; calculate twice
;; which can be improved by
;; let ((s (expmod base (/ exp 2) m)))
;; ...
