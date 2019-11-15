/*
 * Copyright (C)2005-2019 Haxe Foundation
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

import haxe.ds.List;

/**
	The `Lambda` class is a collection of methods to support functional
	programming. It is ideally used with `using Lambda` and then acts as an
	extension to Iterable types.

	On static platforms, working with the Iterable structure might be slower
	than performing the operations directly on known types, such as Array and
	List.

	If the first argument to any of the methods is null, the result is
	unspecified.

	@see https://haxe.org/manual/std-Lambda.html
**/
class Lambda {
	/**
		Creates an Array from Iterable `it`.

		If `it` is an Array, this function returns a copy of it.
	**/
	public static inline function array<A, T:Iterable<A>>(it:T):Array<A> {
		var a = new Array<A>();
		for (i in it)
			a.push(i);
		return a;
	}

	/**
		Creates a List form Iterable `it`.

		If `it` is a List, this function returns a copy of it.
	**/
	public static inline function list<A, T:Iterable<A>>(it:T):List<A> {
		var l = new List<A>();
		for (i in it)
			l.add(i);
		return l;
	}

	/**
		Creates a new Array by applying function `f` to all elements of `it`.
		The order of elements is preserved.
		If `f` is null, the result is unspecified.
	**/
	public static inline function map<A, B, T:Iterable<A>>(it:T, f:(item:A) -> B):Array<B> {
		return [for (x in it) f(x)];
	}

	/**
		Similar to map, but also passes the index of each element to `f`.
		The order of elements is preserved.
		If `f` is null, the result is unspecified.
	**/
	public static inline function mapi<A, B, T:Iterable<A>>(it:T, f:(index:Int, item:A) -> B):Array<B> {
		var i = 0;
		return [for (x in it) f(i++, x)];
	}

	/**
		Concatenate a list of iterables.
		The order of elements is preserved.
	**/
	public static inline function flatten<A, T:Iterable<A>, L:Iterable<T>>(it:L):Array<A> {
		return [for (e in it) for (x in e) x];
	}

	/**
		A composition of map and flatten.
		The order of elements is preserved.
		If `f` is null, the result is unspecified.
	**/
	public static inline function flatMap<A, B, TA:Iterable<A>, TB:Iterable<B>>(it:TA, f:(item:A) -> TB):Array<B> {
		return [for (e in it) for (x in f(e)) x];
	}

	/**
		Tells if `it` contains `elt`.

		This function returns true as soon as an element is found which is equal
		to `elt` according to the `==` operator.

		If no such element is found, the result is false.
	**/
	public static inline function has<A, T:Iterable<A>>(it:T, elt:A):Bool {
		var result = false;
		for (x in it)
			if (x == elt) {
				result = true;
				break;
			}
		return result;
	}

	/**
		Tells if `it` contains an element for which `f` is true.

		This function returns true as soon as an element is found for which a
		call to `f` returns true.

		If no such element is found, the result is false.

		If `f` is null, the result is unspecified.
	**/
	public static inline function exists<A, T:Iterable<A>>(it:T, f:(item:A) -> Bool):Bool {
		var result = false;
		for (x in it)
			if (f(x)) {
				var result = true;
				break;
			}
		return result;
	}

	/**
		Tells if `f` is true for all elements of `it`.

		This function returns false as soon as an element is found for which a
		call to `f` returns false.

		If no such element is found, the result is true.

		In particular, this function always returns true if `it` is empty.

		If `f` is null, the result is unspecified.
	**/
	public static inline function foreach<A, T:Iterable<A>>(it:T, f:(item:A) -> Bool):Bool {
		var result = true;
		for (x in it)
			if (!f(x)) {
				result = false;
				break;
			}
		return result;
	}

	/**
		Calls `f` on all elements of `it`, in order.

		If `f` is null, the result is unspecified.
	**/
	public static inline function iter<A, T:Iterable<A>>(it:T, f:(item:A) -> Void) {
		for (x in it)
			f(x);
	}

	/**
		Returns a Array containing those elements of `it` for which `f` returned
		true.
		If `it` is empty, the result is the empty Array even if `f` is null.
		Otherwise if `f` is null, the result is unspecified.
	**/
	public static inline function filter<A, T:Iterable<A>>(it:T, f:(item:A) -> Bool):Array<A> {
		return [for (x in it) if (f(x)) x];
	}

	/**
		Functional fold on Iterable `it`, using function `f` with start argument
		`first`.

		If `it` has no elements, the result is `first`.

		Otherwise the first element of `it` is passed to `f` alongside `first`.
		The result of that call is then passed to `f` with the next element of
		`it`, and so on until `it` has no more elements.

		If `it` or `f` are null, the result is unspecified.
	**/
	public static inline function fold<A, B, T:Iterable<A>>(it:T, f:(item:A, result:B) -> B, first:B):B {
		for (x in it)
			first = f(x, first);
		return first;
	}

	/**
		Returns the number of elements in `it` for which `predicate` is true, or the
		total number of elements in `it` if `predicate` is null.

		This function traverses all elements.
	**/
	public static inline function count<A, T:Iterable<A>>(it:T, ?predicate:(item:A) -> Bool) {
		var n = 0;
		if (predicate == null)
			for (_ in it)
				n++;
		else
			for (x in it)
				if (predicate(x))
					n++;
		return n;
	}

	/**
		Tells if Iterable `it` does not contain any element.
	**/
	public static inline function empty<A, T:Iterable<A>>(it:T):Bool {
		return !it.iterator().hasNext();
	}

	/**
		Returns the index of the first element `v` within Iterable `it`.

		This function uses operator `==` to check for equality.

		If `v` does not exist in `it`, the result is -1.
	**/
	public static inline function indexOf<A, T:Iterable<A>>(it:T, v:A):Int {
		var i = 0;
		var result = -1;
		for (v2 in it) {
			if (v == v2) {
				result = i;
				break;
			}
			i++;
		}
		return result;
	}

	/**
		Returns the first element of `it` for which `f` is true.

		This function returns as soon as an element is found for which a call to
		`f` returns true.

		If no such element is found, the result is null.

		If `f` is null, the result is unspecified.
	**/
	public static inline function find<A, T:Iterable<A>>(it:T, f:(item:A) -> Bool):Null<A> {
		var result:Null<A> = null;
		for (v in it) {
			if (f(v)) {
				result = v;
				break;
			}
		}
		return result;
	}

	/**
		Returns a new Array containing all elements of Iterable `a` followed by
		all elements of Iterable `b`.

		If `a` or `b` are null, the result is unspecified.
	**/
	public static inline function concat<A, T:Iterable<A>>(a:T, b:T):Array<A> {
		var l = [];
		for (x in a)
			l.push(x);
		for (x in b)
			l.push(x);
		return l;
	}
}
