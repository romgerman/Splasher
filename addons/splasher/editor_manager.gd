@tool
extends Node

var enabled = false
var selected_decal: String
var decal_list: Array[String] = []
var has_items: bool:
	get:
		return not decal_list.is_empty()

var scale_step = 0.5
var rotation_step = 0.05
var snap_step = 0.5
var enable_snap := false

var upper_fade = 0.3
var lower_fade = 0.3

signal select_decal(path: String)
signal changed

func emit_select_decal(index: int):
	selected_decal = decal_list[index]
	select_decal.emit(selected_decal)
	changed.emit()

func emit_changed():
	changed.emit()
