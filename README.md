gasync
========


[![Build Status](https://img.shields.io/travis/niitsuma/gasync/master.svg?style=flat-square)](https://travis-ci.org/niitsuma/gasync)
[![Downloads](https://pepy.tech/badge/gasync)](https://pepy.tech/project/gasync)
[![Version](https://img.shields.io/pypi/v/gasync.svg?style=flat-square)](https://pypi.python.org/pypi/gasync)


This library unify async and non-async functions in [Hy][hylang].

[hylang]: http://hylang.org/ "hylang"

Example
-------


```hy
(import  [gasync.core [*]])
(require [gasync.core [*]]) 

(import asyncio)
(import time)

(defn sleep_test [t]
  (time.sleep t)
  (print t))

(defn/a sleep_test/a [t] ;;async version function name must end with "/a" 
  (await (asyncio.sleep t))
  (print t))


;;; defn/g simultaneously defines sleep_map and sleep_map/a. sleep_map/a is async version of sleep_map.
(defn/g sleep_map [x]
    (sleep/g x) ;;generic sleep
    (sleep_test/g 0.2)  ;; In defn/g, function end with "/g" automatic swich to foo/a or foo.
    (list ;;since return of map is iterator 
	  (map/g sleep_test/g [x 2 1]) ) ;;map/g is generic pararel map
    (print "end"))
	
(sleep_map 3.5)
==> 
0.2
3.5 
2
1
end

(progn/a  ;; progn/a exec corutine
 (sleep_map/a 3.5)
 )
==> 
0.2
1 
2
3.5
end
```

Application to [ccxt][ccxt]

[ccxt]: https://github.com/ccxt/ccxt "ccxt"

```hy
;; merge ccxt.async_support  to single class
(defn classobject-async-merge [cl cla import_async_func_names]
  (setv fndic
        (dfor fa (inspect.getmembers cla inspect.isroutine)
              :if (in (first fa) import_async_func_names)
              [(first fa) (get fa 1)]
              ))
  (print fndic)
  (for [n import_async_func_names]
    (setv na (+ n "/a")) ;;merged async functions are renamed to foo/a
    (setattr
      cl
      (mangle na)
      (get fndic n) ))
  cl
  )

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
		   
(setv bittrex_merged (classobject-async-merge bittrex bittrexa import_async_func_names))

(print (bittrex_merged.fetch_order_book" BTC/USD")) ;;non async use
(print (progn/a (bittrex_merged.fetch_order_book/a "BTC/USD"))) ;;async use
		   
	   

;; mutilple merge async functions
(defn severname2merged_obj 
[sname &optional [import_async_func_names ["fetch_trades" "fetch_order_book"]]]
  (import [ccxt.async_support :as ccxta])
  (import ccxt)
  (setv cl   ((getattr ccxt  sname))
        cla  ((getattr ccxta sname))
        clm (classobject-async-merge cl cla import_async_func_names))
  clm
  )


(setv
  severs ["bittrex" "binance"]
  clms   (dfor k severs 
                 [k (severname2merged_obj k)]))

;;define generic async function
(defn/g book_ft_mul [severs]
    (setv clms (dfor k severs [k (severname2merged_obj k)]))
    (list
      (map/g
      (fn/g [sname] (.fetch_order_book/g (get clms sname) "BTC/USDT" ))
      severs)
    ))

;;async fetech
(progn/a
   (book_ft_mul/a ["bittrex" "binance"] ))

;;simple fetch
(book_ft_mul ["bittrex" "binance"]) 
  

```

Install
------
```bash
pip install gasync
```


License
-------

All the code is licensed under the GNU Affero General Public License
