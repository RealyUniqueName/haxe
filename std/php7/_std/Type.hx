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

import php7.Global;
import php7.Boot;
import php7.reflection.ReflectionClass;
import php7.reflection.ReflectionMethod;
import php7.reflection.ReflectionProperty;
import php7.NativeArray;
import haxe.extern.EitherType;

using php7.Global;

enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass( c : Class<Dynamic> );
	TEnum( e : Enum<Dynamic> );
	TUnknown;
}

@:coreApi class Type {

	public static function getClass<T>( o : T ) : Class<T> {
		if(Global.is_object(o) && !Boot.isClass(o) && !Boot.isEnumValue(o)) {
			return cast Boot.getClass(Global.get_class(cast o));
		} else if(Boot.is(o, cast String)) {
			return cast String;
		} else {
			return null;
		}
	}

	public static function getEnum( o : EnumValue ) : Enum<Dynamic> {
		if(o == null) return null;
		return cast Boot.getClass(Global.get_class(cast o));
	}

	public static function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic> {
		if(c == null) return null;
		var parentClass = Global.get_parent_class((cast c).phpClassName);
		if(!parentClass) return null;
		return cast Boot.getClass(parentClass);
	}

	public static function getClassName( c : Class<Dynamic> ) : String {
		if(c == null) return null;
		return Boot.getHaxeName(cast c);
	}

	public static function getEnumName( e : Enum<Dynamic> ) : String {
		return getClassName(cast e);
	}

	public static function resolveClass( name : String ) : Class<Dynamic> {
		if (name == null) return null;
		if (name == 'String') return String;

		var phpClass = Boot.getPhpName(name);
		if (!Global.class_exists(phpClass)) return null;

		var hxClass = Boot.getClass(phpClass);
		if (Boot.is(hxClass, Boot.getClass('Enum'))) return null;

		return cast hxClass;
	}

	public static function resolveEnum( name : String ) : Enum<Dynamic> {
		if (name == null) return null;

		var phpClass = Boot.getPhpName(name);
		if (!Global.class_exists(phpClass)) return null;

		var hxClass = Boot.getClass(phpClass);
		if (!Boot.is(hxClass, Boot.getClass('Enum'))) return null;

		return cast hxClass;
	}

	public static function createInstance<T>( cl : Class<T>, args : Array<Dynamic> ) : T {
		if (String == cast cl) return args[0];

		var phpName = getPhpName(cl);
		if (phpName == null) return null;

		return untyped __php__("new $phpName(...$args->arr)");
	}

	public static function createEmptyInstance<T>( cl : Class<T> ) : T {
		if (String == cast cl) return cast '';
		if (Array == cast cl) return cast [];

		var phpName = getPhpName(cl);
		if (phpName == null) return null;

		var reflection = new ReflectionClass(phpName);
		return reflection.newInstanceWithoutConstructor();
	}

	public static function createEnum<T>( e : Enum<T>, constr : String, ?params : Array<Dynamic> ) : T {
		if (e == null || constr == null) return null;

		var phpName = getPhpName(e);
		if (phpName == null) return null;

		if (params == null) {
			return untyped __php__("$phpName::$constr()");
		} else {
			return untyped __php__("$phpName::$constr(...$params->arr)");
		}
	}

	public static function createEnumIndex<T>( e : Enum<T>, index : Int, ?params : Array<Dynamic> ) : T {
		if (e == null || index == null) return null;

		var phpName = getPhpName(e);
		if (phpName == null) return null;

		var constr = untyped __php__("$phpName::__hx__list()[$index]");
		if (constr == null) return null;

		if (params == null) {
			return untyped __php__("$phpName::$constr()");
		} else {
			return untyped __php__("$phpName::$constr(...$params->arr)");
		}
	}

	public static function getInstanceFields( c : Class<Dynamic> ) : Array<String> {
		if (c == null) return null;
		if (c == String) {
			return [
				'substr', 'charAt', 'charCodeAt', 'indexOf',
				'lastIndexOf', 'split', 'toLowerCase',
				'toUpperCase', 'toString', 'length'
			];
		}

		var phpName = getPhpName(c);
		if (phpName == null) return null;

		var reflection = new ReflectionClass(phpName);

		var methods = new NativeArray();
		for (m in reflection.getMethods()) {
			var method:ReflectionMethod = m;
			if (!method.isStatic()) {
				var name = method.getName();
				if (!isServiceFieldName(name)) {
					methods.array_push(name);
				}
			}
		}

		var properties = new NativeArray();
		for (p in reflection.getProperties()) {
			var property:ReflectionProperty = p;
			if (!property.isStatic()) {
				var name = property.getName();
				if (!isServiceFieldName(name)) {
					properties.array_push(name);
				}
			}
		}
		properties = Global.array_diff(properties, methods);

		var fields = Global.array_merge(properties, methods);

		return @:privateAccess Array.wrap(fields);
	}

	public static function getClassFields( c : Class<Dynamic> ) : Array<String> {
		if (c == null) return null;
		if (c == String) return ['fromCharCode'];

		var phpName = getPhpName(c);
		if (phpName == null) return null;

		var reflection = new ReflectionClass(phpName);

		var methods = new NativeArray();
		for (m in reflection.getMethods(untyped __php__('\\ReflectionMethod::IS_STATIC'))) {
			var name = (m:ReflectionMethod).getName();
			trace(name);
			if (!isServiceFieldName(name)) {
				methods.array_push(name);
			}
		}

		var properties = new NativeArray();
		for (p in reflection.getProperties(untyped __php__('\\ReflectionProperty::IS_STATIC'))) {
			var name = (p:ReflectionProperty).getName();
			trace(name);
			if (!isServiceFieldName(name)) {
				properties.array_push(name);
			}
		}
		properties = Global.array_diff(properties, methods);

		var fields = Global.array_merge(properties, methods);

		return @:privateAccess Array.wrap(fields);
	}

	public static function getEnumConstructs( e : Enum<Dynamic> ) : Array<String> {
		if (e == null) return null;
		return @:privateAccess Array.wrap(untyped e.__hx__list());
	}

	public static function typeof( v : Dynamic ) : ValueType {
		if (v == null) return TNull;

		if (v.is_object()) {
			if (Reflect.isFunction(v)) return TFunction;
			if (untyped __php__("$v instanceof \\StdClass")) return TObject;
			if (Boot.isClass(v)) return TObject;

			var hxClass = Boot.getClass(Global.get_class(v));
			if (Boot.isEnumValue(v)) return TEnum(cast hxClass);
			return TClass(cast hxClass);
		}

		if (v.is_bool()) return TBool;
		if (v.is_int()) return TInt;
		if (v.is_float()) return TFloat;
		if (v.is_string()) return TClass(String);

		return TUnknown;
	}

	public static function enumEq<T>( a : T, b : T ) : Bool untyped {
		if( a == b )
			return true;
		try {
			if( a.index != b.index )
				return false;
			for( i in 0...__call__("count", a.params))
				if(getEnum(untyped __php__("$a->params[$i]")) != null) {
					if(!untyped enumEq(__php__("$a->params[$i]"),__php__("$b->params[$i]")))
						return false;
				} else {
					if(!untyped __call__("_hx_equal", __php__("$a->params[$i]"),__php__("$b->params[$i]")))
						return false;
				}
		} catch( e : Dynamic ) {
			return false;
		}
		return true;
	}

	public static function enumConstructor( e : EnumValue ) : String {
		return untyped e.tag;
	}

	public static function enumParameters( e : EnumValue ) : Array<Dynamic> untyped {
		if(e.params == null)
			return [];
		else
			return __php__("new _hx_array($e->params)");
	}

	public inline static function enumIndex( e : EnumValue ) : Int {
		return untyped e.index;
	}

	public static function allEnums<T>( e : Enum<T> ) : Array<T> {
		var all = [];
		for( c in getEnumConstructs(e) ) {
			var v = Reflect.field(e,c);
			if( !Reflect.isFunction(v) )
				all.push(v);
		}
		return all;
	}

	/**
		Get corresponding PHP name for specified `type`.
		Returns `null` if `type` does not exist.
	**/
	static function getPhpName( type:EitherType<Class<Dynamic>,Enum<Dynamic>> ) : Null<String> {
		var haxeName = Boot.getHaxeName(cast type);

		return (haxeName == null ? null : Boot.getPhpName(haxeName));
	}

	/**
		check if specified `name` is a special field name generated by compiler.
	 **/
	static inline function isServiceFieldName(name:String) : Bool {
		return (name == '__construct' || name.indexOf('__hx__') == 0);
	}
}

