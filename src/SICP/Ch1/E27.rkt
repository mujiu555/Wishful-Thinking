#lang sicp

;; Demonstrate that the Carmichael numbers listed in [fn:4] really do fool the Fermat test.
;; That is, write a procedure that takes an integer n
;; and tests whether a^n is congruent to a modulo n for every a < n ,
;; and try your procedure on the given Carmichael numbers.
;; 证明 [fn:4] 中列出的卡迈克尔数确实能欺骗费马测试.
;; 即, 编写一个函数, 该函数接受一个整数 n,
;; 并测试对每一个 a < n, a^n 是否与 a 模 n 同余,
;; 并尝试用给定的卡迈克尔数测试你的函数。

(define square
  (lambda (n)
    (* n n)))

(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder
          (square (expmod base (/ exp 2) m))
          m))
        (else
         (remainder
          (* base (expmod base (- exp 1) m))
          m))))

(define check
  (lambda (n)
    (let iter ((i 1))
      (let ((r (= (expmod i n n)
                  (remainder i n))))
        (cond
          ((> i n)
           #t)
          ((not r)
           r)
          (else
           (iter (+ i 1))))))))

(map check (list 561 1105 1729 2465 2821 6601))
;; => (#t #t #t #t #t #t)
