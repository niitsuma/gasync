

(import [nose.tools [eq_  assert-equal assert-not-equal]])

(import  [gasync.core [*]])
(require [gasync.core [*]])

        
(import inspect)

(defn classobject-async-merge [cl cla import_async_func_names]
  (setv fndic
        (dfor fa (inspect.getmembers cla inspect.isroutine)
              :if (in (first fa) import_async_func_names)
              [(first fa) (get fa 1)]
              ))
  (print fndic)
  (for [n import_async_func_names]
    (setv na (+ n "/a"))
    (setattr
      cl
      (mangle na)
      (get fndic n) ))
  cl
  )

(defn severname2merged_obj [sname &optional [import_async_func_names ["fetch_trades" "fetch_order_book"]]]
  (import [ccxt.async_support :as ccxta])
  (import ccxt)
  (setv cl   ((getattr ccxt  sname))
        cla  ((getattr ccxta sname))
        clm (classobject-async-merge cl cla import_async_func_names))
  clm
  )


(defn test-ccxt1 []
  
  (setv import_async_func_names ["fetch_trades" "fetch_order_book"])

  (import [ccxt.async_support :as ccxta])
  (import ccxt)
  
  (setv bittrex 
        (ccxt.bittrex
          {"apiKey" "c5af1d0ceeaa4729ad87da1b05d9dfc3"
           "secret" "d055d8e47fdf4c3bbd0ec6c289ea8ffd"
           "verbose" False}))
  (setv bittrexa
        (ccxta.bittrex
          {"apiKey" "c5af1d0ceeaa4729ad87da1b05d9dfc3"
           "secret" "d055d8e47fdf4c3bbd0ec6c289ea8ffd"
           "verbose" False}))
 
  ;;(progn/a (await (bittrexa.fetch_order_book "BTC/USD"))) ;;;debug ok 

  (setv bittrex_merged (classobject-async-merge bittrex bittrexa import_async_func_names))
  
  (progn/a (bittrex_merged.fetch_order_book "BTC/USD"))
  
)


(defn test-ccxt-mult []
    (setv
      severs ["bittrex" "binance"]
      clms (dfor k  severs 
                 [k (severname2merged_obj k)]))
  (progn/a
    (map/a
      (fn/a [sname] (.fetch_order_book/a (get clms sname) "BTC/USDT" ))
      severs)
    )

  (list (map
      (fn [sname] (.fetch_order_book (get clms sname) "BTC/USDT" ))
      severs))

  (defn/g book_ft_mul [severs]
    (setv clms (dfor k severs [k (severname2merged_obj k)]))
    (list
      (map/g
      (fn/g [sname] (.fetch_order_book/g (get clms sname) "BTC/USDT" ))
      severs)
    ))

  ;;;async fetech
  (progn/a
    (book_ft_mul/a ["bittrex" "binance"] ))

  ;;simple fetch
  (book_ft_mul ["bittrex" "binance"] )
  
  )
  
