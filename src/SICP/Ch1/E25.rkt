#lang sicp

;; Alyssa P. Hacker complains that we went to a lot of extra work in writing *expmod*.
;; After all, she says,
;; since we already know how to compute exponentials,
;; we could have simply written
;; Alyssa P. Hacker 抱怨我们在编写 expmod 时做了很多额外的工作.
;; 毕竟, 她说,
;; 既然我们已经知道如何计算指数,
;; 我们可以简单地(将 expmod)写成:

(define (expmod base exp m)
  (remainder (fast-expt base exp) m))

;; Is she correct?
;; Would this procedure serve as well for our fast prime tester? Explain.
;; 她是否正确?
;; 这个函数是否同样适用于我们的快速素数测试?
;; 请解释.

;; Ans:

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n)
         n)
        ((divides? test-divisor n)
         test-divisor)
        (else (find-divisor
               n
               (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))

(define square
  (lambda (n)
    (* n n)))

(define next
  (lambda (n)
    (if (= n 2)
        3
        (+ n 2))))


(define (timed-prime-test n)
  (newline)
  (display n)
  (start-prime-test n (runtime)))

;; Adjusted
(define (start-prime-test n start-time)
  (if (fast-prime? n 1)                ; 10 for now
      (report-prime (- (runtime)
                       start-time)
                    n)
      #f))

(define (report-prime elapsed-time n)
  (display " *** ")
  (display elapsed-time)
  n)

;; Replaced
;; (define (expmod base exp m)
;;   (cond ((= exp 0) 1)
;;         ((even? exp)
;;          (remainder
;;           (square (expmod base (/ exp 2) m))
;;           m))
;;         (else
;;          (remainder
;;           (* base (expmod base (- exp 1) m))
;;           m))))

(define (fermat-test n)
  (define (try-it a)
    (= (expmod a n n) a))
  (try-it (+ 1 (random (- n 1)))))

(define (fast-prime? n times)
  (cond ((= times 0) true)
        ((fermat-test n)
         (fast-prime? n (- times 1)))
        (else false)))
;; Ans

(define fast-expt
  (lambda (base e)
    (let iter ((base base)
               (e e))
      (cond
        [(= e 1)
         base]
        [(even? e)
         (iter (* base base)
               (/ e 2))]
        [else
         (* base
            (iter (* base base)
                  (/ (- e 1) 2)))]))))

(define s
  (lambda (n)
    (let iter ((i n))
      (if (timed-prime-test i)
          i
          (iter (+ 1 i))))))
