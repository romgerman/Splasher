@tool
extends Control

@onready var enable_snap: Button = $VBoxContainer/MarginContainer2/VBoxContainer2/HBoxContainer/EnableSnap

func _ready() -> void:
	enable_snap.icon = get_theme_icon(&"Snap", &"EditorIcons")

func _on_toggle_plugin_toggled(toggled_on):
	get_editor_manager().enabled = toggled_on
	get_editor_manager().emit_changed()

func _on_upper_fade_line_edit_value_changed(value):
	get_editor_manager().upper_fade = value
	get_editor_manager().emit_changed()

func _on_lower_fade_line_edit_value_changed(value):
	get_editor_manager().lower_fade = value
	get_editor_manager().emit_changed()

func _on_scale_spin_box_value_changed(value):
	get_editor_manager().scale_step = value
	get_editor_manager().emit_changed()

func _on_rotation_spin_box_value_changed(value):
	get_editor_manager().rotation_step = value
	get_editor_manager().emit_changed()

func _on_snap_spin_box_value_changed(value: float) -> void:
	get_editor_manager().snap_step = value
	get_editor_manager().emit_changed()

func _on_enable_snap_toggled(toggled_on: bool) -> void:
	get_editor_manager().enable_snap = toggled_on
	get_editor_manager().emit_changed()

func get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
