@tool
extends Control

@onready var code_graph: CodeGraph = $CodeGraph


func _on_refresh_pressed() -> void:
	code_graph.refresh()
	
