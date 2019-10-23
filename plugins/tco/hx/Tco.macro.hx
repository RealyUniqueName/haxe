import haxe.PosInfos;

using haxe.io.Path;

typedef TcoPluginApi = {
	function register():Void;
}

class Tco {
	/** Access plugin API */
	static public var plugin(get,never):TcoPluginApi;

	static var _plugin:TcoPluginApi;
	static function get_plugin():TcoPluginApi {
		if(_plugin == null) {
			try {
				_plugin = eval.vm.Context.loadPlugin(getPluginPath());
			} catch(e:Dynamic) {
				throw 'Failed to load plugin: $e';
			}
		}
		return _plugin;
	}

	static function getPluginPath():String {
		var currentFile = (function(?p:PosInfos) return p.fileName)();
		var srcDir = currentFile.directory().directory();
		return Path.join([srcDir, 'cmxs', Sys.systemName(), 'plugin.cmxs']);
	}

	static public function register() {
		plugin.register();
	}
}