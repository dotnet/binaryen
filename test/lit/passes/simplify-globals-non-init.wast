;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; NOTE: This test was ported using port_passes_tests_to_lit.py and could be cleaned up.

;; RUN: foreach %s %t wasm-opt --simplify-globals -all -S -o - | filecheck %s

;; A global that is written its initial value in all subsequent writes can
;; remove those writes.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global-0 i32 (i32.const 0))
  (global $global-0 (mut i32) (i32.const 0))
  ;; CHECK:      (global $global-1 i32 (i32.const 1))
  (global $global-1 (mut i32) (i32.const 1))

  ;; CHECK:      (func $sets (type $none_=>_none)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $sets
    ;; All these writes can be turned into drops.

    (global.set $global-0 (i32.const 0))
    (global.set $global-0 (i32.const 0))

    (global.set $global-1 (i32.const 1))
    (global.set $global-1 (i32.const 1))
  )

  ;; CHECK:      (func $gets (type $none_=>_none)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $gets
    ;; Add gets to avoid other opts from removing the sets.
    (drop (global.get $global-0))
    (drop (global.get $global-1))
  )
)

;; As above, but now we write other values.
(module
  ;; CHECK:      (type $i32_=>_none (func (param i32)))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $global-0 (mut i32) (i32.const 0))
  (global $global-0 (mut i32) (i32.const 0))
  ;; CHECK:      (global $global-1 (mut i32) (i32.const 1))
  (global $global-1 (mut i32) (i32.const 1))

  ;; CHECK:      (func $sets (type $i32_=>_none) (param $unknown i32)
  ;; CHECK-NEXT:  (global.set $global-0
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $global-0
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $global-1
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $global-1
  ;; CHECK-NEXT:   (local.get $unknown)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $sets (param $unknown i32)
    (global.set $global-0 (i32.const 0))
    (global.set $global-0 (i32.const 1)) ;; a non-init value

    (global.set $global-1 (i32.const 1))
    (global.set $global-1 (local.get $unknown)) ;; a totally unknown value
  )

  ;; CHECK:      (func $gets (type $none_=>_none)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $global-0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $global-1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $gets
    (drop (global.get $global-0))
    (drop (global.get $global-1))
  )
)

;; Globals without constant initial values.
(module
  ;; An imported global.
  ;; CHECK:      (type $i32_=>_none (func (param i32)))

  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (import "env" "import_global" (global $global-0 i32))
  (import "env" "import_global" (global $global-0 i32))

  ;; A global that initializes with another global.
  ;; CHECK:      (global $global-1 (mut i32) (global.get $global-0))
  (global $global-1 (mut i32) (global.get $global-0))

  ;; CHECK:      (func $sets (type $i32_=>_none) (param $unknown i32)
  ;; CHECK-NEXT:  (global.set $global-1
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $sets (param $unknown i32)
    (global.set $global-1 (i32.const 1))
  )

  ;; CHECK:      (func $gets (type $none_=>_none)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $global-0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (global.get $global-1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $gets
    ;; Add gets to avoid other opts from removing the sets.
    (drop (global.get $global-0))
    (drop (global.get $global-1))
  )
)
