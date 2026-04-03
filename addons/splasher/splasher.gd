@tool
extends EditorPlugin

const Globals := preload("res://addons/splasher/globals.gd")
const DockPanel := preload("res://addons/splasher/splasher_dock.tscn")
const ViewportPanel := preload("res://addons/splasher/ui_viewport_panel.tscn")
const StorageResource := preload("res://addons/splasher/storage.gd")

var dock: Control
var viewport_panel: Control
var save_timer: Timer

func _enter_tree():
	add_autoload_singleton(Globals.EDITOR_MANAGER_NAME, "res://addons/splasher/editor_manager.tscn")
	add_autoload_singleton(Globals.EDITOR_VIEWPORT_NAME, "res://addons/splasher/editor_viewport.tscn")

	if has_settings_file():
		load_settings.call_deferred()

	dock = DockPanel.instantiate()
	add_control_to_bottom_panel.call_deferred(dock, "Splasher")

	viewport_panel = ViewportPanel.instantiate()
	get_editor_interface().get_editor_viewport_3d().get_parent().get_parent().add_child.call_deferred(viewport_panel, true)

	watch_settings.call_deferred()

func _exit_tree():
	viewport_panel.free()

	remove_control_from_bottom_panel(dock)
	dock.free()

	remove_autoload_singleton(Globals.EDITOR_VIEWPORT_NAME)
	remove_autoload_singleton(Globals.EDITOR_MANAGER_NAME)

func _save_external_data() -> void:
	if not save_timer.is_stopped():
		save_timer.stop()
	save_settings()

func watch_settings() -> void:
	save_timer = Timer.new()
	add_child(save_timer)

	var manager = Globals.get_editor_manager()
	manager.plugin_settings.changed.connect(func (_p, _n, _o):
		queue_settings_save()
	)
	manager.decal_settings.changed.connect(func (_p, _n, _o):
		queue_settings_save()
	)

	save_timer.timeout.connect(func ():
		save_settings()
	)

func queue_settings_save() -> void:
	if not save_timer.is_stopped():
		save_timer.stop()
	save_timer.start(Globals.SAVE_DELAY_SEC)

func save_settings() -> void:
	var manager = Globals.get_editor_manager()
	var res := StorageResource.new()
	res.decal_settings = manager.decal_settings.storage
	res.plugin_settings = manager.plugin_settings.storage
	if ResourceSaver.save(res, Globals.SAVE_FILE_PATH) != OK:
		printerr("Couldn't save Splasher settings file")

func load_settings() -> void:
	var res := ResourceLoader.load(Globals.SAVE_FILE_PATH)
	if not res:
		printerr("Couldn't load Splasher settings file")
		return

	var manager = Globals.get_editor_manager()
	manager.decal_settings.set_storage(res.decal_settings)
	manager.plugin_settings.set_storage(res.plugin_settings)

func has_settings_file() -> bool:
	return ResourceLoader.exists(Globals.SAVE_FILE_PATH)
