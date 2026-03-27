@tool
extends EditorPlugin

const EDITOR_VIEWPORT_NAME = "SplasherEditorViewport"
const EDITOR_MANAGER_NAME = "SplasherEditorManager"

const DockPanel := preload("res://addons/splasher/splasher_dock.tscn")
const ViewportPanel := preload("res://addons/splasher/ui_viewport_panel.tscn")

var dock: Control
var viewport_panel: Control

func _enter_tree():
	add_autoload_singleton(EDITOR_MANAGER_NAME, "res://addons/splasher/editor_manager.tscn")
	add_autoload_singleton(EDITOR_VIEWPORT_NAME, "res://addons/splasher/editor_viewport.tscn")

	dock = DockPanel.instantiate()
	add_control_to_bottom_panel(dock, "Splasher")

	viewport_panel = ViewportPanel.instantiate()

	get_editor_interface().get_editor_viewport_3d().add_child(viewport_panel)

func _exit_tree():
	viewport_panel.free()

	remove_control_from_bottom_panel(dock)
	dock.free()

	remove_autoload_singleton(EDITOR_VIEWPORT_NAME)
	remove_autoload_singleton(EDITOR_MANAGER_NAME)

