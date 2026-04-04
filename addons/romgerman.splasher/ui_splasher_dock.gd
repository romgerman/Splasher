@tool
extends Control

const Globals := preload("res://addons/romgerman.splasher/globals.gd")

@onready var toolbar: Control = $VBoxContainer/VBoxContainer/UiDockToolbar

func _ready() -> void:
	var manager = Globals.get_editor_manager()
	toolbar.set_view_type(manager.plugin_settings.p_view_type)

func _on_toggle_plugin_toggled(toggled_on):
	var manager = Globals.get_editor_manager()
	manager.enabled = toggled_on
	manager.emit_changed()

func _on_upper_fade_line_edit_value_changed(value):
	var manager = Globals.get_editor_manager()
	manager.upper_fade = value
	manager.emit_changed()

func _on_lower_fade_line_edit_value_changed(value):
	var manager = Globals.get_editor_manager()
	manager.lower_fade = value
	manager.emit_changed()

func _on_scale_spin_box_value_changed(value):
	var manager = Globals.get_editor_manager()
	manager.scale_step = value
	manager.emit_changed()

func _on_rotation_spin_box_value_changed(value):
	var manager = Globals.get_editor_manager()
	manager.rotation_step = value
	manager.emit_changed()

func _on_snap_spin_box_value_changed(value: float) -> void:
	var manager = Globals.get_editor_manager()
	manager.snap_step = value
	manager.emit_changed()

func _on_ui_dock_toolbar_view_type_changed(view_type: String) -> void:
	var manager = Globals.get_editor_manager()
	manager.plugin_settings.p_view_type = view_type
