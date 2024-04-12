@tool
extends Node

var undo_redo: EditorUndoRedoManager

var enabled = false
var has_items = false
var selected_decal: String
var decal_list: Array[String] = []

signal select_decal(path: String)
signal changed

func emit_select_decal(index: int):
	selected_decal = decal_list[index]
	select_decal.emit(selected_decal)
	changed.emit()

func emit_changed():
	has_items = decal_list.size() > 0
	changed.emit()
