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
package php7;

import haxe.extern.EitherType;

//@:coreType //doesn't seem to work atm
//@:arrayAccess
@:runtimeValue
abstract NativeArray(Dynamic) {
	public inline function new()
		this = untyped __php__("[]");

	@:arrayAccess
	inline function get(key:Scalar):Dynamic
		return this[key];

	@:arrayAccess
	inline function set(key:Scalar, val:Dynamic)
		this[key] = val;

	public inline function count():Int
		return Global.count(this);

	public inline function implode(glue:String):String
		return Global.implode(glue, this);

	public inline function merge(arr:NativeArray):NativeArray
		return Global.array_merge(this, arr);

	public inline function reverse():NativeArray
		return Global.array_reverse(this);

	public inline function slice(offset:Int, len:Int):NativeArray
		return Global.array_slice(this, offset, len);
}

private typedef Scalar = EitherType<Int,EitherType<String,EitherType<Float,Bool>>>;
