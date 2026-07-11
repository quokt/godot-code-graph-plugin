@tool
extends Control

@onready var code_graph: CodeGraph = $CodeGraph


func _on_refresh_pressed() -> void:
	code_graph.clear_nodes()
	
	code_graph.add_graph_node(GDScriptParser.parse_file("res://examples/my_node.gd"))
