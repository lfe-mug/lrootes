(defmacro in (item collection)
  `(orelse ,@(lists:map (lambda (x) `(=== ,x ,item)) collection)))

(defmacro not-in (item collection)
  `(not (in ,item ,collection)))

(defun loaded-lrootes-predicates ()
  "This is just a dummy function for display purposes when including from the
  REPL (the last function loaded has its name printed in stdout).

  This function needs to be the last one in this include."
  'ok)
