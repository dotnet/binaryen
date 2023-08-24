;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; NOTE: This test was ported using port_passes_tests_to_lit.py and could be cleaned up.

;; RUN: foreach %s %t wasm-opt --code-folding --enable-threads -S -o - | filecheck %s

(module
 ;; CHECK:      (type $0 (func))

 ;; CHECK:      (type $1 (func (result f32)))

 ;; CHECK:      (type $13 (func (param f32)))
 (type $13 (func (param f32)))
 (table 282 282 funcref)
 ;; CHECK:      (memory $0 1 1)
 (memory $0 1 1)
 ;; CHECK:      (table $0 282 282 funcref)

 ;; CHECK:      (func $0
 ;; CHECK-NEXT:  (block $label$1
 ;; CHECK-NEXT:   (if
 ;; CHECK-NEXT:    (i32.const 1)
 ;; CHECK-NEXT:    (block
 ;; CHECK-NEXT:     (block $label$3
 ;; CHECK-NEXT:      (call_indirect (type $13)
 ;; CHECK-NEXT:       (block $label$4
 ;; CHECK-NEXT:        (br $label$3)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:       (i32.const 105)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (nop)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $0
  (block $label$1
   (if
    (i32.const 1)
    (block $label$3
     (call_indirect (type $13)
      (block $label$4 (result f32) ;; but this type may change dangerously
       (nop) ;; fold this
       (br $label$3)
      )
      (i32.const 105)
     )
     (nop) ;; with this
    )
   )
  )
 )
 ;; CHECK:      (func $negative-zero (result f32)
 ;; CHECK-NEXT:  (if (result f32)
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:   (block $label$0 (result f32)
 ;; CHECK-NEXT:    (f32.const 0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (block $label$1 (result f32)
 ;; CHECK-NEXT:    (f32.const -0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $negative-zero (result f32)
  (if (result f32)
   (i32.const 0)
   (block $label$0 (result f32)
    (f32.const 0)
   )
   (block $label$1 (result f32)
    (f32.const -0)
   )
  )
 )
 ;; CHECK:      (func $negative-zero-b (result f32)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block $label$0 (result f32)
 ;; CHECK-NEXT:   (f32.const -0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $negative-zero-b (result f32)
  (if (result f32)
   (i32.const 0)
   (block $label$0 (result f32)
    (f32.const -0)
   )
   (block $label$1 (result f32)
    (f32.const -0)
   )
  )
 )
 ;; CHECK:      (func $negative-zero-c (result f32)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block $label$0 (result f32)
 ;; CHECK-NEXT:   (f32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $negative-zero-c (result f32)
  (if (result f32)
   (i32.const 0)
   (block $label$0 (result f32)
    (f32.const 0)
   )
   (block $label$1 (result f32)
    (f32.const 0)
   )
  )
 )
 ;; CHECK:      (func $break-target-outside-of-return-merged-code
 ;; CHECK-NEXT:  (block $label$A
 ;; CHECK-NEXT:   (if
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:    (block
 ;; CHECK-NEXT:     (block $label$B
 ;; CHECK-NEXT:      (if
 ;; CHECK-NEXT:       (unreachable)
 ;; CHECK-NEXT:       (br_table $label$A $label$B
 ;; CHECK-NEXT:        (unreachable)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (return)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (block
 ;; CHECK-NEXT:     (block $label$C
 ;; CHECK-NEXT:      (if
 ;; CHECK-NEXT:       (unreachable)
 ;; CHECK-NEXT:       (br_table $label$A $label$C
 ;; CHECK-NEXT:        (unreachable)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (return)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $break-target-outside-of-return-merged-code
  (block $label$A
   (if
    (unreachable)
    (block
     (block
      (block $label$B
       (if
        (unreachable)
        (br_table $label$A $label$B
         (unreachable)
        )
       )
      )
      (return)
     )
    )
    (block
     (block $label$C
      (if
       (unreachable)
       (br_table $label$A $label$C ;; this all looks mergeable, but $label$A is outside
        (unreachable)
       )
      )
     )
     (return)
    )
   )
  )
 )
 ;; CHECK:      (func $break-target-inside-all-good
 ;; CHECK-NEXT:  (block $folding-inner0
 ;; CHECK-NEXT:   (block $label$A
 ;; CHECK-NEXT:    (if
 ;; CHECK-NEXT:     (unreachable)
 ;; CHECK-NEXT:     (block
 ;; CHECK-NEXT:      (br $folding-inner0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (br $folding-inner0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block $label$B
 ;; CHECK-NEXT:   (if
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:    (br_table $label$B $label$B
 ;; CHECK-NEXT:     (unreachable)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (return)
 ;; CHECK-NEXT: )
 (func $break-target-inside-all-good
  (block $label$A
   (if
    (unreachable)
    (block
     (block
      (block $label$B
       (if
        (unreachable)
        (br_table $label$B $label$B
         (unreachable)
        )
       )
      )
      (return)
     )
    )
    (block
     (block $label$C
      (if
       (unreachable)
       (br_table $label$C $label$C ;; this all looks mergeable, and is, B ~~ C
        (unreachable)
       )
      )
     )
     (return)
    )
   )
  )
 )
 ;; CHECK:      (func $leave-inner-block-type
 ;; CHECK-NEXT:  (block $label$1
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (block $label$2
 ;; CHECK-NEXT:     (block
 ;; CHECK-NEXT:      (unreachable)
 ;; CHECK-NEXT:      (unreachable)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (br $label$1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (i32.const 1)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $leave-inner-block-type
  (block $label$1
   (drop
    (block $label$2 (result i32) ;; leave this alone (otherwise, if we make it unreachable, we need to do more updating)
     (br_if $label$2
      (unreachable)
      (unreachable)
     )
     (drop
      (i32.const 1)
     )
     (br $label$1)
    )
   )
   (drop
    (i32.const 1)
   )
  )
 )
)
(module
 ;; CHECK:      (type $0 (func (result i32)))

 ;; CHECK:      (memory $0 (shared 1 1))
 (memory $0 (shared 1 1))
 ;; CHECK:      (export "func_2224" (func $0))
 (export "func_2224" (func $0))
 ;; CHECK:      (func $0 (result i32)
 ;; CHECK-NEXT:  (local $var$0 i32)
 ;; CHECK-NEXT:  (if (result i32)
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:   (i32.load offset=22
 ;; CHECK-NEXT:    (local.get $var$0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (i32.atomic.load offset=22
 ;; CHECK-NEXT:    (local.get $var$0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $0 (result i32)
  (local $var$0 i32)
  (if (result i32)
   (i32.const 0)
   (i32.load offset=22
    (local.get $var$0)
   )
   (i32.atomic.load offset=22
    (local.get $var$0)
   )
  )
 )
)
(module
 ;; CHECK:      (type $0 (func))
 (type $0 (func))
 ;; CHECK:      (type $1 (func (param i32)))

 ;; CHECK:      (global $global$0 (mut i32) (i32.const 10))
 (global $global$0 (mut i32) (i32.const 10))
 ;; CHECK:      (func $determinism
 ;; CHECK-NEXT:  (block $folding-inner0
 ;; CHECK-NEXT:   (block
 ;; CHECK-NEXT:    (block $label$1
 ;; CHECK-NEXT:     (br_if $label$1
 ;; CHECK-NEXT:      (i32.const 1)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (br $folding-inner0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (block $label$2
 ;; CHECK-NEXT:     (br_if $label$2
 ;; CHECK-NEXT:      (i32.const 0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (if
 ;; CHECK-NEXT:      (global.get $global$0)
 ;; CHECK-NEXT:      (br $folding-inner0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (unreachable)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (if
 ;; CHECK-NEXT:     (global.get $global$0)
 ;; CHECK-NEXT:     (br $folding-inner0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (global.set $global$0
 ;; CHECK-NEXT:   (i32.sub
 ;; CHECK-NEXT:    (global.get $global$0)
 ;; CHECK-NEXT:    (i32.const 1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT: )
 (func $determinism (; 0 ;) (type $0)
  (block $label$1
   (br_if $label$1
    (i32.const 1)
   )
   (global.set $global$0
    (i32.sub
     (global.get $global$0)
     (i32.const 1)
    )
   )
   (unreachable)
  )
  (block $label$2
   (br_if $label$2
    (i32.const 0)
   )
   (if
    (global.get $global$0)
    (block
     (global.set $global$0
      (i32.sub
       (global.get $global$0)
       (i32.const 1)
      )
     )
     (unreachable)
    )
   )
   (unreachable)
  )
  (if
   (global.get $global$0)
   (block
    (global.set $global$0
     (i32.sub
      (global.get $global$0)
      (i32.const 1)
     )
    )
    (unreachable)
   )
  )
  (unreachable)
 )
 ;; CHECK:      (func $careful-of-the-switch (param $0 i32)
 ;; CHECK-NEXT:  (block $label$1
 ;; CHECK-NEXT:   (block $label$3
 ;; CHECK-NEXT:    (block $label$5
 ;; CHECK-NEXT:     (block $label$7
 ;; CHECK-NEXT:      (br_table $label$3 $label$7
 ;; CHECK-NEXT:       (i32.const 0)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (br $label$1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (block $label$8
 ;; CHECK-NEXT:     (br_table $label$3 $label$8
 ;; CHECK-NEXT:      (i32.const 0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (br $label$1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $careful-of-the-switch (param $0 i32)
  (block $label$1
    (block $label$3
      (block $label$5
       (block $label$7 ;;  this is block is equal to $label$8 when accounting for the internal 7/8 difference
        (br_table $label$3 $label$7 ;; the reference to $label$3 must remain valid, cannot hoist out of it!
         (i32.const 0)
        )
       )
       (br $label$1)
      )
      (block $label$8
       (br_table $label$3 $label$8
        (i32.const 0)
       )
      )
      (br $label$1)
    )
    (unreachable)
  )
 )
)

