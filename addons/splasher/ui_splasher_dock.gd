@tool
extends Control

func _on_toggle_plugin_toggled(toggled_on):
	_get_editor_manager().enabled = toggled_on
	_get_editor_manager().emit_changed()

func _on_upper_fade_line_edit_value_changed(value):
	_get_editor_manager().upper_fade = value
	_get_editor_manager().emit_changed()

func _on_lower_fade_line_edit_value_changed(value):
	_get_editor_manager().lower_fade = value
	_get_editor_manager().emit_changed()

func _on_scale_spin_box_value_changed(value):
	_get_editor_manager().scale_step = value
	_get_editor_manager().emit_changed()

func _on_rotation_spin_box_value_changed(value):
	_get_editor_manager().rotation_step = value
	_get_editor_manager().emit_changed()

func _get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
