@tool
extends Control

@onready var code_graph: CodeGraph = $CodeGraph


func _on_refresh_pressed() -> void:
	code_graph.clear_nodes()
	for file_path in find_gd_files("res://"):
		var content = ScriptParser.parse_file(file_path)
		code_graph.add_graph_node(content)
	

func find_gd_files(path: String) -> PackedStringArray:
	var files := PackedStringArray()
	var dir := DirAccess.open(path)
	
	if not dir:
		return files
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name in [".", "..", "addons"]:
			files.append_array(find_gd_files(path.path_join(file_name)))
		elif file_name.ends_with(".gd"):
			files.append(path.path_join(file_name))
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	return files
