(defmacro defroutes body
  `(defun routes ,@(rootes:compile-routes body)))

(defmacro makeapp body
  `(defun out (arg-data)
     (rootes-yaws:out-helper
       (rootes:merge-routes ,body))))

(defun loaded-lrootes-routing ()
  "This is just a dummy function for display purposes when including from the
  REPL (the last function loaded has its name printed in stdout).

  This function needs to be the last one in this include."
  'ok)
