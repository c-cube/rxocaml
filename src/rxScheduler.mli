(* Internal module. (see Rx.Scheduler) *)

module type Base = sig
  type t

  val now : unit -> float

  val schedule_absolute :
    ?due_time:float -> (unit -> RxCore.subscription) ->
    RxCore.subscription

end

module type S = sig
  include Base

  val schedule_relative :
    float -> (unit -> RxCore.subscription) ->
    RxCore.subscription

  val schedule_recursive :
    ((unit -> RxCore.subscription) -> RxCore.subscription) ->
    RxCore.subscription

  val schedule_periodically :
    ?initial_delay:float -> float -> (unit -> RxCore.subscription) ->
    RxCore.subscription

end

module MakeScheduler :
  functor (BaseScheduler : Base) -> S

module CurrentThread : S

module Immediate : S

module NewThread : S

module Lwt : S

module Test : sig
  include S

  val now : unit -> float

  val trigger_actions : float -> unit

  val trigger_actions_until_now : unit -> unit

  val advance_time_to : float -> unit

  val advance_time_by : float -> unit

end

