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
	var graph_node_dictionary: Dictionary = {}
	add_child(new_graph_node)

	var count: int = 0
	
	new_graph_node.title = content.classname if content.classname else content.script_name
	graph_nodes[new_graph_node] = []
	
	for enum_name in content.enums.keys():
		var graph_node_member_info := GraphNodeMemberInfo.new()
		graph_node_member_info.index = count
		graph_node_member_info.member_name = enum_name
		graph_node_member_info.member_type = Variant.Type.TYPE_NIL
		graph_node_member_info.label_text = str(enum_name, ": ", content.enums[enum_name])
		add_graph_node_member(new_graph_node, graph_node_member_info)
		count += 1
	
	for constant_name in content.constants.keys():
		var graph_node_member_info := GraphNodeMemberInfo.new()
		graph_node_member_info.index = count
		graph_node_member_info.member_name = constant_name
		graph_node_member_info.member_type = content.constants[constant_name]["type"] as Variant.Type
		graph_node_member_info.label_text = str(constant_name, ": ", type_string(content.constants[constant_name]["type"]), " = ", content.constants[constant_name]["value"])
		add_graph_node_member(new_graph_node, graph_node_member_info)
		count += 1
	
	for property in content.properties:
		var graph_node_member_info := GraphNodeMemberInfo.new()
		graph_node_member_info.index = count
		graph_node_member_info.member_name = property["name"]
		graph_node_member_info.member_type = property["type"] as Variant.Type
		graph_node_member_info.label_text = str(property["name"], ": ", type_string(property["type"]))
		add_graph_node_member(new_graph_node, graph_node_member_info)
		count += 1
	
	for _signal in content.signals:
		var graph_node_member_info := GraphNodeMemberInfo.new()
		graph_node_member_info.index = count
		graph_node_member_info.member_name = _signal["name"]
		graph_node_member_info.member_type = Variant.Type.TYPE_SIGNAL
		graph_node_member_info.label_text = str(_signal["name"])
		add_graph_node_member(new_graph_node, graph_node_member_info)
		count += 1
	
	for method in content.methods:
		var graph_node_member_info := GraphNodeMemberInfo.new()
		graph_node_member_info.index = count
		graph_node_member_info.member_name = method["name"]
		graph_node_member_info.member_type = method["return"]["type"] as Variant.Type
		graph_node_member_info.label_text = str(method["name"], ": ", type_string(method["return"]["type"]))
		add_graph_node_member(new_graph_node, graph_node_member_info)
		count += 1
	
	add_slots(new_graph_node)

func add_graph_node_member(graph_node: GraphNode, graph_node_member_info: GraphNodeMemberInfo) -> void:
		var label := Label.new()
		label.text = graph_node_member_info.label_text
		graph_node.add_child(label)
		graph_nodes[graph_node].append(graph_node_member_info)
