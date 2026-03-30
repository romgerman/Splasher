@tool
extends Node

const ObservableList := preload("res://addons/splasher/ui/observable_list.gd")

class StoredSettings:
	var storage: Dictionary = {}

	signal changed(prop_name: String, new_value: Variant, old_value: Variant)

	func get_property(prop_name: String) -> Variant:
		return storage[prop_name]

	func set_property(prop_name: String, new_value: Variant) -> void:
		var old_value = storage[prop_name]
		storage[prop_name] = new_value
		emit_changed(prop_name, new_value, old_value)

	func emit_changed(prop_name: String, new_value: Variant, old_value: Variant) -> void:
		changed.emit(prop_name, new_value, old_value)

class DecalSettings extends StoredSettings:
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

	func _init() -> void:
		# Load initial values
		storage["p_auto_thickness"] = true
		storage["p_grid_snap"] = false

class PluginSettings extends StoredSettings:
	var p_view_type: String:
		get:
			return get_property("p_view_type")
		set(value):
			set_property("p_view_type", value)

	# -------

	func _init() -> void:
		storage["p_view_type"] = "list"

var enabled = false
var selected_decal: String
var selected_decal_index: int
var decal_list: ObservableList = ObservableList.new()
var has_items: bool:
	get:
		return not decal_list.is_empty()

# TODO: move to plugin settings
var scale_step = 0.5
var rotation_step = 0.05
var snap_step = 0.5

var decal_settings := DecalSettings.new()
var plugin_settings := PluginSettings.new()

# TODO: move to decal settings
var upper_fade = 0.3
var lower_fade = 0.3

var viewport_panel: Control

signal select_decal(path: String)
signal changed()

func emit_select_decal(index: int):
	selected_decal = decal_list.get_item(index)
	selected_decal_index = index
	select_decal.emit(selected_decal)
	changed.emit()

func emit_changed():
	changed.emit()
