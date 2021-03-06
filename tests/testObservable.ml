open OUnit2

let test_of_enum _ =
  let items = ["one"; "two"; "three"] in
  let observable =
    Rx.Observable.CurrentThread.of_enum @@ BatList.enum items in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = observable observer in
  assert_equal items @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_count _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let length_observable =
    Rx.Observable.length observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = length_observable observer in
  assert_equal [3] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_drop _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_next "d";
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let drop_2_observable =
    Rx.Observable.drop 2 observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = drop_2_observable observer in
  assert_equal ["c"; "d"] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_take _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_next "d";
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let take_2_observable = Rx.Observable.take 2 observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = take_2_observable observer in
  assert_equal ["a"; "b"] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_take_last _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_next "d";
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let take_last_2_observable =
    Rx.Observable.take_last 2 observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = take_last_2_observable observer in
  assert_equal ["c"; "d"] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_materialize _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_next "d";
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let materialized_observable =
    Rx.Observable.materialize observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = materialized_observable observer in
  assert_equal [
    RxCore.OnNext "a";
    RxCore.OnNext "b";
    RxCore.OnNext "c";
    RxCore.OnNext "d";
    RxCore.OnCompleted] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_materialize_error _ =
  let observable =
    (fun (_, on_error, on_next) ->
      on_next "a";
      on_next "b";
      on_next "c";
      on_next "d";
      on_error @@ Failure "test";
      Rx.Subscription.empty;
    ) in
  let materialized_observable =
    Rx.Observable.materialize observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = materialized_observable observer in
  assert_equal [
    RxCore.OnNext "a";
    RxCore.OnNext "b";
    RxCore.OnNext "c";
    RxCore.OnNext "d";
    RxCore.OnError (Failure "test")
  ] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_dematerialize _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next @@ RxCore.OnNext "a";
      on_next @@ RxCore.OnNext "b";
      on_next @@ RxCore.OnNext "c";
      on_next @@ RxCore.OnNext "d";
      on_next RxCore.OnCompleted;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let dematerialized_observable =
    Rx.Observable.dematerialize observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = dematerialized_observable observer in
  assert_equal ["a"; "b"; "c"; "d"] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_dematerialize_error _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next @@ RxCore.OnNext "a";
      on_next @@ RxCore.OnNext "b";
      on_next @@ RxCore.OnNext "c";
      on_next @@ RxCore.OnNext "d";
      on_next @@ RxCore.OnError (Failure "test");
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let dematerialized_observable =
    Rx.Observable.dematerialize observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = dematerialized_observable observer in
  assert_equal ["a"; "b"; "c"; "d"] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_to_enum _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_next 3;
      on_next 4;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let enum = Rx.Observable.Blocking.to_enum observable in
  let xs = BatList.of_enum enum in
  assert_equal [1; 2; 3; 4] xs

let test_to_enum_error _ =
  let ex = Failure "test" in
  let observable =
    (fun (_, on_error, on_next) ->
      on_next 1;
      on_next 2;
      on_next 3;
      on_next 4;
      on_error ex;
      Rx.Subscription.empty;
    ) in
  try
    let enum = Rx.Observable.Blocking.to_enum observable in
    let _ = BatList.of_enum enum in
    assert_failure "Should raise an exception"
  with e ->
    assert_equal ex e

let test_single _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let single_observable = Rx.Observable.single observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = single_observable observer in
  assert_equal [1] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_single_too_many_elements _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let single_observable = Rx.Observable.single observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = single_observable observer in
  assert_equal [] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_single_empty _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let single_observable = Rx.Observable.single observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = single_observable observer in
  assert_equal [] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_single_blocking _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let value = Rx.Observable.Blocking.single observable in
  assert_equal 1 value

let test_single_blocking_empty _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_completed ();
      Rx.Subscription.empty;
    ) in
  try
    let _ = Rx.Observable.Blocking.single observable in
    assert_failure "Should raise an exception"
  with e ->
    assert_equal (Failure "Sequence contains no elements") e

let test_of_list _ =
  let items = ["one"; "two"; "three"] in
  let of_list xs =
    Rx.Observable.CurrentThread.of_enum @@ BatList.enum xs in
  assert_equal 3
    Rx.Observable.(
      items |> of_list |> length |> Blocking.single
    );
  assert_equal "two"
    Rx.Observable.(
      items |> of_list |> drop 1 |> take 1 |> Blocking.single
    );
  assert_equal "three"
    Rx.Observable.(
      items |> of_list |> take_last 1 |> Blocking.single
    )

