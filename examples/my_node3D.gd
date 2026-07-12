extends Node

enum MY_ENUM {BAR, FOO}

const POSITION = Vector3(10.0, 8.0, 15.5)

const MY_CONST_FLOAT = 0.1516123

var my_3d_property: String = ""

@export var my_3d_export_property: String = ""

@onready var my_3d_child := $Label3D


func my_3d_method(arg: int) -> void:
	var my_node := MyNode.new()
	my_node.my_method(arg)
	my_node.my_property = str(arg)
	my_3d_child.set_text("My Label Text")
	$Child.child_method(arg)
	$Child.child_property = arg
