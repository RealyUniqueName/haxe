package flash.globalization;

@:require(flash10_1) extern final class StringTools {
	var actualLocaleIDName(default,never) : String;
	var lastOperationStatus(default,never) : LastOperationStatus;
	var requestedLocaleIDName(default,never) : String;
	function new(requestedLocaleIDName : String) : Void;
	function toLowerCase(s : String) : String;
	function toUpperCase(s : String) : String;
	static function getAvailableLocaleIDNames() : flash.Vector<String>;
}
