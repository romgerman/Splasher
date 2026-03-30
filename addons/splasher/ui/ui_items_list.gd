@tool
extends Container

const RES_LENGTH = 6

enum Type {
	List,
	Grid
}

const Globals := preload("res://addons/splasher/globals.gd")
const UIListItem := preload("res://addons/splasher/ui/ui_list_item.tscn")
const UIGridItem := preload("res://addons/splasher/ui/ui_grid_item.tscn")

@export var list_type: Type = Type.List

@onready var alerts: Control = $Alerts
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var context_menu: PopupMenu = $PopupMenu

var presenter: Container
var btn_group: ButtonGroup
var right_clicked_item: Control

func _ready() -> void:
	# Hide all alerts by default
	for alert: Control in alerts.get_children():
		alert.visible = false

	# Set the same style as the ItemList so it looks cohesive
	set_default_theme()

	# Button group for the item selection
	btn_group = ButtonGroup.new()
	btn_group.pressed.connect(btn_group_pressed)

	# List/Grid view
	presenter = create_presenter(list_type)
	scroll_container.add_child(presenter)

	update_alerts()

	var manager = Globals.get_editor_manager()
	bind(manager.decal_list)

func bind(list) -> void:
	list.added.connect(func (_index: int, item: Variant):
		add_item(item)
		update_alerts()
	)
	list.removed.connect(func (index: int, _item: Variant):
		remove_item(index)
		update_alerts()
	)

func update_alerts() -> void:
	var manager = Globals.get_editor_manager()
	alerts.get_child(0).visible = not manager.has_items

func create_presenter(type: Type) -> Container:
	var container: Container

	if type == Type.List:
		container = VBoxContainer.new()
	else:
		container = HFlowContainer.new()

	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return container

func add_item(item: Variant) -> void:
	if list_type == Type.List:
		var ctrl := UIListItem.instantiate()
		presenter.add_child(ctrl)
		ctrl.setup(item, btn_group)
		ctrl.mouse_input.connect(item_mouse_input.bind(ctrl))
	elif list_type == Type.Grid:
		var ctrl := UIGridItem.instantiate()
		presenter.add_child(ctrl)
		ctrl.setup(item, btn_group)
		ctrl.mouse_input.connect(item_mouse_input.bind(ctrl))

func remove_item(index: int) -> void:
	presenter.get_child(index).queue_free()

func item_mouse_input(event: InputEventMouseButton, ctrl: Control) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		right_clicked_item = ctrl
		context_menu.reset_size()
		context_menu.position = (event as InputEventMouseButton).global_position + Vector2(context_menu.size)
		context_menu.popup()

func btn_group_pressed(btn: BaseButton) -> void:
	var ctrl := btn.get_parent()
	var index := ctrl.get_index()
	Globals.get_editor_manager().emit_select_decal(index)

func set_default_theme() -> void:
	var theme := EditorInterface.get_editor_theme()
	add_theme_stylebox_override("panel", theme.get_stylebox("panel", "ItemList"))

var highlight_stylebox: StyleBoxFlat

func highlight_dnd(toggle: bool) -> void:
	if toggle:
		highlight_stylebox = get_theme_stylebox("panel").duplicate()
		highlight_stylebox.border_color = get_theme_color("accent_color", "Editor")
		highlight_stylebox.border_width_bottom = 2
		highlight_stylebox.border_width_left = 2
		highlight_stylebox.border_width_right = 2
		highlight_stylebox.border_width_top = 2
		add_theme_stylebox_override("panel", highlight_stylebox)
	else:
		set_default_theme()

# dnd

func _can_drop_data(at_position: Vector2, data):
	return data.type == "files"

func _drop_data(at_position: Vector2, data):
	var paths: PackedStringArray = data.files
	var decal_list = Globals.get_editor_manager().decal_list
	for path in paths:
		if not decal_list.has(path) and ResourceLoader.load(path) is Texture2D:
			decal_list.push_back(path)

# etc

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		highlight_dnd(true)
	elif what == NOTIFICATION_DRAG_END:
		highlight_dnd(false)

func _on_popup_menu_id_pressed(id: int) -> void:
	if id == 0: # Remove
		var manager = Globals.get_editor_manager()
		manager.decal_list.remove_at(right_clicked_item.get_index())
