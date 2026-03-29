@tool
extends Control

const Globals := preload("res://addons/splasher/globals.gd")

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
