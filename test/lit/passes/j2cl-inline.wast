;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; NOTE: In real world example  no-inline would use _<once>_ but there is escaping problem in a multi-platform
;; way in lit so we are working around it by using no-inline with a different pattern that matches same method.
;; RUN: foreach %s %t wasm-opt --no-inline=*clinit* --optimize-j2cl --inlining --vacuum --optimize-level=3 -all -S -o - | filecheck %s

;; Only trivial once functions are inlined
(module

  ;; A once function that has become empty
  (func $clinit-trivial-1_<once>_@Foo  )

  ;; A once function that just calls another
  (func $clinit-trivial-2_<once>_@Bar
    (call $clinit-trivial-1_<once>_@Foo)
  )

  ;; CHECK:      (type $0 (func))

  ;; CHECK:      (global $$class-initialized@Zoo (mut i32) (i32.const 0))
  (global $$class-initialized@Zoo (mut i32) (i32.const 0))

  ;; Not hoisted but trivial.
  ;; CHECK:      (func $clinit-non-trivial_<once>_@Zoo (type $0)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $$class-initialized@Zoo)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $$class-initialized@Zoo
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $clinit-non-trivial_<once>_@Zoo
    (if (global.get $$class-initialized@Zoo)
     (return)
    )
    (global.set $$class-initialized@Zoo (i32.const 1))
  )

  ;; CHECK:      (func $main (type $0)
  ;; CHECK-NEXT:  (call $clinit-non-trivial_<once>_@Zoo)
  ;; CHECK-NEXT: )
  (func $main
    (call $clinit-trivial-1_<once>_@Foo)
    (call $clinit-trivial-2_<once>_@Bar)
    (call $clinit-non-trivial_<once>_@Zoo)
  )
)
