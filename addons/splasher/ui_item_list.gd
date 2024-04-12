@tool
extends ItemList

const RES_LENGTH = 6

func _can_drop_data(at_position, data):
	return data.type == "files"

func _drop_data(at_position, data):
	var paths: PackedStringArray = data.files
	for path in paths:
		var image = Image.new()
		if image.load(path) != OK:
			continue
		var texture = ImageTexture.create_from_image(image)
		var index_of_last_slash = path.substr(RES_LENGTH).rfind("/")
		if index_of_last_slash == -1:
			index_of_last_slash = 0
		var final_path = path.substr(RES_LENGTH).substr(index_of_last_slash)
		var index = add_item(final_path, texture)
		_get_editor_manager().decal_list.push_back(path)
		_get_editor_manager().emit_changed()

func _on_item_selected(index):
	_get_editor_manager().emit_select_decal(index)

func _get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
