@tool
extends RefCounted

const EDITOR_VIEWPORT_NAME := "SplasherEditorViewport"
const EDITOR_MANAGER_NAME := "SplasherEditorManager"

const SAVE_DELAY_SEC := 3

const SAVE_FILE_PATH := "user://splasher.tres"

static func get_autoload(name: String):
	return Engine.get_main_loop().root.get_node_or_null(name)

static func get_editor_manager():
	return get_autoload(EDITOR_MANAGER_NAME)

static func has_debug_draw_3d():
	return type_exists("DebugDraw3D")

static func get_debug_draw_3d():
	return Engine.get_singleton("DebugDraw3D")
