(defmodule rootes-util
  (export all))

(defun get-lrootes-version ()
  (lutil:get-app-src-version "src/lrootes.app.src"))

(defun get-versions ()
  (++ (lutil:get-version)
      `(#(lrootes ,(get-lrootes-version)))))
