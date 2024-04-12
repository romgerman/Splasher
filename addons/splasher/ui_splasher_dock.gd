@tool
extends Control

func _on_toggle_plugin_toggled(toggled_on):
	_get_editor_manager().enabled = toggled_on
	_get_editor_manager().emit_changed()

func _get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
