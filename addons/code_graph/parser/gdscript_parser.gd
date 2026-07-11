class_name GDScriptParser extends RefCounted

class ScriptContent extends RefCounted:
	var classname: String = ""
	var parent_class: String = ""
	var properties: Array = []
	var signals: Array = []
	var methods: Array = []


static func parse_file(file_path: String) -> ScriptContent:
	var script_content := ScriptContent.new()
	var script: Script = ResourceLoader.load(file_path, "Script", ResourceLoader.CACHE_MODE_IGNORE)
	
	print_debug(file_path)
	print_debug(script)
	
	script_content.classname = script.get_global_name()
	script_content.properties = script.get_script_property_list()
	script_content.signals = script.get_script_signal_list()
	script_content.methods = script.get_script_method_list()
	
	return script_content
