@tool
extends Node

var undo_redo: EditorUndoRedoManager

var enabled = false
var has_items = false
var selected_decal: String
var decal_list: Array[String] = []

var scale_step = 0.5
var rotation_step = 0.05

var upper_fade = 0.3
var lower_fade = 0.3

signal select_decal(path: String)
signal changed

func emit_select_decal(index: int):
	selected_decal = decal_list[index]
	select_decal.emit(selected_decal)
	changed.emit()

func emit_changed():
	has_items = decal_list.size() > 0
	changed.emit()
