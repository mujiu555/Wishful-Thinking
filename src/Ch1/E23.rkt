#lang sicp


;; The *smallest-divisor* procedure shown at the start of this section does lots of needless testing:
;; After it checks to see if the number is divisible by 2
;; there is no point in checking to see if
;; it is divisible by any larger even numbers.
;; This suggests that the values used for *test-divisor* should not be 2, 3, 4, 5, 6, …,
;; but rather 2, 3, 5, 7, 9, ….
;; To implement this change, define a procedure next that returns 3 if its input is equal to 2 and otherwise returns its input plus 2.
;; Modify the *smallest-divisor* procedure to use *(next test-divisor)* instead of *(+ test-divisor 1)*.
;; With *timed-prime-test* incorporating this modified version of *smallest-divisor*,
;; run the test for each of the 12 primes found in [[Exercise 1.22:]].
;; Since this modification halves the number of test steps,
;; you should expect it to run about twice as fast.
;; Is this expectation confirmed?
;; If not, what is the observed ratio of the speeds of the two algorithms,
;; and how do you explain the fact that it is different from 2?
;; 本节开头展示的 smallest-divisor 函数进行了许多不必要的测试:
;; 在检查一个数字是否能被 2 整除后,
;; 再检查它是否能被任何(其他)更大的偶数整除是没有意义的.
;; 这表明用于 test-divisor 的值不应该是
;; 2, 3, 4, 5, 6, …,
;; 而应该是 2, 3, 5, 7, 9, ….
;; 为了实现这一变化,
;; 定义一个函数 next, 当其输入等于 2 时返回 3, 否则返回其输入加 2.
;; 修改最小除数程序,
;; 使用 (next test-divisor) 代替 (+ test-divisor 1).
;; 在包含这个修改版 smallest-divisor 的 timed-prime-test 中,
;; 对 [[Exercise 1.22:][练习 1.22]] 中找到的 12 个素数进行测试.
;; 由于这一修改将测试步骤的数量减半,
;; 你应该预期它的运行速度大约快两倍.
;; 这个预期是否成立?
;; 如果没有, 两个算法的速度比率是多少?
;; 你如何解释这个比率与 2 不同的事实?

(define (smallest-divisor n)
  (find-divisor n 2))

;; (define (find-divisor n test-divisor)
;;   (cond ((> (square test-divisor) n)
;;          n)
;;         ((divides? test-divisor n)
;;          test-divisor)
;;         (else (find-divisor
;;                n
;;                (+ test-divisor 1)))))

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
  (if (prime? n)
      (report-prime (- (runtime)
                       start-time)
                    n)
      #f))

(define (report-prime elapsed-time n)
  (display " *** ")
  (display elapsed-time)
  n)


;; Ans

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n)
         n)
        ((divides? test-divisor n)
         test-divisor)
        (else (find-divisor
               n
               (next test-divisor)))))

(define s
  (lambda (n)
    (let iter ((i n))
      (if (timed-prime-test i)
          i
          (iter (+ 1 i))))))

;; 1009 *** 21009
(map s (list 1000 1010 1014 10000 10008 10010 100000 100004 100020))

;; 1000
;; 1001
;; 1002
;; 1003
;; 1004
;; 1005
;; 1006
;; 1007
;; 1008
;; 1009 *** 3
;; 1010
;; 1011
;; 1012
;; 1013 *** 1
;; 1014
;; 1015
;; 1016
;; 1017
;; 1018
;; 1019 *** 1
;; 10000
;; 10001
;; 10002
;; 10003
;; 10004
;; 10005
;; 10006
;; 10007 *** 3
;; 10008
;; 10009 *** 3
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
;; 10037 *** 3
;; 100000
;; 100001
;; 100002
;; 100003 *** 9
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
;; 100019 *** 10
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
;; 100043 *** 10(1009 1013 1019 10007 10009 10037 100003 100019 100043)
