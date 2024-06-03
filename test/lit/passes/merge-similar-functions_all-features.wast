;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; RUN: foreach %s %t wasm-opt --all-features --merge-similar-functions -S -o - | filecheck %s

(module
  ;; CHECK:      (type $0 (func))

  ;; CHECK:      (type $"[i8]" (array i8))
  (type $"[i8]" (array i8))

  ;; CHECK:      (type $2 (func (param arrayref)))

  ;; CHECK:      (type $3 (func (param (ref eq))))

  ;; CHECK:      (func $take-ref-null-array (type $2) (param $0 arrayref)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $take-ref-null-array (param (ref null array))
    (unreachable)
  )
  ;; CHECK:      (func $take-ref-eq (type $3) (param $0 (ref eq))
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  (func $take-ref-eq (param (ref eq))
    (unreachable)
  )

  ;; NOTE: When type A is a subtype of type B and type C,
  ;; and func X takes a type B arg, and func Y takes a type C arg.
  ;; Then both func X and Y are callable with a type A arg.
  ;; But in general, type B and C don't have a common subtype, so
  ;; we can't merge call instructions of func X and Y.

  ;; CHECK:      (func $no-call-subtyping-same-operand-0 (type $0)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (call $take-ref-null-array
  ;; CHECK-NEXT:   (array.new_fixed $"[i8]" 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $no-call-subtyping-same-operand-0
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (call $take-ref-null-array
      (array.new_fixed $"[i8]" 0)
    )
  )
  ;; CHECK:      (func $no-call-subtyping-same-operand-1 (type $0)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (call $take-ref-eq
  ;; CHECK-NEXT:   (array.new_fixed $"[i8]" 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $no-call-subtyping-same-operand-1
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (call $take-ref-eq
      (array.new_fixed $"[i8]" 0)
    )
  )
)

;; Test that we can merge properly when there is a return_call.
(module
  ;; CHECK:      (type $0 (func (result i32)))

  ;; CHECK:      (type $1 (func (param (ref $0)) (result i32)))

  ;; CHECK:      (elem declare func $return_a $return_b)

  ;; CHECK:      (func $return_call_a (type $0) (result i32)
  ;; CHECK-NEXT:  (call $byn$mgfn-shared$return_call_a
  ;; CHECK-NEXT:   (ref.func $return_a)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $return_call_a (result i32)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (return_call $return_a)
  )

  ;; CHECK:      (func $return_call_b (type $0) (result i32)
  ;; CHECK-NEXT:  (call $byn$mgfn-shared$return_call_a
  ;; CHECK-NEXT:   (ref.func $return_b)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $return_call_b (result i32)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    (nop) (nop) (nop) (nop) (nop) (nop)
    ;; As above, but now use a return_call.
    (return_call $return_b)
  )

  ;; CHECK:      (func $return_a (type $0) (result i32)
  ;; CHECK-NEXT:  (i32.const 0)
  ;; CHECK-NEXT: )
  (func $return_a (result i32)
    ;; Helper function.
    (i32.const 0)
  )

  ;; CHECK:      (func $return_b (type $0) (result i32)
  ;; CHECK-NEXT:  (i32.const 1)
  ;; CHECK-NEXT: )
  (func $return_b (result i32)
    ;; Helper function.
    (i32.const 1)
  )
)
;; CHECK:      (func $byn$mgfn-shared$return_call_a (type $1) (param $0 (ref $0)) (result i32)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (nop)
;; CHECK-NEXT:  (return_call_ref $0
;; CHECK-NEXT:   (local.get $0)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )
