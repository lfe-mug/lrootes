# lrootes [![Build Status][travis-badge]][travis]

[![lrootes project logo][logo]][logo-large]

*Macros and functions for creating, combining, and composing routes for lmug apps*

**WARNING**: This project is in high-flux and is awaiting further developments in the lmug library.


##### Table of Contents

* [Introduction](#introduction-)
* [Dependences](#dependences-)
* [Installtion](#installtion-)
* [Usage](#usage-)
  * [Simple Example](#simple-example-)
  * [Combination Example](#combination-example-)
  * [REST Service Example](#rest-service-example-)
  * [YAWS Auth Example](#yaws-auth-example-)
  * [Fine-grained Access Example](#fine-grained-access-example-)
* [Concepts](#concepts-)
  * [How It Works](#how-it-works-)
  * [Behind the Scenes](#behind-the-scenes-)


## Introduction [&#x219F;](#table-of-contents)

Inspired by Clojure's [Compojure](https://github.com/weavejester/compojure)
and based on the original LFE-YAWS routing
work done in the [lfest](https://github.com/lfex/lfest) project, lrootes
improves upon its predecessor by focusing on route combination utilizing the same
principles as the Compojure project, principally by integrating the work of lmug.

lrootes accomplishes this by ensuring that routes are simply functions which
return [iolists](http://erlang.org/doc/reference_manual/typespec.html#id77856)
of data structures. The data strcutures represent an HTTP-verb+URL dispatch.
This allows lrootes routes to be composed (since they are functions) and keeps
the inner workings simple (because it's just ``iolist``s of tuples).


## Dependencies [&#x219F;](#table-of-contents)

This project assumes that you have Erlang and [rebars](https://github.com/erlang/rebar3),
and [lfetool]()


## Installation [&#x219F;](#table-of-contents)

Just add it to your ``rebar.config`` deps:

```erlang

{deps, [
    ...
    {lrootes, ".*", {git, "git@github.com:lfe-mug/lrootes.git", "master"}}
  ]}.
```

Then:

```bash
$ rebar3 compile
```


## Usage [&#x219F;](#table-of-contents)

### Simple Example [&#x219F;](#table-of-contents)

This shows bare minimum usage:

```lfe
(include-lib "lrootes/include/routing.lfe")

(defroutes webapp
  ('GET "/hello/world" (rootes-http:html-ok "Hello, World"))
  ('NOTFOUND
    (rootes-http:html-not-found "Page Not Found")))

(defapp (webapp))
```

### Combination Example [&#x219F;](#table-of-contents)

This shows a simple combination of routes:

```lfe
(include-lib "lrootes/include/routing.lfe")

(defroutes webapp
  ('GET "/hello/world" (rootes-http:html-ok "Hello, World"))
  ('NOTFOUND
    (rootes-http:html-not-found "Page Not Found")))

(defroutes api
  ('GET "/api/get-status" (rootes-http:html-ok "All systems go.")))

(makeapp
  (list (webapp)
        (api)))
```

There are several ways in which one may choose to combine routes for an app; the
above example shows the list constructor approach; the literal data approach is
an obvious alternative:

```lfe
(makeapp `(,(webapp)
           ,(api)))
```

Another option open to developers is to compose the routes:

```lfe
(makeapp (api (webapp)))
```

Or, if you're familiar with Clojure and enjoy using the LFE clj library, you can
use one of the threshing macros:

```lfe
(makeapp (-> (webapp)
             (api)))
```

### REST Service Example

```lfe
(include-lib "lrootes/include/routing.lfe")

(defroutes order-api
  ;; top-level
  ('GET "/"
    (lfest-html-resp:ok "Welcome to the Volvo Store!"))
  ;; single order operations
  ('POST "/order"
    (create-order (lfest:get-data arg-data)))
  ('GET "/order/:id"
    (get-order id))
  ('PUT "/order/:id"
    (update-order id (lfest:get-data arg-data)))
  ('DELETE "/order/:id"
    (delete-order id))
  ;; order collection operations
  ('GET "/orders"
    (get-orders))
  ;; payment operations
  ('GET "/payment/order/:id"
    (get-payment-status id))
  ('PUT "/payment/order/:id"
    (make-payment id (lfest:get-data arg-data)))
  ;; error conditions
  ('ALLOWONLY
    ('GET 'POST 'PUT 'DELETE)
    (lfest-json-resp:method-not-allowed))
  ('NOTFOUND
    (lfest-json-resp:not-found "Bad path: invalid operation.")))

(makeapp (order-api))
```

### YAWS Auth Example [&#x219F;](#table-of-contents)

With LFE releases 1.10.x and higher, you can define multiple modules in a
single file, thus allowing you to provide multiple ``appmods`` in a single
module. We can take advantage of this to succinctly define ``appmods`` that
are protected and those that are publicly accessible.

```lfe
TBD
```

### Fine-grained Access Example [&#x219F;](#table-of-contents)

```lfe
TBD
```

## Concepts [&#x219F;](#table-of-contents)


### How It Works [&#x219F;](#table-of-contents)

A few important things to note here:

* Each route is composed of an HTTP verb, a path, and a function to execute
  should both the verb and path match.
* The function call in the route has access to the ``arg-data`` passed from
  YAWS; this contains all the data you could conceivably need to process a
  request. (You may need to import the ``yaws_api.hrl`` in your module to
  parse the data of your choice, though.)
* If a path has a segment preceded by a colon, this will be converted to a
  variable by the ``(defroutes ...)`` macro; the variable will then be
  accessible from the function you provide in that route.
* The ``(defroutes ...)`` macro generates the ``routes/3`` function; it's
  three arguments are the HTTP verb (method name), the path info (a list of
  path segments, with the ``":varname"`` segments converted to ``varname``/
  variable segments), and then the ``arg-data`` variable from YAWS.

Notes for new library [this will be converted to content once implementation is done]:

* ``(defroutes ...)`` - deines a named function
* The routes function can take 0 or 1 arguments
* When called with zero arguments, the routes function will return an
  ``iolist`` of the routes defined by the function.
* When called with 1 argument, that argument must be another routes
  function or function that will return an ``iolist`` of routes
* To be usable by YAWS, the ``(makeapp ...)`` macro must be called in the
  module that is specified in the YAWS configuration with an ``appmods``
  directive
* The ``(makeapp ...)`` macro defines the ``out/1`` function which YAWS
  requires application modules to provide


### Behind the Scenes [&#x219F;](#table-of-contents)

lfest needs to provide YAWS with an ``out/1`` function. The location of this
function is configured in your ``etc/yaws.conf`` file in the
``<appmods ...>`` directives (it can be repeated for supporting multiple
endpoints).

YAWS will call this function with one argument: the YAWS ``arg`` record
data. Since this function is the entry point for applications running under
YAWS, it is responsible for determining how to process all requests.

The ``out/1`` function in lfest-based apps calls the ``routes/3`` function
generated by the ``(defroutes ...)`` mamcro.

The route definition macro does some pretty heavy remixing of the routes
defined in ``(defroutes ...)``. The route definition given in the "Usage"
section above actually expands to the following LFE before being compiled to
a ``.beam``:

```cl
 #((define-function routes
     (match-lambda
       (('GET () arg-data)
        (call 'lfest-html-resp 'ok "Welcome to the Volvo Store!"))
       (('POST ("order") arg-data)
        (create-order (call 'lfest 'get-data arg-data)))
       (('GET ("order" id) arg-data) (get-order id))
       (('PUT ("order" id) arg-data)
        (update-order id (call 'lfest 'get-data arg-data)))
       (('DELETE ("order" id) arg-data) (delete-order id))
       (('GET ("orders") arg-data) (get-orders))
       (('GET ("payment" "order" id) arg-data) (get-payment-status id))
       (('PUT ("payment" "order" id) arg-data)
        (make-payment id (call 'lfest 'get-data arg-data)))
       ((method p a)
        (when
         (not
          (if (call 'erlang '=:= 'GET method)
            'true
            (if (call 'erlang '=:= 'POST method)
              'true
              (if (call 'erlang '=:= 'PUT method)
                'true
                (call 'erlang '=:= 'DELETE method))))))
        (call 'lfest-json-resp 'method-not-allowed))
       ((method path arg-data)
        (call 'lfest-json-resp 'not-found "Bad path: invalid operation."))))
   6)
```

When it is compiled, the ``routes/3`` function is available for use from
wherever you have defined your routes.


<!-- Named page links below: /-->

[travis]: https://travis-ci.org/lfe-mug/lrootes
[travis-badge]: https://travis-ci.org/lfe-mug/lrootes.png?branch=master
[logo]: priv/images/lrootes-x250.png
[logo-large]: priv/images/lrootes-x1000.png

