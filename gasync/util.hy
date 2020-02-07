
(import  [gasync.core [*]])
(require [gasync.core [*]])


(import inspect)

(defn merge-class-async-to-nonasync [cl cla
                          &optional import_async_func_names 
                                     ]
  
    (setv fndic
        (dfor fa (inspect.getmembers cla inspect.isroutine)
              :if
              (lif import_async_func_names
                   (in (first fa) import_async_func_names)
                   (not (.startswith (first fa) "_")))
                   [(first fa) (get fa 1)]
              ))
  ;;(print fndic)
  (for [n fndic]
    (setv na (+ n "/a"))
    (setattr cl (mangle na) (get fndic n) ))
  cl
  )



