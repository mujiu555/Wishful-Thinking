#lang sicp

;; One variant of the Fermat test that cannot be fooled is called the /Miller-Rabin test/ ([[file:References.org][Miller 1976]]; [[file:References.org][Rabin 1980]]).
;; This starts from an alternate form of Fermat’s Little Theorem,
;; which states that if n is a prime number and a is any positive integer less than n ,
;; then a raised to the (n−1)-st power is congruent to 1 modulo n .
;; To test the primality of a number n by the Miller-Rabin test,
;; we pick a random number a < n
;; and raise a to the (n−1)-st power modulo n using the *expmod* procedure.
;; However, whenever we perform the squaring step in *expmod*,
;; we check to see if we have discovered a “nontrivial square root of 1 modulo n ,”
;; that is,
;; a number not equal to 1 or n−1 whose square is equal to 1 modulo n .
;; It is possible to prove that if such a nontrivial square root of 1 exists,
;; then n is not prime.
;; It is also possible to prove that if n is an odd number that is not prime,
;; then, for at least half the numbers a < n ,
;; computing a^{n−1} in this way will reveal a nontrivial square root of 1 modulo n .
;; (This is why the Miller-Rabin test cannot be fooled.)
;; Modify the *expmod* procedure to signal if it discovers a nontrivial square root of 1,
;; and use this to implement the Miller-Rabin test with a procedure analogous to *fermat-test*.
;; Check your procedure by testing various known primes and non-primes.
;; Hint: One convenient way to make *expmod* signal is to have it return 0.
;; 一个不能被欺骗的费马测试的变体称为米勒-拉宾测试 ( [[file:References.org][Miller 1976]]; [[file:References.org][Rabin 1980]] ).
;; 这个测试基于费马小定理的另一种形式, 它指出, 如果 n 是一个质数, a 是任何小于 n 的正整数,
;; 那么 a 的 (n−1) 次幂与 1 模 n 同余.
;; (n is prime, Any a < n, a^{n-1} === 1 (mod n))
;; (=> x1 = 1, x2 = n-1)
;; 为了使用米勒-拉宾测试来测试一个数 n 的素性, 我们选择一个随机数 a < n, 并使用 expmod 计算 a 的 (n−1) 次幂模 n.
;; 然而, 在 expmod 过程中每次执行平方步骤时, 我们都会检查是否发现了 "1 模 n 的的非平凡平方根",
;; 即, 一个不等于 1 或 n−1 且其平方等于 1 模 n 的数.
;; (Any x != 1 and x != n-1, x^2 === 1 (mod n))
;; 可以证明, 如果存在这样的非平凡平方根, 那么 n 就不是质数.
;; 还可以证明, 如果 n 是一个非质数的奇数,
;; 那么, 对于至少有一半的 a < n, 在以这种方式计算 a^{n−1} 时会得出 1 模 n 的非平凡平方根.
;; (这就是为什么米勒-拉宾测试不能被欺骗.)
;; 修改 expmod 过程, 使其在发现 1 模 n 的非平凡平方根时发出信号,
;; 并使用这种方法实现类似于 fermat-test 的米勒-拉宾测试.
;; 通过检查已知的质数和非质数来检查你的函数.
;; 提示: expmod 发信的一个简单方法是返回 0.

;; Ans:

(define square
  (lambda (n)
    (* n n)))

(define expmod
  (lambda (b e n)
    (cond
      [(= e 0) 1]
      [(nontrival-square-root? b n)
       0]
      [(even? e)
       (remainder
        (square (expmod b (/ e 2) n))
        n)]
      [else
       (remainder
        (* b (expmod b (- e 1) n))
        n)])))

(define nontrival-square-root?
  (lambda (b n)
    (and (not (= 1 b))
         (not (= b (- n 1)))
         (= (remainder (square b) n)
            (remainder 1 n)))))

(define r
  (lambda (m)
    (+ (random (- m 1)) 1)))

(define t
  (lambda (n)
    (let iter ((i 0))
      (cond
        [(= i (ceiling (sqrt n))) #t]
        [(= (expmod (r n)
                    (- n 1)
                    n)
            1)
         (iter (+ i 1))]
        [else
         #f]))))

(map t (list 561 1105 1729 2465 2821 6601))
;; (#f #f #f #f #f #f)
(map t (list 2 3 4 5 6 7 8 9 10))
;; (#t #t #f #t #f #t #f #f #f)
