(defmodule rootes
  (export all))

(include-lib "lrootes/include/predicates.lfe")

(defun check-segment
  (((cons colon var-name)) (when (=:= colon #\:))
   (list_to_atom var-name))
  ((seg)
   seg))

(defun parse-path (path-string)
  (lists:map
   #'check-segment/1
   (string:tokens path-string "/")))

(defun rebuild-head
  (((list method path-string))
   `(,method ,(parse-path path-string) arg-data)))

(defun split-params (elements)
  "For each form passed, the last element is always the expression to
  execute; before it are the method, the path, and the data from YAWS.

  We need to re-form each route as a function head pattern and the
  expression (function to call or output to render) for that pattern."
  (let* (((cons tail rev-head) (lists:reverse elements))
         (head (lists:reverse rev-head)))
    (case (eval (car head))
      ('ALLOWONLY `((method p a) (when (not-in method ,(lists:nth 2 head)))
                    ,tail))
      ('NOTFOUND `((method path arg-data) ,tail))
      (_ `((,@(rebuild-head head)) ,tail)))))

(defun compile-routes (forms)
  (lists:map #'split-params/1 forms))