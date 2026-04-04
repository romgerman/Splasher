@tool
extends Control

const view_types := ["list", "grid"]

@export var view_type_group: ButtonGroup

signal view_type_changed(view_type: String)

func _ready() -> void:
	view_type_group.pressed.connect(_on_view_type_btn_pressed)

func _on_view_type_btn_pressed(btn: BaseButton) -> void:
	var index := btn.get_index()
	view_type_changed.emit(view_types[index])

func set_view_type(view_type: String) -> void:
	var index := view_types.find(view_type)
	if index != -1:
		view_type_group.get_buttons()[index].set_pressed(true)
	else:
		printerr("Unknown view type \"%s\"" % view_type)
