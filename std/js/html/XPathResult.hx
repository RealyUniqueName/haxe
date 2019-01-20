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

// This file is generated from mozilla\XPathResult.webidl. Do not edit!

package js.html;

/**
	The `XPathResult` interface represents the results generated by evaluating an XPath 1.0 expression within the context of a given node.

	Documentation [XPathResult](https://developer.mozilla.org/en-US/docs/Web/API/XPathResult) by [Mozilla Contributors](https://developer.mozilla.org/en-US/docs/Web/API/XPathResult$history), licensed under [CC-BY-SA 2.5](https://creativecommons.org/licenses/by-sa/2.5/).

	@see <https://developer.mozilla.org/en-US/docs/Web/API/XPathResult>
**/
@:native("XPathResult")
extern class XPathResult
{
	static inline var ANY_TYPE : Int = 0;
	static inline var NUMBER_TYPE : Int = 1;
	static inline var STRING_TYPE : Int = 2;
	static inline var BOOLEAN_TYPE : Int = 3;
	static inline var UNORDERED_NODE_ITERATOR_TYPE : Int = 4;
	static inline var ORDERED_NODE_ITERATOR_TYPE : Int = 5;
	static inline var UNORDERED_NODE_SNAPSHOT_TYPE : Int = 6;
	static inline var ORDERED_NODE_SNAPSHOT_TYPE : Int = 7;
	static inline var ANY_UNORDERED_NODE_TYPE : Int = 8;
	static inline var FIRST_ORDERED_NODE_TYPE : Int = 9;
	
	
	/**
		integer (short)
	**/
	var resultType(default,null) : Int;
	
	/**
		float
	**/
	var numberValue(default,null) : Float;
	
	/**
		String
	**/
	var stringValue(default,null) : String;
	
	/**
		boolean
	**/
	var booleanValue(default,null) : Bool;
	
	/**
		Node
	**/
	var singleNodeValue(default,null) : Node;
	
	/**
		boolean
	**/
	var invalidIteratorState(default,null) : Bool;
	
	/**
		Integer
	**/
	var snapshotLength(default,null) : Int;
	
	
	/**
		...
		@throws DOMError
	**/
	function iterateNext() : Node;
	
	/**
		...
		@throws DOMError
	**/
	function snapshotItem( index : Int ) : Node;
}