open Globals
open EvalValue

module Deque = struct
	let create () = {
		dvalues = [];
		dmutex = Mutex.create();
	}

	let add this i =
		Mutex.lock this.dmutex;
		this.dvalues <- this.dvalues @ [i];
		Mutex.unlock this.dmutex

	let pop this blocking =
		if not blocking then begin
			Mutex.lock this.dmutex;
			match this.dvalues with
			| v :: vl ->
				this.dvalues <- vl;
				Mutex.unlock this.dmutex;
				Some v
			| [] ->
				Mutex.unlock this.dmutex;
				None
		end else begin
			(* Optimistic first attempt with immediate lock. *)
			Mutex.lock this.dmutex;
			begin match this.dvalues with
			| v :: vl ->
				this.dvalues <- vl;
				Mutex.unlock this.dmutex;
				Some v
			| [] ->
				Mutex.unlock this.dmutex;
				(* First attempt failed, let's be pessimistic now to avoid locks. *)
				let rec loop () =
					Thread.yield();
					match this.dvalues with
					| v :: vl ->
						(* Only lock if there's a chance to have a value. This avoids high amounts of unneeded locking. *)
						Mutex.lock this.dmutex;
						(* We have to check again because the value could be gone by now. *)
						begin match this.dvalues with
						| v :: vl ->
							this.dvalues <- vl;
							Mutex.unlock this.dmutex;
							Some v
						| [] ->
							Mutex.unlock this.dmutex;
							loop()
						end
					| [] ->
						loop()
				in
				loop()
			end
		end

	let push this i =
		Mutex.lock this.dmutex;
		this.dvalues <- i :: this.dvalues;
		Mutex.unlock this.dmutex
end

module ThreadsStorage : sig
	val find : Thread.t -> vthread
	val remove : Thread.t -> unit
	val alloc : ?preprocess:(vthread -> unit) -> Thread.t -> vthread
	val find_or_alloc : Thread.t -> vthread
end = struct
	let storage = ref []
	let id_counter = ref 0

	let find t =
		let id = Thread.id t in
		List.find (fun thread -> id = thread.tid) !storage

	let rec remove id passed rest =
		match rest with
		| [] -> storage := passed
		| thread :: rest ->
			if thread.tid = id then storage := passed @ rest
			else remove id (thread :: passed) rest

	let remove t =
		remove (Thread.id t) [] !storage

	let alloc ?preprocess t =
		let id = !id_counter in
		incr id_counter;
		let thread = {
			tthread = t;
			tstorage = IntMap.empty;
			tid = id;
			tevents = vnull;
			tdeque = Deque.create();
		} in
		Option.may (fun f -> f thread) preprocess;
		storage := thread :: !storage;
		thread

	let find_or_alloc t =
		try find t
		with Not_found -> alloc t
end

let current () = ThreadsStorage.find_or_alloc (Thread.self())