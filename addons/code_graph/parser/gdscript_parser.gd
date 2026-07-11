extends RefCounted

class ScriptContent extends RefCounted:
	var properties: Array = []
	var export_properties: Array = []
	var references: Array = []
	var signals: Array = []
	var methods: Array = []

func parse_file(file_path: String) -> ScriptContent:
	var script_content := ScriptContent.new()
	return script_content
