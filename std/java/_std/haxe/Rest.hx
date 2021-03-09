package haxe;

import haxe.iterators.RestIterator;
import haxe.iterators.RestKeyValueIterator;
import java.NativeArray;
import java.lang.System;
import java.lang.Object;
import java.util.Arrays;

private typedef NativeRest<T> = NativeArray<T>;

@:coreApi
abstract Rest<T>(NativeRest<T>) {
	public var length(get,never):Int;
	extern inline function get_length():Int
		return this.length;

	@:from extern inline static public function of<T>(array:Array<T>):Rest<T> {
		var r = new NativeRest<T>(array.length);
		for(i in 0...array.length)
			r[i] = array[i];
		return new Rest(r);
		// return new Rest(@:privateAccess array.__a);
	}

	extern inline function new(a:NativeRest<T>):Void
		this = a;

	@:arrayAccess extern inline function get(index:Int):T
		return this[index];

	@:to extern inline public function toArray():Array<T> {
		return [for(i in 0...this.length) this[i]];
	}

	extern inline public function iterator():RestIterator<T>
		return new RestIterator<T>(this);

	extern inline public function keyValueIterator():RestKeyValueIterator<T>
		return new RestKeyValueIterator<T>(this);

	extern inline public function append(item:T):Rest<T> {
		var result = new NativeRest<T>(this.length + 1);
		System.arraycopy(this, 0, result, 0, this.length);
		result[this.length] = item;
		return new Rest(result);
	}

	extern inline public function prepend(item:T):Rest<T> {
		var result = new NativeRest<T>(this.length + 1);
		System.arraycopy(this, 0, result, 1, this.length);
		result[0] = item;
		return new Rest(result);
	}

	extern inline public function toString():String {
		return inline toArray().toString();
	}
}