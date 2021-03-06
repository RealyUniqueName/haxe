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
	inline function get_length():Int
		return this.length;

	@:from static public function of<T>(array:Array<T>):Rest<T> {
		return new Rest(@:privateAccess array.__a);
	}

	// @:from static public function ofNative<T>(collection:NativeRest<T>):Rest<T> {
	// 	var result:NativeRest<T>;
	// 	#if jvm
	// 		result = (cast collection:Object).clone();
	// 	#else
	// 		result = new NativeRest<T>(collection.length);
	// 		for(i in 0...collection.length)
	// 			result[i] = cast collection[i];
	// 	#end
	// 	return new Rest(result);
	// }

	inline function new(a:NativeRest<T>):Void
		this = a;

	/**
	 * JVM: implemented in genjvm
	 */
	static function createNative<T>(length:Int):NativeRest<T>
		return new NativeRest<T>(length);

	@:arrayAccess inline function get(index:Int):T
		return this[index];

	@:to public function toArray():Array<T> {
		return [for(i in 0...this.length) this[i]];
	}

	public inline function iterator():RestIterator<T>
		return new RestIterator<T>(this);

	public inline function keyValueIterator():RestKeyValueIterator<T>
		return new RestKeyValueIterator<T>(this);

	extern inline public function append(item:T):Rest<T> {
		return _append(createNative(this.length + 1), item);
	}

	function _append(result:NativeRest<T>, item:T):Rest<T> {
		System.arraycopy(this, 0, result, 0, this.length);
		result[this.length] = cast item;
		return new Rest(result);
	}

	extern inline public function prepend(item:T):Rest<T> {
		return _prepend(createNative(this.length + 1), item);
	}

	function _prepend(result:NativeRest<T>, item:T):Rest<T> {
		System.arraycopy(this, 0, result, 1, this.length);
		result[0] = cast item;
		return new Rest(result);
	}

	public function toString():String {
		return toArray().toString();
	}
}