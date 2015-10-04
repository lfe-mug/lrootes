(defmodule unit-rootes-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")
(include-lib "lrootes/include/routing.lfe")

(deftest handle-segment
  (is-equal "id" (rootes:handle-segment "id"))
  (is-equal 'id (rootes:handle-segment ":id")))

(deftest parse-patch
  (is-equal '() (rootes:parse-path ""))
  (is-equal '() (rootes:parse-path "/"))
  (is-equal '() (rootes:parse-path ""))
  (is-equal '("child") (rootes:parse-path "/child"))
  (is-equal '("child") (rootes:parse-path "/child/"))
  (is-equal '("child" cid) (rootes:parse-path "/child/:cid"))
  (is-equal '("parent" "child") (rootes:parse-path "/parent/child"))
  (is-equal '("parent" pid "child" cid )
            (rootes:parse-path "/parent/:pid/child/:cid"))
  (is-equal '("gparent" gpid "parent" pid "child" cid )
            (rootes:parse-path "/gparent/:gpid/parent/:pid/child/:cid")))

(deftest split-params
  (is-equal 1 1))