class_name ScriptParser extends RefCounted


class ScriptParserResult extends RefCounted:
	var script_name: String = ""
	var classname: String = ""
	var parent_class: String = ""
	var enums: Dictionary[String, Array] = {} #contains "name" and "members"
	var constants: Dictionary[String, Dictionary] = {} #contains "name", "type" and "value"
	var properties: Array[Dictionary] = []
	var signals: Array = []
	var methods: Array = []


class ConstantMapExtract extends RefCounted:
	var enums: Dictionary[String, Array] = {}
	var constants: Dictionary[String, Dictionary] = {}


static func parse_file(gd_file_info: CodeGraph.GDFileInfo) -> ScriptParserResult:
	var script_content := ScriptParserResult.new()
	var script: Script = ResourceLoader.load(gd_file_info.path, "Script", ResourceLoader.CACHE_MODE_IGNORE)
	
	script_content.script_name = gd_file_info.file_name
	script_content.classname = script.get_global_name()
	
	var constant_map_extract := get_constant_map_extract(script.get_script_constant_map())
	script_content.enums = constant_map_extract.enums
	script_content.constants = constant_map_extract.constants
	
	script_content.properties = script.get_script_property_list().filter(
		func(property): return (not property["name"] in script_content.enums.keys()) and not property["name"].ends_with(".gd")
	)
	
	script_content.signals = script.get_script_signal_list()
	
	script_content.methods = script.get_script_method_list()
	
	return script_content


static func get_constant_map_extract(constant_map: Dictionary) -> ConstantMapExtract:
	var constant_map_extract := ConstantMapExtract.new()
	for constant_name in constant_map:
		var constant_value = constant_map[constant_name]
		if typeof(constant_value) == TYPE_DICTIONARY and not constant_value.is_empty():
			#Filter dictionaries from enums using the type of dictionary values (enums are always int)
			var all_ints := true
			for member_value in constant_value.values():
				if typeof(member_value) != TYPE_INT:
					all_ints = false
					break
			if all_ints:
				constant_map_extract.enums[constant_name] = constant_value.keys()
				continue
		constant_map_extract.constants[constant_name] = {
			"type": typeof(constant_value), 
			"value": constant_value
			}
	
	return constant_map_extract
