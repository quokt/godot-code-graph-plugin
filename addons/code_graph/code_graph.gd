@tool
class_name CodeGraph extends GraphEdit

var exclude_dirs: Array = [".", "..", "addons"]

var graph_nodes: Dictionary[GraphNode, Array] = {}

class GDFileInfo extends RefCounted:
	var path: String = ""
	var file_name: String = ""

class GraphNodeMemberInfo extends RefCounted:
	var index: int
	var member_name: String
	var member_type: Variant.Type
	var label_text: String


func refresh() -> void:
	clear_nodes()
	for file_info in find_gd_files("res://"):
		var content = ScriptParser.parse_file(file_info)
		add_graph_node(content)
	print_debug(graph_nodes)


func clear_nodes() -> void:
	for node: Node in get_children():
		if node is GraphNode:
			node.queue_free()


func add_slots(graph_node: GraphNode) -> void:
	for graph_node_member_info: GraphNodeMemberInfo in graph_nodes[graph_node]:
		graph_node.set_slot(
			graph_node_member_info.index,
			true, graph_node_member_info.member_type, Color.WHITE,
			true, graph_node_member_info.member_type, Color.WHITE
			)
		


func find_gd_files(path: String) -> Array[GDFileInfo]:
	var files: Array[GDFileInfo] = []
	var dir := DirAccess.open(path)
	
	if not dir:
		return files
		
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		var gd_file_info := GDFileInfo.new()
		if dir.current_is_dir() and not file_name in exclude_dirs:
			files.append_array(find_gd_files(path.path_join(file_name)))
		elif file_name.ends_with(".gd"):
			gd_file_info.file_name = file_name
			gd_file_info.path = path.path_join(file_name)
			files.append(gd_file_info)
		file_name = dir.get_next()
		
	dir.list_dir_end()
	
	return files


func add_graph_node(content: ScriptParser.ScriptParserResult) -> void:
	var new_graph_node := GraphNode.new()
	add_child(new_graph_node)

	new_graph_node.title = content.classname if content.classname else content.script_name
	graph_nodes[new_graph_node] = []
	
	for enum_name in content.enums.keys():
		add_graph_node_member(
			new_graph_node, 
			enum_name, 
			TYPE_NIL, 
			str(enum_name, ": ", content.enums[enum_name])
			)
	
	for constant_name in content.constants.keys():
		var constant = content.constants[constant_name]
		add_graph_node_member(
			new_graph_node, 
			constant_name, 
			constant["type"] as Variant.Type, 
			str(constant_name, ": ", type_string(constant["type"]), " = ", 
			constant["value"]))
	
	for property in content.properties:
		add_graph_node_member(
			new_graph_node, 
			property["name"], property["type"] as Variant.Type, 
			str(property["name"], ": ", type_string(property["type"]))
			)
	
	for _signal in content.signals:
		add_graph_node_member(
			new_graph_node, 
			_signal["name"], 
			TYPE_SIGNAL, 
			str(_signal["name"])
			)
	
	for method in content.methods:
		add_graph_node_member(
			new_graph_node, 
			method["name"], 
			method["return"]["type"] as Variant.Type, 
			str(method["name"], ": ", type_string(method["return"]["type"]))
			)
	
	add_slots(new_graph_node)


func add_graph_node_member(graph_node: GraphNode, name: String, member_type: Variant.Type, label_text: String) -> void:
	var info := GraphNodeMemberInfo.new()
	info.index = graph_nodes[graph_node].size()
	info.member_name = name
	info.member_type = member_type
	info.label_text = label_text
	var label := Label.new()
	label.text = label_text
	graph_node.add_child(label)
	graph_nodes[graph_node].append(info)
