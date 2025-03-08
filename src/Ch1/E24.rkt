#lang sicp

;; Modify the *timed-prime-test* procedure of [[Exercise 1.22:]] to use *fast-prime?* (the Fermat method),
;; and test each of the 12 primes you found in that exercise.
;; Since the Fermat test has Θ(log⁡n) growth,
;; how would you expect the time to test primes near 1,000,000 to compare with the time needed to test primes near 1000?
;; Do your data bear this out?
;; Can you explain any discrepancy you find?
;; 修改 [[Exercise 1.22:][练习 1.22]] 中的 timed-prime-test 函数,
;; 以使用 fast-prime? (费马方法),
;; 并测试你在该练习中找到的 12 个素数.
;; 由于费马测试的增长阶为 Θ(log n),
;; 你预期测试 1,000,000 左右的素数所需的时间
;; 与测试 1,000 左右的素数所需的时间
;; 相比如何?
;; 你的数据是否支持这一点?
;; 你能否解释任何出现的差异?

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

(define s
  (lambda (n)
    (let iter ((i n))
      (if (timed-prime-test i)
          i
          (iter (+ 1 i))))))

;; Ans:

;; 1000
;; 1001
;; 1002
;; 1003
;; 1004
;; 1005
;; 1006
;; 1007
;; 1008
;; 1009 *** 13
;; 1010
;; 1011
;; 1012
;; 1013 *** 14
;; 1014
;; 1015
;; 1016
;; 1017
;; 1018
;; 1019 *** 14
;; 10000
;; 10001
;; 10002
;; 10003
;; 10004
;; 10005
;; 10006
;; 10007 *** 17
;; 10008
;; 10009 *** 17
;; 10010
;; 10011
;; 10012
;; 10013
;; 10014
;; 10015
;; 10016
;; 10017
;; 10018
;; 10019
;; 10020
;; 10021
;; 10022
;; 10023
;; 10024
;; 10025
;; 10026
;; 10027
;; 10028
;; 10029
;; 10030
;; 10031
;; 10032
;; 10033
;; 10034
;; 10035
;; 10036
;; 10037 *** 17
;; 100000
;; 100001
;; 100002
;; 100003 *** 20
;; 100004
;; 100005
;; 100006
;; 100007
;; 100008
;; 100009
;; 100010
;; 100011
;; 100012
;; 100013
;; 100014
;; 100015
;; 100016
;; 100017
;; 100018
;; 100019 *** 19
;; 100020
;; 100021
;; 100022
;; 100023
;; 100024
;; 100025
;; 100026
;; 100027
;; 100028
;; 100029
;; 100030
;; 100031
;; 100032
;; 100033
;; 100034
;; 100035
;; 100036
;; 100037
;; 100038
;; 100039
;; 100040
;; 100041
;; 100042
;; 100043 *** 19(1009 1013 1019 10007 10009 10037 100003 100019 100043)
