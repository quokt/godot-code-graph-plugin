@tool
class_name CodeGraph extends GraphEdit


func refresh() -> void:
	clear_nodes()
	for file_path in find_gd_files("res://"):
		var content = ScriptParser.parse_file(file_path)
		add_graph_node(content)


func clear_nodes() -> void:
	for node: Node in get_children():
		if node is GraphNode:
			node.queue_free()


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


func add_graph_node(content: ScriptParser.ScriptContent) -> void:
	var new_graph_node := GraphNode.new()
	add_child(new_graph_node)
	new_graph_node.title = content.classname
	
	for _enum in content.enums:
		add_graph_node_label(new_graph_node, str(_enum["name"], ": ", _enum["members"]))
	
	new_graph_node.add_child(HSeparator.new())
	
	for constant in content.constants:
		add_graph_node_label(new_graph_node, str(constant["name"], ": ", type_string(constant["type"]), " = ", constant["value"]))
	
	new_graph_node.add_child(HSeparator.new())
	
	for property in content.properties:
		add_graph_node_label(new_graph_node, str(property["name"], ": ", type_string(property["type"])))
	
	new_graph_node.add_child(HSeparator.new())
	
	for method in content.methods:
		add_graph_node_label(new_graph_node, str(method["name"], ": ", type_string(method["return"]["type"])))


func add_graph_node_label(graph_node: GraphNode, label_text: String) -> void:
		var label := Label.new()
		label.text = label_text
		graph_node.add_child(label)
