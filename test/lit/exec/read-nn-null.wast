;; NOTE: Assertions have been generated by update_lit_checks.py --all-items --output=fuzz-exec and should not be edited.

;; RUN: wasm-opt %s      -all --coalesce-locals --optimize-instructions --fuzz-exec -q -o /dev/null 2>&1 | filecheck %s --check-prefix=NORMAL
;; RUN: wasm-opt %s -tnh -all --coalesce-locals --optimize-instructions --fuzz-exec -q -o /dev/null 2>&1 | filecheck %s --check-prefix=TNH

;; The sequence of passes here will do the following:
;;
;;  * coalesce-locals will remove the local.set. That does not reach any
;;    local.get due to the unreachable, so it is a dead store that we can
;;    remove.
;;  * optimize-instructions will reorder the select's arms (to get rid of the
;;    i32.eqz). It looks ok to reorder them because the local.get on one arm has
;;    no side effects at all.
;;
;; After those, if we did not fix up non-nullable locals in between, then we'd
;; end up executing a local.get of a non-nullable local that has no local.set,
;; which means we are reading a null by a non-nullable local - an internal
;; error. We avoid this situation by fixing up non-nullable locals in between
;; these passes, which adds a ref.as_non_null on the local.get, and that
;; possibly-trapping instruction will prevent dangerous reordering. In
;; particular, --fuzz-exec result should be identical before and after: always
;; log 42 and then trap on that unreachable.
;;
;; This also tests traps-never-happen mode. Atm that mode changes nothing here,
;; but that may change in the future as tnh starts to optimize more things. In
;; particular, tnh can in principle remove the ref.as_non_null that is added on
;; the local.get, which would then let optimize-instructions reorder - but that
;; will still not affect observable behavior, so it is fine.

(module
  (import "fuzzing-support" "log-i32" (func $log (param i32)))

  ;; NORMAL:      [fuzz-exec] calling foo
  ;; NORMAL-NEXT: [LoggingExternalInterface logging 42]
  ;; NORMAL-NEXT: [trap unreachable]
  ;; TNH:      [fuzz-exec] calling foo
  ;; TNH-NEXT: [LoggingExternalInterface logging 42]
  ;; TNH-NEXT: [trap unreachable]
  (func $foo (export "foo") (param $i i32) (result funcref)
    (local $ref (ref func))
    (local.set $ref
      (ref.func $foo)
    )
    (select (result funcref)
      (block $trap (result funcref)
        (call $log
          (i32.const 42)
        )
        ;; We never reach the br, but its existence makes the block's type none
        ;; instead of unreachable (optimization passes may ignore such
        ;; obviously-unreachable code, so we make it less obvious this way).
        (unreachable)
        (br $trap
          (ref.func $foo)
        )
      )
      (local.get $ref)
      (i32.eqz
        (local.get $i)
      )
    )
  )
)
;; NORMAL:      [fuzz-exec] calling foo
;; NORMAL-NEXT: [LoggingExternalInterface logging 42]
;; NORMAL-NEXT: [trap unreachable]
;; NORMAL-NEXT: [fuzz-exec] comparing foo

;; TNH:      [fuzz-exec] calling foo
;; TNH-NEXT: [LoggingExternalInterface logging 42]
;; TNH-NEXT: [trap unreachable]
;; TNH-NEXT: [fuzz-exec] comparing foo
