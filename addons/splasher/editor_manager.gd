@tool
extends Node

class DecalSettings:
	# Automatically determine decal's thickness based on the size of a collider
	var p_auto_thickness: bool:
		get:
			return get_property("p_auto_thickness")
		set(value):
			set_property("p_auto_thickness", value)

	# Snap to a custom grid
	var p_grid_snap: bool:
		get:
			return get_property("p_grid_snap")
		set(value):
			set_property("p_grid_snap", value)

	# -------

	var settings_storage: Dictionary = {}

	signal changed(prop_name: String, new_value: Variant, old_value: Variant)

	func _init() -> void:
		# Load initial values
		settings_storage["p_auto_thickness"] = true
		settings_storage["p_grid_snap"] = false

	func get_property(prop_name: String) -> Variant:
		return settings_storage[prop_name]

	func set_property(prop_name: String, new_value: Variant) -> void:
		var old_value = settings_storage[prop_name]
		settings_storage[prop_name] = new_value
		emit_changed(prop_name, new_value, old_value)

	func emit_changed(prop_name: String, new_value: Variant, old_value: Variant) -> void:
		changed.emit(prop_name, new_value, old_value)

var enabled = false
var selected_decal: String
var decal_list: Array[String] = []
var has_items: bool:
	get:
		return not decal_list.is_empty()

var scale_step = 0.5
var rotation_step = 0.05
var snap_step = 0.5

var decal_settings: DecalSettings = DecalSettings.new()

var upper_fade = 0.3
var lower_fade = 0.3

var viewport_panel: Control

signal select_decal(path: String)
signal changed

func emit_select_decal(index: int):
	selected_decal = decal_list[index]
	select_decal.emit(selected_decal)
	changed.emit()

func emit_changed():
	changed.emit()
