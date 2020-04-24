package runci.targets;

import sys.FileSystem;
import runci.System.*;
import runci.Config.*;

class Macro {
	static public function run(args:Array<String>) {
		changeDirectory(miscDir);
		runCommand("haxe", ["compile.hxml"]);
	}
}