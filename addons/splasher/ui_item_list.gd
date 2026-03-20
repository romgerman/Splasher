@tool
extends ItemList

const RES_LENGTH = 6

@onready var context_menu: PopupMenu = $PopupMenu

func _can_drop_data(at_position: Vector2, data):
	return data.type == "files"

func _drop_data(at_position: Vector2, data):
	var paths: PackedStringArray = data.files
	for path in paths:
		var final_path = path.substr(RES_LENGTH)
		var index = add_item(final_path, ResourceLoader.load(path))
		var editor_manager = get_editor_manager()
		editor_manager.decal_list.push_back(path)
		editor_manager.emit_changed()

func _on_item_selected(index):
	var editor_manager = get_editor_manager()
	editor_manager.emit_select_decal(index)

func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		context_menu.position = get_screen_position() + at_position
		context_menu.popup()

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0: # Remove
		var selected := get_selected_items()
		var editor_manager = get_editor_manager()
		for item_index in selected:
			remove_item(item_index)
			(editor_manager.decal_list as Array).remove_at(item_index)

func get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
