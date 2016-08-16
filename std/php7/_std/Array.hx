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
import php7.NativeArray;

@:coreApi
@:native("HxArray")
class Array<T> {
	public var length(default, null):Int;
	var arr:NativeArrayI<T>;

	public function new() {
		arr = new NativeArrayI<T>();
		length = 0;
	}

	public function concat(a:Array<T>):Array<T> {
		return wrap(arr.merge(a.arr));
	}

	public function copy():Array<T> {
		return wrap(arr);
	}

	public function filter(f:T->Bool):Array<T> {
		return wrap(arr.filter(f));
	}

	public function indexOf(x:T, ?fromIndex:Int):Int {
		if (fromIndex == null) fromIndex = 0;
		while (fromIndex < length) {
			if (arr[fromIndex] == x)
				return fromIndex;
			fromIndex++;
		}
		return -1;
	}

	public function insert(pos:Int, x:T):Void {
		length++;
		arr.splice(pos, 0, x);
	}

	public function iterator():Iterator<T> {
		return null; //TODO
	}

	public function join(sep:String):String {
		return arr.implode(sep);
	}

	public function lastIndexOf(x:T, ?fromIndex:Int):Int {
		if (fromIndex == null) fromIndex = length;
		while (fromIndex >= 0) {
			if (arr[fromIndex] == x)
				return fromIndex;
			fromIndex--;
		}
		return -1;
	}

	public function map<S>(f:T->S):Array<S> {
		return wrap(arr.map(f));
	}

	public function pop():Null<T> {
		if (length > 0) length--;
		return arr.pop();
	}

	public function push(x:T):Int {
		return length = arr.push(x);
	}

	public function remove(x:T):Bool {
		for (i in 0...length) {
			if (arr[i] == x) {
				arr.splice(i, 1);
				length--;
				return true;
			}
		}
		return false;
	}

	public function reverse():Void {
		arr = arr.reverse();
	}

	public function shift():Null<T> {
		if (length > 0) length--;
		return arr.shift();
	}

	public function slice(pos:Int, ?end:Int):Array<T> {
		return wrap(arr.slice(pos, end == null ? null : end - pos));
	}

	public function sort(f:T->T->Int):Void {
		arr.usort(f);
	}

	public function splice(pos:Int, len:Int):Array<T> {
		return wrap(arr.splice(pos, len));
	}

	public function unshift(x:T):Void {
		length = arr.unshift(x);
	}

	public function toString():String {
		return "array"; //TODO
	}

	static function wrap<T>(arr:NativeArrayI<T>):Array<T> {
		var a = new Array();
		a.arr = arr;
		a.length = arr.count();
		return a;
	}

}
