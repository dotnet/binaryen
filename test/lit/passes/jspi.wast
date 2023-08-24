;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s --jspi -all -S -o - | filecheck %s

(module

  ;; CHECK:      (type $0 (func (param externref f64) (result i32)))

  ;; CHECK:      (type $1 (func (param f64) (result i32)))

  ;; CHECK:      (type $2 (func (param externref i32) (result i32)))

  ;; CHECK:      (type $3 (func (param f64)))

  ;; CHECK:      (type $4 (func (param i32) (result i32)))

  ;; CHECK:      (type $5 (func (param i32)))

  ;; CHECK:      (type $6 (func (param externref i32)))

  ;; CHECK:      (import "js" "compute_delta" (func $import$compute_delta (type $0) (param externref f64) (result i32)))
  (import "js" "compute_delta" (func $compute_delta (param f64) (result i32)))
  ;; CHECK:      (import "js" "import_and_export" (func $import$import_and_export (type $2) (param externref i32) (result i32)))
  (import "js" "import_and_export" (func $import_and_export (param i32) (result i32)))
  ;; CHECK:      (import "js" "import_void_return" (func $import$import_void_return (type $6) (param externref i32)))
  (import "js" "import_void_return" (func $import_void_return (param i32)))
  ;; CHECK:      (global $suspender (mut externref) (ref.null noextern))

  ;; CHECK:      (export "update_state_void" (func $export$update_state_void))
  (export "update_state_void" (func $update_state_void))
  ;; CHECK:      (export "update_state" (func $export$update_state))
  (export "update_state" (func $update_state))
  ;; Test duplicating an export.
  ;; CHECK:      (export "update_state_again" (func $export$update_state))
  (export "update_state_again" (func $update_state))
  ;; Test that a name collision on the parameters is handled.
  ;; CHECK:      (export "update_state_param_collision" (func $export$update_state_param_collision))
  (export "update_state_param_collision" (func $update_state_param_collision))
  ;; Test function that is imported and exported.
  ;; CHECK:      (export "import_and_export" (func $export$import_and_export))
  (export "import_and_export" (func $import_and_export))


  ;; CHECK:      (func $update_state (type $1) (param $param f64) (result i32)
  ;; CHECK-NEXT:  (call $compute_delta
  ;; CHECK-NEXT:   (f64.sub
  ;; CHECK-NEXT:    (f64.const 1.1)
  ;; CHECK-NEXT:    (local.get $param)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $update_state (param $param f64) (result i32)
    (call $compute_delta (f64.sub (f64.const 1.1) (local.get $param)))
  )

  ;; CHECK:      (func $update_state_void (type $3) (param $0 f64)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (call $compute_delta
  ;; CHECK-NEXT:    (f64.const 1.1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $update_state_void (param f64)
    ;; This function doesn't return anything, but the JSPI pass should add a
    ;; fake return value to make v8 happy.
    (drop (call $compute_delta (f64.const 1.1)))
  )

  ;; CHECK:      (func $update_state_param_collision (type $1) (param $susp f64) (result i32)
  ;; CHECK-NEXT:  (call $update_state_param_collision
  ;; CHECK-NEXT:   (f64.sub
  ;; CHECK-NEXT:    (f64.const 1.1)
  ;; CHECK-NEXT:    (local.get $susp)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $update_state_param_collision (param $susp f64) (result i32)
    (call $update_state_param_collision (f64.sub (f64.const 1.1) (local.get $susp)))
  )
)
;; CHECK:      (func $export$update_state_void (type $0) (param $susp externref) (param $0 f64) (result i32)
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $susp)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (call $update_state_void
;; CHECK-NEXT:   (local.get $0)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (i32.const 0)
;; CHECK-NEXT: )

;; CHECK:      (func $export$update_state (type $0) (param $susp externref) (param $param f64) (result i32)
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $susp)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (call $update_state
;; CHECK-NEXT:   (local.get $param)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $export$update_state_param_collision (type $0) (param $susp_1 externref) (param $susp f64) (result i32)
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $susp_1)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (call $update_state_param_collision
;; CHECK-NEXT:   (local.get $susp)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $export$import_and_export (type $2) (param $susp externref) (param $0 i32) (result i32)
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $susp)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (call $import_and_export
;; CHECK-NEXT:   (local.get $0)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )

;; CHECK:      (func $compute_delta (type $1) (param $0 f64) (result i32)
;; CHECK-NEXT:  (local $1 externref)
;; CHECK-NEXT:  (local $2 i32)
;; CHECK-NEXT:  (local.set $1
;; CHECK-NEXT:   (global.get $suspender)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (local.set $2
;; CHECK-NEXT:   (call $import$compute_delta
;; CHECK-NEXT:    (global.get $suspender)
;; CHECK-NEXT:    (local.get $0)
;; CHECK-NEXT:   )
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $1)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (local.get $2)
;; CHECK-NEXT: )

;; CHECK:      (func $import_and_export (type $4) (param $0 i32) (result i32)
;; CHECK-NEXT:  (local $1 externref)
;; CHECK-NEXT:  (local $2 i32)
;; CHECK-NEXT:  (local.set $1
;; CHECK-NEXT:   (global.get $suspender)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (local.set $2
;; CHECK-NEXT:   (call $import$import_and_export
;; CHECK-NEXT:    (global.get $suspender)
;; CHECK-NEXT:    (local.get $0)
;; CHECK-NEXT:   )
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $1)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (local.get $2)
;; CHECK-NEXT: )

;; CHECK:      (func $import_void_return (type $5) (param $0 i32)
;; CHECK-NEXT:  (local $1 externref)
;; CHECK-NEXT:  (local.set $1
;; CHECK-NEXT:   (global.get $suspender)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (call $import$import_void_return
;; CHECK-NEXT:   (global.get $suspender)
;; CHECK-NEXT:   (local.get $0)
;; CHECK-NEXT:  )
;; CHECK-NEXT:  (global.set $suspender
;; CHECK-NEXT:   (local.get $1)
;; CHECK-NEXT:  )
;; CHECK-NEXT: )
