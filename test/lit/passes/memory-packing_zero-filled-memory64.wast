;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: foreach %s %t wasm-opt --memory-packing -all --zero-filled-memory -S -o - | filecheck %s

(module
 (type (;0;) (func (param i64)))
 ;; CHECK:      (type $i64_=>_none (func (param i64)))

 ;; CHECK:      (import "env" "memory" (memory $0 i64 1 1))
 (import "env" "memory" (memory $0 i64 1 1))
 (data (i64.const 1024) "x")
 (data (i64.const 1023) "\00")
 (data $.tdata "\00\00\00\00\00\00\00\00")
 ;; CHECK:      (global $__mem_segment_drop_state (mut i32) (i32.const 0))

 ;; CHECK:      (data $0 (i64.const 1024) "x")

 ;; CHECK:      (func $__wasm_init_tls (type $i64_=>_none) (param $0 i64)
 ;; CHECK-NEXT:  (local $1 i64)
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (local.get $0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (global.get $__mem_segment_drop_state)
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (memory.fill
 ;; CHECK-NEXT:   (local.get $1)
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:   (i64.const 8)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $__wasm_init_tls (type 0) (param i64)
     (memory.init $.tdata
       (local.get 0)
       (i32.const 0)
       (i32.const 8)))
)
