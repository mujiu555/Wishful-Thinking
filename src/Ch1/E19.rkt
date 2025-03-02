#lang sicp

;; There is a clever algorithm for computing the Fibonacci numbers in a logarithmic number of steps.
;; Recall the transformation of the state variables a and b in the *fib-iter* process of [[file:Chapter1.2.2.org][1.2.2]]:
;; a ← a + b and b ← a .
;; Call this transformation T, and observe that applying T over and over again n times,
;; starting with 1 and 0, produces the pair Fib(n+1) and Fib(n).
;; In other words, the Fibonacci numbers are produced by applying T^n ,
;; the n^th power of the transformation T , starting with the pair (1, 0).
;; Now consider T to be the special case of p = 0 and q = 1 in a family of transformations T_pq ,
;; where T_pq transforms the pair (a, b) according to
;; a ← bq + aq + ap and b ← bp + aq.
;; Show that if we apply such a transformation T_pq twice,
;; the effect is the same as using a single transformation T_p′q′ of the same form,
;; and compute p′ and q′ in terms of p and q .
;; This gives us an explicit way to square these transformations,
;; and thus we can compute T^n using successive squaring, as in the *fast-expt* procedure.
;; Put this all together to complete the following procedure,
;; which runs in a logarithmic number of steps:[fn:7]
;;
;; 有一种用于在对数步骤计算斐波那契数的算法.
;; 回忆 fib-iter 进程中的状态变量 a 和 b:
;; a ← a + b and b ← a .
;; 将这种状态转移方程称作 T, 并且观察到, 从 1 和 0 开始, 重复执行 T n 次,
;; 会产生 Fib(n+1) 和 Fib(n) 的数对.
;; 也就是说, 斐波那契数是通过执行从数对(1, 0) 开始的 T^n, 状态转移方程 T 的 n 方, 得到的.
;; 现在将 T 视为 T_pq 这个状态转移族中 p=0, q=1 的特殊情况,
;; T_pq 根据
;; a ← bq + aq + ap
;; b ← bp + aq.
;; 转化数对 (a, b).
;; 证明, 如果我们执行这样的 T_pq 两次, 效果和执行一次相同形式的 T_p'q' ,
;; 并且用 p 和 q 计算 p' 和 q' 是一样的.
;; 这给了我们一种显式的方式计算那些转移方程的平方, 并且可以通过逐次乘方计算 T^n,
;; 就像 fast-expt 函数一样.
;; 用如上完成如下需要对数步骤的函数[fn:7]:

(define (fib n)
  (fib-iter 1 0 0 1 n))

(define square
  (lambda (x)
    (* x x)))

;; (define (fib-iter a b p q count)
;;   (cond ((= count 0)
;;          b)
;;         ((even? count)
;;          (fib-iter a
;;                    b
;;                    ⟨??⟩  ;compute p' ; (+ p q)
;;                    ⟨??⟩  ;compute q' ; p
;;                    (/ count 2)))
;;         (else
;;          (fib-iter (+ (* b q)
;;                       (* a q)
;;                       (* a p))
;;                    (+ (* b p)
;;                       (* a q))
;;                    p
;;                    q
;;                    (- count 1)))))

(define (fib-iter a b p q count)
  (cond ((= count 0)
         b)
        ((even? count)
         (fib-iter a
                   b
                   (+ (square p) (square q)) ;compute p' ; (+ p q)
                   (+ (* 2 p q) (square q)) ;compute q' ; p
                   (/ count 2)))
        (else
         (fib-iter (+ (* b q)
                      (* a q)
                      (* a p))
                   (+ (* b p)
                      (* a q))
                   p
                   q
                   (- count 1)))))

;; References: https://sicp.readthedocs.io/en/latest/chp1/19.html
