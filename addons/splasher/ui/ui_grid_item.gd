@tool
extends Control

const RES_LENGTH = 6

@onready var btn: Button = $Button
@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect

func setup(item: String, btn_group: ButtonGroup) -> void:
	var theme := EditorInterface.get_editor_theme()
	btn.add_theme_stylebox_override("pressed", theme.get_stylebox("selected", "ItemList"))
	btn.add_theme_stylebox_override("hover", theme.get_stylebox("hovered", "ItemList"))
	btn.button_group = btn_group
	var final_name = item.substr(RES_LENGTH)
	name_label.text = final_name
	EditorInterface.get_resource_previewer().queue_resource_preview(
		item,
		self,
		"_on_preview_ready",
		null
	)

func _on_preview_ready(path: String, preview: Texture2D, thumbnail_preview: Texture2D, userdata: Variant) -> void:
	texture_rect.texture = preview
