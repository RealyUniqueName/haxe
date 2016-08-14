/*
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

private extern class NativeArray {}

abstract Array<T>(NativeArray) from NativeArray to NativeArray {
	
	public var length(get, never) : Int;
	inline function get_length() : Int
		return untyped __call__('count', this);

	public function new() : Void
		this = untyped __php__('[]');

	inline public function concat( a : Array<T> ) : Array<T>
		return untyped __call__('array_merge', this, a);

	inline public function join( sep : String ) : String
		return untyped __call__('implode', sep, this);

	inline public function pop() : Null<T>
		return untyped __call__('array_pop', this);
	
	inline public function push(x : T) : Int
		return untyped __call__('array_push', this, x);

	inline public function reverse() : Void
		untyped __call__('usort', this, function(a, b) return 0);

	inline public function shift() : Null<T>
		return untyped __call__('array_shift', this);

	inline public function slice( pos : Int, ?end : Int ) : Array<T>
		return untyped __call__('array_slice', this, pos, end);

	inline public function sort( f : T -> T -> Int ) : Void
		untyped __call__('usort', this, f);

	inline public function splice( pos : Int, len : Int ) : Array<T>
		return untyped __call__('array_splice ', this, pos, len);

	inline public function toString() : String
		return untyped __call__('print_r', this, true);

	inline public function unshift( x : T ) : Void
		untyped __call__('array_unshift', this, x);
	
	inline public function insert( pos : Int, x : T ) : Void
		untyped __call__('array_splice', this, pos, 0, x);

	inline public function remove( x : T ) : Bool {
		var index = indexOf(x);
		if (index == -1) {
			return false;
		} else {
			splice(index, 1);
			return true;
		}
	}

	inline public function indexOf( x : T, ?fromIndex:Int ) : Int {
		var index = untyped __call__('array_search', x, this, true);
		return untyped __physeq__(index, false) ? -1 : index;
	}

	inline public function lastIndexOf( x : T, ?fromIndex:Int ) : Int {
		var key: Int;
		untyped __call__('end', this);
		while ((key = untyped __call__('key', this)) != null) {
			untyped __call__('prev', this);
			if (untyped __call__('current', this) == x) break;
		}
		return key == null ? -1 : key;
	}

	inline public function copy() : Array<T>
		return untyped __call__('array_merge', this, []);

	inline public function iterator() : Iterator<T>
		return new ArrayIterator<T>(this);

	inline public function map<S>( f : T -> S ) : Array<S>
		return untyped __call__('array_map', f, this);

	inline public function filter( f : T -> Bool ) : Array<T>
		return untyped __call__('array_filter', this, f);
		
}

private class ArrayIterator<T> {
	
	var array: Array<T>;
	var i: Int = 0;
	
	public function new(array: Array<T>)
		this.array = array;
	
	public function next(): T
		return array[i++];
		
	public function hasNext(): Bool
		return i < array.length;
	
}