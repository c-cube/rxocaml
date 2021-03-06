open OUnit2

let test_wait_graceful _ =
  let ok = ref false in
  let async_lock = RxAsyncLock.create () in
  RxAsyncLock.wait async_lock (fun () -> ok := true);
  assert_bool "ok should be true" !ok

let test_wait_fail _ =
  let l = RxAsyncLock.create () in
  let ex = Failure "test" in
  begin try
      RxAsyncLock.wait l (fun () -> raise ex );
      assert_failure "should raise an exception";
    with e ->
      assert_equal ex e
  end;
  RxAsyncLock.wait l (fun () -> assert_failure "l has faulted; should not run")

let test_wait_queues_work _ =
  let l = RxAsyncLock.create () in
  let l1 = ref false in
  let l2 = ref false in
  RxAsyncLock.wait l
    (fun () ->
       RxAsyncLock.wait l
         (fun () ->
           assert_bool "l1 should be true" !l1;
           l2 := true;
         );
       l1 := true;
    );
  assert_bool "l2 should be true" !l2

let test_dispose _ =
  let l = RxAsyncLock.create () in
  let l1 = ref false in
  let l2 = ref false in
  let l3 = ref false in
  let l4 = ref false in
  RxAsyncLock.wait l
    (fun () ->
       RxAsyncLock.wait l
         (fun () ->
            RxAsyncLock.wait l
              (fun () ->
                 l3 := true;
              );
            l2 := true;
            RxAsyncLock.dispose l;

            RxAsyncLock.wait l
              (fun () ->
                 l4 := true;
              );
         );

       l1 := true;
    );
  assert_bool "l1 should be true" !l1;
  assert_bool "l2 should be true" !l2;
  assert_equal false !l3;
  assert_equal false !l4

let suite = "Async lock tests" >:::
  ["test_wait_graceful" >:: test_wait_graceful;
   "test_wait_fail" >:: test_wait_fail;
   "test_wait_queues_work" >:: test_wait_queues_work;
   "test_dispose" >:: test_dispose;
  ]