let test_append _ =
  let o1 =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let o2 =
    (fun (on_completed, _, on_next) ->
      on_next 3;
      on_next 4;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let append_observable = Rx.Observable.append o1 o2 in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = append_observable observer in
  assert_equal [1; 2; 3; 4] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_append_error _ =
  let o1 =
    (fun (_, on_error, on_next) ->
      on_next 1;
      on_next 2;
      on_error @@ Failure "test";
      Rx.Subscription.empty;
    ) in
  let o2 =
    (fun (on_completed, _, on_next) ->
      on_next 3;
      on_next 4;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let append_observable = Rx.Observable.append o1 o2 in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = append_observable observer in
  assert_equal [1; 2] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_map _ =
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_next 3;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let map_observable =
    Rx.Observable.map (fun x -> x * 2) observable in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = map_observable observer in
  assert_equal [2; 4; 6] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_return _ =
  let observable = Rx.Observable.return 42 in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = observable observer in
  assert_equal [42] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_merge_synchronous _ =
  let o1 =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let o2 =
    (fun (on_completed, _, on_next) ->
      on_next 3;
      on_next 4;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let o =
    (fun (on_completed, _, on_next) ->
      on_next o1;
      on_next o2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let merge_observable = Rx.Observable.merge o in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = merge_observable observer in
  assert_equal [1; 2; 3; 4] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_merge_child_error_synchronous _ =
  let o1 =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let o2 =
    (fun (_, on_error, on_next) ->
      on_next 3;
      on_next 4;
      on_error @@ Failure "test";
      Rx.Subscription.empty;
    ) in
  let o =
    (fun (on_completed, _, on_next) ->
      on_next o1;
      on_next o2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let merge_observable = Rx.Observable.merge o in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = merge_observable observer in
  assert_equal [1; 2; 3; 4] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_merge_parent_error_synchronous _ =
  let o1 =
    (fun (on_completed, _, on_next) ->
      on_next 1;
      on_next 2;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let o =
    (fun (_, on_error, on_next) ->
      on_next o1;
      on_error @@ Failure "test";
      Rx.Subscription.empty;
    ) in
  let merge_observable = Rx.Observable.merge o in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = merge_observable observer in
  assert_equal [1; 2] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_bind _ =
  let f v =
    (fun (on_completed, _, on_next) ->
      begin match v with
      | 42 ->
          on_next "42";
          on_next "Answer to the Ultimate Question of Life, \
                   the Universe, and Everything"
      | n ->
          on_next @@ string_of_int n
      end;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 41;
      on_next 42;
      on_next 43;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let bind_observable = Rx.Observable.bind observable f in
  let (observer, state) = TestHelper.Observer.create () in
  let _ = bind_observable observer in
  assert_equal [
    "41";
    "42";
    "Answer to the Ultimate Question of Life, the Universe, and Everything";
    "43"] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_empty _ =
  let (observer, state) = TestHelper.Observer.create () in
  let _ = Rx.Observable.empty observer in
  assert_equal [] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_error _ =
  let (observer, state) = TestHelper.Observer.create () in
  let _ = Rx.Observable.error (Failure "test") observer in
  assert_equal [] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal true @@ TestHelper.Observer.is_on_error state

let test_never _ =
  let (observer, state) = TestHelper.Observer.create () in
  let _ = Rx.Observable.never observer in
  assert_equal [] @@ TestHelper.Observer.on_next_values state;
  assert_equal false @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_subscribe_on_this _ =
  let (observer, state) = TestHelper.Observer.create () in
  let schedule_count = ref 0 in
  let module Scheduler = struct
    type t = unit
    let now () = 0.0
    let schedule_absolute ?due_time action =
      incr schedule_count;
      Rx.Scheduler.Immediate.schedule_absolute ?due_time action
    let schedule_relative _ _ = Rx.Subscription.empty
    let schedule_recursive _ = Rx.Subscription.empty
    let schedule_periodically ?initial_delay _ _ = Rx.Subscription.empty
  end in
  let module ScheduledObservable = Rx.Observable.MakeScheduled(Scheduler) in
  let observable =
    (fun (on_completed, _, on_next) ->
      on_next 42;
      on_completed ();
      Rx.Subscription.empty;
    ) in
  let scheduled_observable =
    ScheduledObservable.subscribe_on_this observable in
  let unsubscribe = scheduled_observable observer in
  assert_equal 1 !schedule_count;
  unsubscribe ();
  assert_equal 2 !schedule_count;
  assert_equal [42] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let test_with_test_scheduler _ =
  let (observer, state) = TestHelper.Observer.create () in
  let interval = Rx.Observable.Test.interval 1.0 in
  let observable = Rx.Observable.take 5 interval in
  let _ = observable observer in
  Rx.Scheduler.Test.advance_time_to 5.0;
  assert_equal [0;1;2;3;4] @@ TestHelper.Observer.on_next_values state;
  assert_equal true @@ TestHelper.Observer.is_completed state;
  assert_equal false @@ TestHelper.Observer.is_on_error state

let suite = "Observable tests" >:::
  ["test_of_enum" >:: test_of_enum;
   "test_count" >:: test_count;
   "test_drop" >:: test_drop;
   "test_take" >:: test_take;
   "test_take_last" >:: test_take_last;
   "test_materialize" >:: test_materialize;
   "test_materialize_error" >:: test_materialize_error;
   "test_dematerialize" >:: test_dematerialize;
   "test_dematerialize_error" >:: test_dematerialize_error;
   "test_to_enum" >:: test_to_enum;
   "test_to_enum_error" >:: test_to_enum_error;
   "test_single" >:: test_single;
   "test_single_too_many_elements" >:: test_single_too_many_elements;
   "test_single_empty" >:: test_single_empty;
   "test_single_blocking" >:: test_single_blocking;
   "test_single_blocking_empty" >:: test_single_blocking_empty;
   "test_of_list" >:: test_of_list;
   "test_append" >:: test_append;
   "test_append_error" >:: test_append_error;
   "test_map" >:: test_map;
   "test_return" >:: test_return;
   "test_merge_synchronous" >:: test_merge_synchronous;
   "test_merge_child_error_synchronous" >::
     test_merge_child_error_synchronous;
   "test_merge_parent_error_synchronous" >::
     test_merge_parent_error_synchronous;
   "test_bind" >:: test_bind;
   "test_empty" >:: test_empty;
   "test_error" >:: test_error;
   "test_never" >:: test_never;
   "test_subscribe_on_this" >:: test_subscribe_on_this;
   "test_with_test_scheduler" >:: test_with_test_scheduler;
  ]

