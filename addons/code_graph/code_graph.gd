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
	
	for property in content.properties:
		var label := Label.new()
		label.text = str(property["name"], ": ", type_string(property["type"]))
		new_graph_node.add_child(label)
	
	new_graph_node.add_child(HSeparator.new())
	
	for method in content.methods:
		var label := Label.new()
		label.text = str(method["name"], ": ", type_string(method["return"]["type"]))
		new_graph_node.add_child(label)
		
