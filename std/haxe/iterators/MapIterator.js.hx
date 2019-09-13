package haxe.iterators;

import haxe.ds.EnumValueMap;
import haxe.ds.HashMap;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.WeakMap;

class MapEnumValueIterator {
	static public inline function iterator<K:EnumValue, V>(m:EnumValueMap<K,V>) {
		return m.iterator();
	}

	static public inline function keys<K:EnumValue, V>(m:EnumValueMap<K,V>) {
		return m.keys();
	}
}

class MapHashIterator {
	static public inline function iterator<K:{function hashCode():Int;}, V>(m:HashMap<K,V>) {
		return m.iterator();
	}

	static public inline function keys<K:{function hashCode():Int;}, V>(m:HashMap<K,V>) {
		return m.keys();
	}
}

class MapIntIterator {
	static public inline function iterator<V>(m:IntMap<V>) {
		return @:privateAccess m.typedIterator();
	}

	static public inline function keys<V>(m:IntMap<V>) {
		return new KeyIterator(@:privateAccess m.arrayKeys());
	}
}

class MapObjectIterator {
	static public inline function iterator<K:{}, V>(m:ObjectMap<K,V>) {
		return @:privateAccess m.typedIterator();
	}

	static public inline function keys<K:{}, V>(m:ObjectMap<K,V>) {
		return new KeyIterator(@:privateAccess m.arrayKeys());
	}
}

class MapStringIterator {
	static public inline function iterator<V>(m:StringMap<V>) {
		return @:privateAccess m.typedIterator();
	}

	static public inline function keys<V>(m:StringMap<V>) {
		return new KeyIterator(@:privateAccess m.arrayKeys());
	}
}

class MapWeakIterator {
	static public inline function iterator<K:{}, V>(m:WeakMap<K, V>) {
		return m.iterator();
	}

	static public inline function keys<K:{}, V>(m:WeakMap<K, V>) {
		return m.keys();
	}
}

private class KeyIterator<T> {
	final keys:Array<T>;
	var current:Int = 0;

	public inline function new(keys:Array<T>) {
		this.keys = keys;
	}

	public inline function hasNext():Bool {
		return keys.length > current;
	}

	public inline function next():T {
		return keys[current++];
	}
}