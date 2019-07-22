package unit.issues;

class Issue6503 extends unit.Test {
	function test() {
		voidJob(() -> ("hi":Dynamic));
		noAssert();
	}

	static function voidJob(cb:()->Void) {}
}