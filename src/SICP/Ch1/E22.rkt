#lang sicp

;; Most Lisp implementations include a primitive called *runtime* that returns an integer
;; that specifies the amount of time the system has been running (measured, for example, in microseconds).
;; The following *timed-prime-test* procedure,
;; when called with an integer n ,
;; prints n and checks to see if n is prime.
;; If n is prime,
;; the procedure prints three asterisks followed by the amount of time used in performing the test.
;; 大部分 Lisp 实现都有一个被称作 runtime 的原语, 返回一个确定了系统运行时间的整数(以, 例如, 微秒作单位).
;; 当如下 timed-prime-test 函数用整数 n 调用时, 会输出 n, 并检查 n 是否为一个素数.
;; 如果 n 是一个素数, 这个函数会输出三个星号,
;; 紧跟执行这个测试所用的时间.

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

;; Using this procedure,
;; write a procedure *search-for-primes* that checks the primality of consecutive odd integers in a specified range.
;; Use your procedure to find the three smallest primes larger than 1000;
;; larger than 10,000;
;; larger than 100,000;
;; larger than 1,000,000.
;; Note the time needed to test each prime.
;; Since the testing algorithm has order of growth of Θ(sqrt(n)) ,
;; you should expect that testing for primes around 10,000 should take about
;; sqrt(10) times as long as testing for primes around 1000.
;; Do your timing data bear this out?
;; How well do the data for 100,000 and 1,000,000 support the Θ(sqrt(n)) prediction?
;; Is your result compatible with the notion
;; that programs on your machine run in time proportional to
;; the number of steps required for the computation?
;; 使用此程序,
;; 编写一个名为 search-for-primes 的函数,
;; 检查指定范围内连续奇数的素性.
;; 使用你的函数找到三个大于
;; 1000, 10,000, 100,000 和 1,000,000
;; 的最小素数.
;; 注意测试每个素数所需的时间.
;; 由于测试算法的增长阶为 Θ(√n),
;; 你应该预期测试 10,000 左右的素数所需的时间
;; 大约是测试 1,000 左右的素数所需时间的 √10 倍.
;; 你的计时数据是否支持这一点?
;; 对于 100,000 和 1,000,000 的数据在多大程度上支持 Θ(√n) 的预测?
;; 你的结果是否与程序在你的机器上运行所需时间
;; 与计算所需步骤数量成正比的概念相符？


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

;; Ans:

(define s
  (lambda (n)
    (let iter ((i n))
      (if (timed-prime-test i)
          i
          (iter (+ 1 i))))))

;; 1000
;; 1001
;; 1002
;; 1003
;; 1004
;; 1005
;; 1006
;; 1007
;; 1008
;; 1009 *** 2
;; 1010
;; 1011
;; 1012
;; 1013 *** 2
;; 1014
;; 1015
;; 1016
;; 1017
;; 1018
;; 1019 *** 2
;; 10000
;; 10001
;; 10002
;; 10003
;; 10004
;; 10005
;; 10006
;; 10007 *** 5
;; 10008
;; 10009 *** 5
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
;; 10037 *** 5
;; 100000
;; 100001
;; 100002
;; 100003 *** 15
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
;; 100019 *** 14
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
;; 100043 *** 16(1009 1013 1019 10007 10009 10037 100003 100019 100043)
