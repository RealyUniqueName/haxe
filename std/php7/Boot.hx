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


/**
	Various Haxe->PHP compatibility utilities
**/
@:keep
@:dox(hide)
class Boot {

	/**
		Initialization stuff
	**/
	static function __init__ () {
		trace('Boot.__init__');
	}

	/**
		Get Class<T> instance for PHP fully qualified class name (E.g. '\some\pack\MyClass')
		It's always the same instance for the same `phpClassName`
	*/
	public static function getClass (phpClassName:String) : HxClass {
		return HxClass.get(phpClassName);
	}

	/**
		Performs `left >>> right` operation
	 */
	public static function shiftRightUnsigned( left:Int, right:Int ) : Int {
		if (right == 0) {
			return left;
		} else if (left >= 0) {
			return (left >> right);
		} else {
			return (left >> right) & (0x7fffffff >> (right - 1));
		}
	}

	// /**
	// 	Access fields of dynamic things
	//  */
	// public static function dynamicFieldAccess( target:Dynamic, field:String ) : Dynamic {
	// 	if (field == 'length' && untyped __call__("is_string", target)) {
	// 		return untyped __call__("strlen", $target);
	// 	} else {
	// 		return untyped __php__("$target->$field");
	// 	}
	// }
}


/**
	Class<T> implementation for Haxe->PHP internals
*/
@:keep
@:dox(hide)
private class HxClass {
	@:protected
	static private var classes = new Map<String,HxClass>();

	@:protected
	var phpClassName : String;

	/**
		Get `HxClass` instance for specified PHP fully qualified class name (E.g. '\some\pack\MyClass')
	*/
	public static function get (phpClassName:String) : HxClass {
		var cls = classes.get(phpClassName);
		if (cls == null) {
			cls = new HxClass(phpClassName);
			classes.set(phpClassName, cls);
		}

		return cls;
	}

	@:protected
	private function new (phpClassName:String) : Void {
		this.phpClassName = phpClassName;
	}

	/**
		Implementation for `cast(value, Class<Dynamic>)`
		@throws HException if `value` cannot be casted to this type
	*/
	public function tryCast (value:Dynamic) : Dynamic {
		throw "Not implemented";
	}
}