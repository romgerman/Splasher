extends RefCounted

const EDITOR_VIEWPORT_NAME = "SplasherEditorViewport"
const EDITOR_MANAGER_NAME = "SplasherEditorManager"

static func get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null(EDITOR_MANAGER_NAME)

static func has_debug_draw_3d():
	return type_exists("DebugDraw3D")

static func get_debug_draw_3d():
	return Engine.get_singleton("DebugDraw3D")
