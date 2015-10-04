(defmodule rootes
  (export all))

(include-lib "lrootes/include/predicates.lfe")

(defun handle-segment
  (((cons #\: var-name))
   (list_to_atom var-name))
  ((seg)
   seg))

(defun parse-path (path-string)
  (lists:map
   #'handle-segment/1
   (string:tokens path-string "/")))

(defun make-pattern-old
  ((`(,method ,path-string))
   `(,method ,(parse-path path-string) arg-data)))

(defun make-pattern (method path-string)
  `(,method ,(parse-path path-string) arg-data))

(defun compile-route-old (elements)
  "For each form passed, the last element is always the expression to
  execute; before it are the method, the path, and the data from YAWS.

  We need to re-form each route as a function head pattern and the
  expression (function to call or output to render) for that pattern."
  (let* (((cons tail rev-head) (lists:reverse elements))
         (head (lists:reverse rev-head)))
    (case (eval (car head))
      ('ALLOWONLY `((method path arg-data) (when (not-in method ,(lists:nth 2 head)))
                    ,tail))
      ('NOTFOUND `((method path arg-data) ,tail))
      (_ `((,@(make-pattern-old head)) ,tail)))))

(defun compile-route
  "For each form passed, the last element is always the expression to
  execute; before it are the method, the path, and the data from YAWS.

  We need to re-form each route as a function head pattern and the
  expression (function to call or output to render) for that pattern."
  ((`('ALLOWONLY ,methods ,expr))
   `((method path arg-data) (when (not-in method ,methods))
     ,expr))
  ((`('NOTFOUND ,expr))
    `((method path arg-data) ,expr))
  ((`(,method ,path ,expr))
   `((,@(make-pattern method path)) ,expr)))

(defun compile-routes (forms)
  (lists:map #'compile-route/1 forms))

(defun route->map (route)
  'noop)

(defun map->pattern
  ((`#m(http-verb ,verb
        path ,path
        func ,func))
   'noop))

(defun merge-routes (list-of-routes)
  (lists:flatten list-of-routes))

