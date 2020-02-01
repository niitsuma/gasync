

(import [nose.tools [eq_  assert-equal assert-not-equal]])

(import  [gasync.core [*]])
(require [gasync.core [*]])

;; (defn assert-all-equal [&rest tests]
;;   (reduce (fn [x y] (assert-equal x y) y)
;;           tests)
;;   None)

(defmacro/g! wrap-stdout [&rest body]
  `(do
     (import sys
             [io [StringIO]])
    (setv ~g!old-stdout sys.stdout)
    (setv sys.stdout (StringIO))
    (setv ~g!result (do ~@body))
    (setv ~g!stdout (.getvalue sys.stdout))
    (setv sys.stdout ~g!old-stdout)
    [~g!stdout ~g!result]))



(defn test-core []
  (eq_
    'time/a
    (symbolg2symbola 'time/g)
    )

  (eq_
    'time
    (symbolg2symbol 'time/g)
    )

  (eq_
    '(await (f2/a (await (f1/a (await (map/a f/a [1 2])) (await (print/a 2)))) (print 5)))
      (q-exp-g2a-deep
      '(f2/g (f1/g (map/g f/g [1 2]) (print/g 2))(print 5))
      )
      )
  
  (eq_
    '(f2 (f1 (map f [1 2]) (print 2)) (print 5))
      (q-exp-g2--deep
      '(f2/g (f1/g (map/g f/g [1 2]) (print/g 2))(print 5))
      ))
  

  (import asyncio)
  (import time)

  (defn/a sleep_test/a [t]  
    (await (asyncio.sleep t)) 
    (print t)
    t)

  (defn sleep_test [t]  
    (time.sleep t)
    (print t)
    t)
  
  (defn/g sleep_map [x]
    (print x)
    (sleep/g x)
    (list (map/g sleep_test/g [x 2 1]) )
    (+ x 30)
    )

  (eq_
    ["3.5\n1\n2\n3.5\n" 33.5]  
    (wrap-stdout
      (progn/a (sleep_map/a 3.5))
      )
    )

  (eq_
    ["3.5\n3.5\n2\n1\n" 33.5]
    (wrap-stdout
      (sleep_map 3.5)
      ))
)


