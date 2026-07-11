@tool
extends EditorPlugin

# Dock reference.
var dock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


# Plugin initialization.
func _enter_tree():
	dock = EditorDock.new()
	dock.title = "Code Graph"
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	var dock_content = preload("./code_graph_dock.tscn").instantiate()
	dock.add_child(dock_content)
	add_dock(dock)

# Plugin clean-up.
func _exit_tree():
	remove_dock(dock)
	dock.queue_free()
	dock = null
