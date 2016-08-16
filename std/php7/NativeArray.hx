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

import haxe.extern.Rest;
import haxe.extern.EitherType;

//@:coreType
abstract NativeArray<T>(Dynamic) {
  public inline function count():Int
    return Arr.count(this);

  public inline function filter(cb:T->Bool):NativeArray<T>
    return Arr.filter(this, cb);

  public inline function implode(glue:String):String
    return Arr.implode(glue, this);

  public inline function map<S>(cb:T->S):NativeArray<S>
    return Arr.map(cb, this);

  public inline function merge(arr:NativeArray<T>):NativeArray<T>
    return Arr.merge(this, arr);

  public inline function pop():T
    return Arr.pop(this);

  public inline function push(val:T):Int
    return Arr.push(this, val);

  public inline function reverse():NativeArray<T>
    return Arr.reverse(this);

  public inline function shift():T
    return Arr.shift(this);

  public inline function slice(offset:Int, ?len:Int):NativeArray<T>
    return Arr.slice(this, offset, len);

  public inline function splice(offset:Int, len:Int, ?repl:T):NativeArray<T>
    return Arr.splice(this, offset, len, repl);

  public inline function unshift(val:T):Int
    return Arr.unshift(this, val);

  public inline function usort(func:T->T->Int):Bool
    return Arr.usort(this, func);

  @:to inline function toIndexedArray():NativeArrayI<T>
    return cast this;
}

@:forward
abstract NativeArrayI<T>(NativeArray<T>) {
  public inline function new()
    this = Arr.create();

  @:to inline function toNativeArray():NativeArray<T>
    return this;

  @:to inline function toHaxeArray():Array<T>
    return @:privateAccess Array.wrap(this);

  @:from static inline function fromHaxeArray<T>(a:Array<T>):NativeArrayI<T>
    return @:privateAccess a.arr;

  @:arrayAccess inline function get(idx:Int):T
    return untyped this[idx];

  @:arrayAccess inline function set(idx:Int, val:T)
    untyped this[idx] = val;
}

@:phpGlobal
private extern class Arr {
  @:native("array")
  static function create<T>():NativeArray<T>;

  @:native("\\count")
  static function count<T>(arr:NativeArray<T>, ?mode:Int = 0):Int;

  @:native("\\array_filter")
  static function filter<T>(arr:NativeArray<T>, cb:T->Bool, ?flag:Int = 0):NativeArray<T>;

  @:native("\\implode")
  static function implode<T>(glue:String = "", arr:NativeArray<T>):String;

  @:native("\\array_map")
  static function map<T,S>(cb:T->S, arr:NativeArray<T>):NativeArray<S>;

  @:native("\\array_merge")
  static function merge<T>(arr1:NativeArray<T>, arrN:Rest<NativeArray<T>>):NativeArray<T>;

  @:native("\\array_pop")
  static function pop<T>(arr:NativeArray<T>):T;

  @:native("\\array_push")
  static function push<T>(arr:NativeArray<T>, val:T):Int;

  @:native("\\array_reverse")
  static function reverse<T>(arr:NativeArray<T>, ?pres:Bool = false):NativeArray<T>;

  @:native("\\array_shift")
  static function shift<T>(arr:NativeArray<T>):T;

  @:native("\\array_slice")
  static function slice<T>(arr:NativeArray<T>, offset:Int, ?len:Int, ?pres:Bool=false):NativeArray<T>;

  @:native("\\array_splice")
  static function splice<T>(arr:NativeArray<T>, offset:Int, ?len:Int = 0,
    ?repl:EitherType<T,NativeArray<T>>):NativeArray<T>;

  @:native("\\array_unshift")
  static function unshift<T>(arr:NativeArray<T>, val:Rest<T>):Int;

  @:native("\\usort")
  static function usort<T>(arr:NativeArray<T>, func:T->T->Int):Bool;
}
