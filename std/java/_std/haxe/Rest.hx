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

	@:from static inline public function of<T>(array:Array<T>):Rest<T> {
		return new Rest(@:privateAccess array.__a);
		// var native = @:privateAccess array.__a;
		// var result:NativeRest<T>;
		// #if jvm
		// 	result = (cast native:Object).clone();
		// #else
		// 	result = new NativeRest<T>(native.length);
		// 	for(i in 0...native.length)
		// 		result[i] = cast native[i];
		// #end
		// return new Rest(result);
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

	public function append(item:T):Rest<T> {
		// var result = createNative(this.length + 1);
		var result = new NativeRest<T>(this.length + 1);
		System.arraycopy(this, 0, result, 0, this.length);
		for(i in 0...this.length)
			result[i] = this[i];
		result[this.length] = item;
		return new Rest(result);
	}

	public function prepend(item:T):Rest<T> {
		var result = new NativeRest<T>(this.length + 1);
		System.arraycopy(this, 0, result, 1, this.length);
		result[0] = item;
		return new Rest(result);
	}

	public function toString():String {
		return toArray().toString();
	}
}