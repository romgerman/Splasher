@tool
extends Control

@export var view_type_group: ButtonGroup

signal view_type_changed(view_type: String)

func _ready() -> void:
	view_type_group.pressed.connect(_on_view_type_btn_pressed)

func _on_view_type_btn_pressed(btn: BaseButton) -> void:
	var index := btn.get_index() # 0 - list, 1 - grid
	view_type_changed.emit("list" if index == 0 else "grid")

func set_view_type(view_type: String) -> void:
	if view_type == "list":
		view_type_group.get_buttons()[0].set_pressed_no_signal(true)
	elif view_type == "grid":
		view_type_group.get_buttons()[1].set_pressed_no_signal(true)
	else:
		printerr("Unknown view type \"%s\"" % view_type)
