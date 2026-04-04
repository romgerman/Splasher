@tool
extends Container

const RES_LENGTH = 6

enum Type {
	List,
	Grid
}

const Globals := preload("res://addons/romgerman.splasher/globals.gd")
const UIListItem := preload("res://addons/romgerman.splasher/ui/ui_list_item.tscn")
const UIGridItem := preload("res://addons/romgerman.splasher/ui/ui_grid_item.tscn")

@export var list_type: Type = Type.List
# Button group for the item selection
@export var btn_group: ButtonGroup

@onready var alerts: Control = $Alerts
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var context_menu: PopupMenu = $PopupMenu

var presenter: Container
var right_clicked_item: Control
var items_list

func _ready() -> void:
	# Hide all alerts by default
	for alert: Control in alerts.get_children():
		alert.visible = false

	# Set the same style as the ItemList so it looks cohesive
	set_default_theme()

	btn_group.pressed.connect(btn_group_pressed)

	var manager = Globals.get_editor_manager()
	bind(manager.decal_list)

	build_view()

	manager.plugin_settings.changed.connect(func (prop_name: String, new_value: Variant, old_value: Variant):
		if prop_name == "p_view_type":
			if new_value == "list":
				list_type = Type.List
				build_view()
			elif new_value == "grid":
				list_type = Type.Grid
				build_view()
	)

func bind(list) -> void:
	items_list = list
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
		ctrl.ready.connect(ctrl.setup.bind(item, btn_group), CONNECT_ONE_SHOT)
		ctrl.mouse_input.connect(item_mouse_input.bind(ctrl))
		presenter.add_child(ctrl)
	elif list_type == Type.Grid:
		var ctrl := UIGridItem.instantiate()
		ctrl.ready.connect(ctrl.setup.bind(item, btn_group), CONNECT_ONE_SHOT)
		ctrl.mouse_input.connect(item_mouse_input.bind(ctrl))
		presenter.add_child(ctrl)

func remove_item(index: int) -> void:
	presenter.get_child(index).queue_free()

func item_mouse_input(event: InputEventMouseButton, ctrl: Control) -> void:
	if event.button_index == MOUSE_BUTTON_RIGHT:
		right_clicked_item = ctrl
		context_menu.reset_size()
		context_menu.position = (event as InputEventMouseButton).global_position + Vector2(context_menu.size)
		context_menu.popup()

func build_view() -> void:
	var has_pressed_btn := btn_group.get_pressed_button() != null

	if presenter:
		presenter.free()

	presenter = create_presenter(list_type)
	scroll_container.add_child(presenter)

	for item in items_list.items:
		add_item(item)

	var index = Globals.get_editor_manager().selected_decal_index

	if not items_list.is_empty() and has_pressed_btn:
		presenter.get_child(index).btn.set_pressed_no_signal(true)

	update_alerts()

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
