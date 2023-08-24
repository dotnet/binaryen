;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --inlining --enable-gc-nn-locals -all -S -o - | filecheck %s

(module
 ;; CHECK:      (func $caller-nullable (type $0)
 ;; CHECK-NEXT:  (local $0 funcref)
 ;; CHECK-NEXT:  (block $__inlined_func$target-nullable
 ;; CHECK-NEXT:   (local.set $0
 ;; CHECK-NEXT:    (ref.null nofunc)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $caller-nullable
  ;; Call a function with a nullable local. After the inlining there will
  ;; be a new local in this function for the use of the inlined code, and also
  ;; we assign the null value to that local in the inlined block (which does
  ;; not matter much here, but in general if we had a loop that the inlined
  ;; block was inside of, that would be important to get the right behavior).
  (call $target-nullable)
 )

 (func $target-nullable
  (local $1 (ref null func))
 )

 ;; CHECK:      (func $caller-non-nullable (type $0)
 ;; CHECK-NEXT:  (local $0 (ref func))
 ;; CHECK-NEXT:  (block $__inlined_func$target-non-nullable$1
 ;; CHECK-NEXT:   (nop)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $caller-non-nullable
  ;; Call a function with a non-nullable local. After the inlining there will
  ;; be a new local in this function for the use of the inlined code. We do not
  ;; need to zero it out (such locals cannot be used before being set anyhow, so
  ;; no zero is needed; and we cannot set a zero anyhow as none exists for the
  ;; type).
  (call $target-non-nullable)
 )

 (func $target-non-nullable
  (local $1 (ref func))
 )
)
