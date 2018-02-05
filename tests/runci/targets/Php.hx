package runci.targets;

import sys.FileSystem;
import runci.System.*;
import runci.Config.*;

class Php {
	static public function getPhpDependencies(phpVersion:String = null) {
		var phpCmd = commandResult("php", ["-v"]);
		var phpVerReg = ~/PHP ([0-9]+\.[0-9]+)/i;
		var phpVer = if (phpVerReg.match(phpCmd.stdout))
			Std.parseFloat(phpVerReg.matched(1));
		else
			null;

		if (phpCmd.exitCode == 0 && phpVer != null && phpVer >= 7.0) {
			infoMsg('php ${phpVer} has already been installed.');
			return;
		}
		switch (systemName) {
			case "Linux":
				runCommand("phpenv", ["global", "7.0"], false, true);
			case "Mac":
				runCommand("brew", ["tap", "homebrew/homebrew-php"], true);
				runCommand("brew", ["install", "php71"], true);
			case "Windows":
				runCommand("cinst", ["php", "-version", "7.1.8", "-y"], true);
		}
		runCommand("php", ["-v"]);
	}

	static public function run(args:Array<String>) {
		haxelibInstall("utest");

		function test() {
			runCommand("haxe", ["compile-php.hxml"].concat(args));
			runCommand("php", ["bin/php/index.php"]);

			changeDirectory(sysDir);
			runCommand("haxe", ["compile-php.hxml"]);
			runCommand("php", ["bin/php/Main/index.php"]);
		}

		getPhpDependencies();
		switch(systemName) {
			case "Linux" if(ci == TravisCI):
				runCommand("phpenv", ["global", "7.0"], false, true);
				test();
				runCommand("phpenv", ["install", "7.1.13"], false, true);
				runCommand("phpenv", ["global", "7.1.13"], false, true);
				test();
				runCommand("phpenv", ["install", "7.2.1"], false, true);
				runCommand("phpenv", ["global", "7.2.1"], false, true);
				test();
			case _:
				test();
		}
	}
}