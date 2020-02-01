
(import [hy.contrib.walk [postwalk]])


(defn car [ls]  (first ls))
(defn cdr [ls]  (cut ls 1))
;;(defn cdr [s] (first (cut s 1) ))
(defn cadr [ls]  (-> ls cdr car))


(defn fun/a-name? [s]
  (and  (= (cut s -2) "/a")
        (!= s "defn/a")    ))
(defn fun/g-name? [s]
  (and  (= (cut s -2) "/g")
        (!= s "defn/g")    ))
(defn fun/a-symbol? [s]
  (and  (symbol? s)
        (fun/a-name? (str s)) ))
(defn fun/g-symbol? [s]
  (and  (symbol? s)
        (fun/g-name? (str s)) ))
(defn symbol_2symbola [s] (HySymbol (+ (str s) "/a")))
(defn symbolg2symbol [s] (HySymbol  (cut (str s) None -2)))
(defn symbolg2symbola [s] (HySymbol (+ (cut (str s) None -2) "/a")))
(defn q-exp-fn-args?    [p]   (and (coll? p) (> (len p) 1)))
(defn q-exp-fn?         [p f] (and (q-exp-fn-args? p) (= (first p) f)))
(defn q-exp-/a-fn?      [p]   (and (q-exp-fn-args? p) (fun/a-symbol? (first p))))
(defn q-exp-/g-fn?      [p]   (and (q-exp-fn-args? p) (fun/g-symbol? (first p))))

(defn q-exp-awaited?    [p]   (q-exp-fn? p 'await))
(defn q-exp-2awaited?   [p]   (and (q-exp-awaited? p) (q-exp-awaited? (cadr p)) (= (len p) 2)))
(defn q-exp-2awaited-del [p]  (if (q-exp-2awaited? p) (cadr p) p))
(defn q-exp-awaited-del   [p] (if (q-exp-awaited? p)(cadr p) p))
(defn q-exp-insert-await [p] (if (q-exp-/a-fn? p)  `(await ~p) p))

(defn q-exp-fng-normalize [p]
  (if (q-exp-/g-fn? p)
      `(~(symbolg2symbol (first p)) ~@(cut p 1))
      p))
(defn q-element-g-normalize [p]
  (if (fun/g-symbol? p)
      (symbolg2symbol p)
      p))
(defn q-exp-fng-replace-a [p] 
  (if (q-exp-/g-fn? p)
      `(~(symbolg2symbola (first p)) ~@(cut p 1))
      p))
(defn q-element-g-replace-a [p]
  (if (fun/g-symbol? p)
      (symbolg2symbola p)
      p))


(setv fn-symbol-list-arg-no-await  [['map/a [1]]])

(defn q-exp-no-await-arg-del [p]
  (if (q-exp-fn-args? p)
      `( ~@(lfor j (range (len p))
             (do
               (setv a (get p j))
               (for [f_n fn-symbol-list-arg-no-await]
                 (setv f (first f_n))
                 (setv ns (get f_n 1))
                 (when (and (q-exp-fn? p f) (in j ns))
                   (setv a (q-exp-awaited-del a))))
               a
               )))
      p))

(defn q-exp-async-fix-deep [p]
  (postwalk
    q-exp-no-await-arg-del
    (postwalk
      q-exp-2awaited-del
      (postwalk
        q-exp-insert-await
        (postwalk
          q-exp-2awaited-del
          p)))))

(defn q-exp-g2a-deep [p] (q-exp-async-fix-deep (postwalk q-element-g-replace-a p)))
(defn q-exp-g2--deep [p] (postwalk q-element-g-normalize p))


(import asyncio)

(defn/a map/a [f l]
  (await (asyncio.gather #*(lfor a l (f a)))))

(import time)

(defn sleep [t] (time.sleep t))
(defn/a sleep/a [t] (await (asyncio.sleep t)))

(defmacro progn/a [&rest code]
  `(.run_until_complete (.get-event-loop asyncio )
     ((fn/a []
        ~@(lfor p code (q-exp-async-fix-deep p))
        ))
     ))

(defmacro defn/g [name arg &rest code]
  `(do
     (defn ~name ~arg
     ~@(lfor p code (q-exp-g2--deep p)))
     (defn/a ~(symbol_2symbola name) ~arg
     ~@(lfor p code (q-exp-g2a-deep p))
     ))
  )




