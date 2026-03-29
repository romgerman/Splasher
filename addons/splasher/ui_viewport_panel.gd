@tool
extends Control

const Globals := preload("res://addons/splasher/globals.gd")

@onready var toolbar: Control = $Toolbar
@onready var info_label: Label = $Toolbar/HBoxContainer/InfoLabel

@onready var auto_thickness_btn: Button = $Toolbar/HBoxContainer/AutoThickness
@onready var grid_snap_btn: Button = $Toolbar/HBoxContainer/GridSnap

func _ready() -> void:
	# TODO: this
	Globals.get_editor_manager().viewport_panel = self

	enable(false)

	# Initialize base on settings

	var settings = Globals.get_editor_manager().decal_settings
	auto_thickness_btn.set_pressed_no_signal(settings.p_auto_thickness)

	# Connect change signal

	Globals.get_editor_manager().changed.connect(_editor_manager_changed)

func _editor_manager_changed() -> void:
	var manager = Globals.get_editor_manager()
	enable(manager.enabled)

func enable(value: bool) -> void:
	toolbar.visible = value

	if value:
		info_label.text = get_info_label_text()

func get_info_label_text() -> String:
	return "decal placement"

# Events

func _on_auto_thickness_toggled(toggled_on: bool) -> void:
	Globals.get_editor_manager().decal_settings.p_auto_thickness = toggled_on

func _on_grid_snap_toggled(toggled_on: bool) -> void:
	Globals.get_editor_manager().decal_settings.p_grid_snap = toggled_on
