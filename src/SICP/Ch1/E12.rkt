#lang racket

;; The following pattern of numbers is called /Pascal’s triangle/.
;; 以下数字被称作 "杨辉三角".

;;0 |         1
;;1 |       1   1
;;2 |     1   2   1
;;3 |   1   3   3   1
;;4 | 1   4   6   4   1
;;5 |       . . .

;; The numbers at the edge of the triangle are all 1,
;; and each number inside the triangle is the sum of the two numbers above it [fn:5].
;; Write a procedure that computes elements of Pascal’s triangle by means of a recursive process.
;; 三角形边上的数都为 1, 并且三角形内部的数都是它上方两数的和[fn:5].
;; 写一个函数通过递归进程计算杨辉三角的元素

;;  Ans

(define e
  (lambda (n)
    (let ((last-element
           (if (<= n 0)
               (list 1)
               (e (- n 1)))))
      (let iter ((element '())
                 (nth 0))
        (cond
          ((= nth n)
           (cons 1 element))
          ((= nth 0)
           (iter (cons 1 element)
                 (+ nth 1)) )
          (else
           (iter (cons (+ (list-ref last-element nth)
                          (list-ref last-element (- nth 1)))
                       element)
                 (+ nth 1))))))))
