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

(deftest compile-route
  (is-equal '(('GET () arg-data) "Home Page")
            (rootes:compile-route '('GET "/" "Home Page")))
  (is-equal '(('GET ("a-page") arg-data) "A Page")
            (rootes:compile-route '('GET "/a-page" "A Page")))
  (is-equal '(('PUT ("update" "thing" id) arg-data) "Updated.")
            (rootes:compile-route '('PUT "/update/thing/:id" "Updated.")))
  (is-equal '((method path arg-data) (when (not-in method ('GET 'POST 'PUT 'DELETE)))
              "Can't do that.")
            (rootes:compile-route
             '('ALLOWONLY ('GET 'POST 'PUT 'DELETE) "Can't do that.")))
  (is-equal '((method path arg-data) "404 func")
            (rootes:compile-route
             '('NOTFOUND "404 func")))
  )