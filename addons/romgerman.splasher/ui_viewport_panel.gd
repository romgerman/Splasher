@tool
extends Control

const Globals := preload("res://addons/splasher/globals.gd")
const DecalPropsResource := preload("res://addons/splasher/decal_props.gd")

@onready var toolbar: Control = $Toolbar
@onready var info_label: Label = $Toolbar/HBoxContainer/InfoLabel

@onready var auto_thickness_btn: Button = $Toolbar/HBoxContainer/AutoThickness
@onready var grid_snap_btn: Button = $Toolbar/HBoxContainer/GridSnap
@onready var copy_decal_props: Button = $Toolbar/HBoxContainer/CopyDecalProps

func _ready() -> void:
	var manager = Globals.get_editor_manager()
	manager.viewport_panel = self

	enable(false)

	# Initialize based on settings

	var settings = manager.decal_placement_settings
	auto_thickness_btn.set_pressed_no_signal(settings.p_auto_thickness)
	grid_snap_btn.set_pressed_no_signal(settings.p_grid_snap)

	# Connect change signal

	manager.changed.connect(_editor_manager_changed)

func _editor_manager_changed() -> void:
	var manager = Globals.get_editor_manager()
	enable(manager.enabled)

func enable(value: bool) -> void:
	toolbar.visible = value

	if value:
		info_label.text = get_info_label_text()

	var manager = Globals.get_editor_manager()

	var editor_selection := EditorInterface.get_selection()
	copy_decal_props.visible = editor_selection.get_selected_nodes().size() == 1 and editor_selection.get_selected_nodes()[0] is Decal

	auto_thickness_btn.visible = manager.enabled
	grid_snap_btn.visible = manager.enabled

func get_info_label_text() -> String:
	return "Decal"

# Events

func _on_auto_thickness_toggled(toggled_on: bool) -> void:
	Globals.get_editor_manager().decal_placement_settings.p_auto_thickness = toggled_on

func _on_grid_snap_toggled(toggled_on: bool) -> void:
	Globals.get_editor_manager().decal_placement_settings.p_grid_snap = toggled_on

func _on_copy_decal_props_pressed() -> void:
	var editor_selection := EditorInterface.get_selection()

	if editor_selection.get_selected_nodes().size() == 1 and editor_selection.get_selected_nodes()[0] is Decal:
		var decal := editor_selection.get_selected_nodes()[0] as Decal
		var defaults_res := DecalPropsResource.make_from(decal) as DecalPropsResource
		var manager = Globals.get_editor_manager()
		manager.decal_defaults = defaults_res
