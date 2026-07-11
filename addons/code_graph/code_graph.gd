@tool
class_name CodeGraph extends GraphEdit


func clear_nodes() -> void:
	for node: Node in get_children():
		if node is GraphNode:
			node.queue_free()


func add_graph_node(content: GDScriptParser.ScriptContent) -> void:
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
		var label := Label.new()
		add_graph_node_label(new_graph_node, str(method["name"], ": ", type_string(method["return"]["type"])))
		new_graph_node.add_child(label)


func add_graph_node_label(graph_node: GraphNode, label_text: String) -> void:
		var label := Label.new()
		label.text = label_text
		graph_node.add_child(label)
