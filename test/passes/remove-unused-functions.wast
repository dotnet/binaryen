(module
  (memory 0)
  (start $start)
  (type $0 (func))
  (export "exported" $exported)
  (table 1 1 anyfunc)
  (elem (i32.const 0) $called_indirect)
  (func $start (type $0)
    (call $called0)
  )
  (func $called0 (type $0)
    (call $called1)
  )
  (func $called1 (type $0)
    (nop)
  )
  (func $called_indirect (type $0)
    (nop)
  )
  (func $exported (type $0)
    (call $called2)
  )
  (func $called2 (type $0)
    (call $called2)
    (call $called3)
  )
  (func $called3 (type $0)
    (call $called4)
  )
  (func $called4 (type $0)
    (call $called3)
  )
  (func $remove0 (type $0)
    (call $remove1)
  )
  (func $remove1 (type $0)
    (nop)
  )
  (func $remove2 (type $0)
    (call $remove2)
  )
  (func $remove3 (type $0)
    (call $remove4)
  )
  (func $remove4 (type $0)
    (call $remove3)
  )
)
