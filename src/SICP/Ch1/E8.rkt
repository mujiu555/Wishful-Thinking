#lang sicp

;; Newton’s method for cube roots is based on the fact that if y is an approximation to the cube root of x , then a better approximation is given by the value
;; x / y^2 + 2 y
;; ------------- .
;;      3
;; Use this formula to implement a cube-root procedure analogous to the square-root procedure. (In 1.3.4 we will see how to implement Newton’s method in general as an abstraction of these square-root and cube-root procedures.)

(define (square x)
  (* x x))

;; Ans:

(define average
  (lambda args
    (/ (apply + args)
       (length args))))

(define good-enough?
  (lambda (old new)
    (< (/ (abs (- old new))
          old)
       0.00001)))

(define improve
  (lambda (target guess)
    (/ (+ (/ target (square guess))
          (* 2 guess))
       3)))

(define iter
  (lambda (target guess)
    (let ([new (improve target guess)])
      (if (good-enough? new guess)
          new
          (iter target new)))))

(define cube-root
  (lambda (x)
    (iter x 1.0)))
