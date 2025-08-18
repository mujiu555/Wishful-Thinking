#lang racket


;; Prove that Fib(n) is the closest integer to φ^n / sqrt(5) ,
;; where φ = (1 + sqrt(5)) / 2 .
;; Hint: Let ψ = (1 − sqrt(5)) / 2 .
;; Use induction and the definition of the Fibonacci numbers (see [[file:Chapter1.2.2.org][1.2.2]]) to prove that
;; Fib(n) = (φ^n − ψ^n) / sqrt(5) .
;;
;; 证明 Fib(n) 是最接近 φ^n / sqrt(5) 的整数,
;; φ = (1 + sqrt(5)) / 2 .
;; 提示: 令ψ = (1 − sqrt(5)) / 2.
;; 用数学归纳法和斐波那契数的定义(见 [[file:Chapter1.2.2.org][1.2.2]])证明
;; Fib(n) = ( φ^n − ψ^n ) / sqrt(5) .

;; Ans:
;; Proof:
;; If Fib(n) = (phi^n - Phi^n) / sqrt(5)
;; when n = 0,
;; Fib(n) = Fib(0) = 0
;; when n = 1,
;; Fib(n) = Fib(1) = (phi - Phi) / sqrt(5)
;; = (((1 + sqrt(5)) / 2) - ((1 - sqrt(5)) / 2)) / sqrt(5)
;; = 1
;; when n = 2,
;; Fib(n) = Fib(2) = (phi^2 - Phi^2) / sqrt(5)
;; = ((1 + 5 + 2*sqrt(5)) / 4 - (1 + 5 - 2*sqrt(5)) / 4) / sqrt(5)
;; = 1
;;
;; then
;; Fib(n+1) = (phi^{n+1} - Phi^{n+1}) / sqrt(5)
;; = (phi^n * ((1 + sqrt(5)) / 2) - Phi^n * ((1 - sqrt(5)) / 2)) / sqrt(5)
;; = (1/2) * (((phi^n - Phi^n) / sqrt(5)) + sqrt(5) * ((phi^n + Phi^n) / sqrt(5)))
;; = 1/2 * Fib(n) + (phi^n + Phi^n)
;;
;; Fib(n+2) = (phi^{n+2} - Phi^{n+2}) / sqrt(5)
;; = 3/2 * Fib(n) + (phi^n + Phi^n)
;;
;; so,
;; Fib(n+2) = Fib(n+1) + Fib(n)
;;
;; Thus,
;; Fib(n) = (phi^n - Phi^n) / sqrt(5) proval
