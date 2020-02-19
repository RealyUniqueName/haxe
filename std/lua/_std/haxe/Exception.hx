package haxe;

@:coreApi
class Exception {
	public var message(get,never):String;
	public var stack(get,never):CallStack;
	public var previous(get,never):Null<Exception>;
	public var native(get,never):Any;

	@:noCompletion var __exceptionMessage:String;
	@:noCompletion var __exceptionStack:Null<CallStack>;
	@:noCompletion var __nativeStack:Null<String>;
	@:noCompletion var __nativeException:Any;
	@:noCompletion var __previousException:Null<Exception>;

	static public function caught(value:Any):Exception {
		if(Std.is(value, Exception)) {
			return value;
		} else {
			return new ValueException(value, null, value);
		}
	}

	static public function thrown(value:Any):Any {
		if(Std.isOfType(value, Exception)) {
			return (value:Exception).native;
		} else {
			return new ValueException(value);
		}
	}

	public function new(message:String, ?previous:Exception, ?native:Any) {
		__exceptionMessage = message;
		__previousException = previous;
		if(native != null) {
			__nativeException = native;
			__nativeStack = CallStack.exception;
		} else {
			__nativeException = this;
			__nativeStack = lua.Debug.traceback(null, null, 2);
		}
	}

	public function unwrap():Any {
		return __nativeException;
	}

	public function toString():String {
		return inline CallStack.exceptionToString(this);
	}

	function get_message():String {
		return __exceptionMessage;
	}

	function get_previous():Null<Exception> {
		return __previousException;
	}

	final function get_native():Any {
		return __nativeException;
	}

	function get_stack():CallStack {
		return switch __exceptionStack {
			case null:
				__exceptionStack = switch __nativeStack {
					case null: [];
					case s: CallStack.makeStack(s);
				}
			case s: s;
		}
	}
}