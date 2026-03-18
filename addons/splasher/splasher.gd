@tool
extends EditorPlugin

const EDITOR_VIEWPORT_NAME = "SplasherEditorViewport"
const EDITOR_MANAGER_NAME = "SplasherEditorManager"

const SplasherDock := preload("res://addons/splasher/splasher_dock.tscn")

var dock: Control

func _enter_tree():
	dock = SplasherDock.instantiate()
	add_autoload_singleton(EDITOR_MANAGER_NAME, "res://addons/splasher/editor_manager.tscn")
	add_autoload_singleton(EDITOR_VIEWPORT_NAME, "res://addons/splasher/editor_viewport.tscn")
	add_control_to_bottom_panel(dock, "Splasher")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
	remove_autoload_singleton(EDITOR_VIEWPORT_NAME)
	remove_autoload_singleton(EDITOR_MANAGER_NAME)
