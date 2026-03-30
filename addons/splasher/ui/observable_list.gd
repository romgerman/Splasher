@tool
extends RefCounted

var items: Array = []

signal added(index: int, item: Variant)
signal removed(index: int, item: Variant)
signal changed()

func push_back(item: Variant) -> void:
	items.push_back(item)
	added.emit(items.size() - 1, item)
	changed.emit()

func remove_at(index: int) -> void:
	var item = items[index]
	items.remove_at(index)
	removed.emit(index, item)
	changed.emit()

func get_item(index: int) -> Variant:
	return items[index]

func size() -> int:
	return items.size()

func is_empty() -> bool:
	return items.is_empty()

func has(item: Variant) -> bool:
	return items.has(item)
