@tool
extends Node3D

const RAY_LENGTH = 100
const SAFE_OFFSET = 0.05

const Globals := preload("res://addons/splasher/globals.gd")

@export_flags_3d_physics var temporary_layer: int

var decal_ref: Decal
var decal_dupe: Decal
var last_collider

var on_object = false
var add_rotation_rad = 0.0
var add_scale = Vector3(1.0, 1.0, 1.0)

var editor_manager

func _ready():
	if not Engine.is_editor_hint():
		queue_free()
		return

	editor_manager = Globals.get_editor_manager()
	decal_ref = Decal.new()

	editor_manager.select_decal.connect(on_decal_selected)

func on_decal_selected(path: String):
	decal_ref.texture_albedo = ResourceLoader.load(path)

func create_decal_dupe():
	if decal_dupe:
		return

	var root := EditorInterface.get_edited_scene_root()
	decal_dupe = decal_ref.duplicate()
	decal_dupe.process_mode = Node.PROCESS_MODE_DISABLED

	if editor_manager.decal_defaults:
		editor_manager.decal_defaults.apply_to(decal_dupe)
	else:
		var upper_fade = editor_manager.upper_fade
		var lower_fade = editor_manager.lower_fade
		decal_dupe.upper_fade = upper_fade
		decal_dupe.lower_fade = lower_fade

	var pivot := root
	var editor_selection := EditorInterface.get_selection()
	if editor_selection.get_selected_nodes().size() == 1:
		var selected_node := editor_selection.get_selected_nodes()[0]
		if selected_node != root and selected_node.get_parent():
			pivot = selected_node.get_parent()
	pivot.add_child(decal_dupe, true)
	decal_dupe.owner = root

func _remove_decal():
	decal_dupe.free()
	decal_dupe = null
	last_collider = null

func _place_decal():
	decal_dupe.process_mode = Node.PROCESS_MODE_INHERIT
	decal_dupe = null

func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		return
	var event_was_handled = false
	var rot_iter = editor_manager.rotation_step
	var scale_step = editor_manager.scale_step
	var scale_iter = Vector3(scale_step, scale_step, scale_step)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var viewport = EditorInterface.get_editor_viewport_3d(0)
			var mouse_pos = viewport.get_mouse_position()
			var rect = viewport.get_visible_rect()

			if decal_dupe and on_object and rect.has_point(mouse_pos):
				# TODO: this
				var viewport_toolbar: Control = Globals.get_editor_manager().viewport_panel.toolbar
				if not viewport_toolbar.get_rect().has_point(mouse_pos):
					_place_decal()
					event_was_handled = true
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if decal_dupe and event.shift_pressed:
				add_rotation_rad += rot_iter
				event_was_handled = true
			elif decal_dupe and event.ctrl_pressed:
				add_scale += scale_iter
				event_was_handled = true
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if decal_dupe and event.shift_pressed:
				add_rotation_rad -= rot_iter
				event_was_handled = true
			elif decal_dupe and event.ctrl_pressed:
				add_scale -= scale_iter
				event_was_handled = true

	if event_was_handled:
		var viewport = EditorInterface.get_editor_viewport_3d(0)
		viewport.set_input_as_handled()

func _process(delta):
	if not Engine.is_editor_hint():
		return
	if not editor_manager:
		return
	if not editor_manager.enabled:
		if decal_dupe:
			_remove_decal()
		return
	if not editor_manager.has_items and not editor_manager.selected_decal:
		return

	var viewport = EditorInterface.get_editor_viewport_3d(0)
	var camera = viewport.get_camera_3d()
	var mouse_pos = viewport.get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_position(mouse_pos, RAY_LENGTH)
	var space_state = get_tree().get_root().get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(params)

	if result:
		on_ray_hit(result)
	else:
		on_object = false
		if last_collider and decal_dupe:
			_remove_decal()

func on_ray_hit(hit) -> void:
	on_object = true
	var collider = hit.collider
	last_collider = collider
	var hit_position: Vector3 = hit.position
	var hit_normal: Vector3 = hit.normal

	if Globals.has_debug_draw_3d():
		Globals.get_debug_draw_3d().draw_line(hit_position, hit_position + hit_normal, Color.RED)

	if not decal_dupe:
		create_decal_dupe()

	if editor_manager.decal_placement_settings.p_grid_snap:
		var snap_to := Vector3(
			editor_manager.snap_step,
			editor_manager.snap_step,
			editor_manager.snap_step
		)
		hit_position = hit_position.snapped(snap_to)

	decal_dupe.global_position = hit_position
	decal_dupe.size = add_scale

	if editor_manager.decal_placement_settings.p_auto_thickness:
		var hit_collider = hit.collider
		var hit_collider_layer = hit_collider.collision_layer
		var hit_collider_mask = hit_collider.collision_mask

		hit_collider.collision_layer = temporary_layer
		hit_collider.collision_mask = temporary_layer

		var from = hit_position + -hit_normal * RAY_LENGTH
		var to = hit_position
		var space_state = get_tree().get_root().get_world_3d().get_direct_space_state()
		var params := PhysicsRayQueryParameters3D.create(from, to, temporary_layer)
		var back_hit = space_state.intersect_ray(params)

		if not back_hit.is_empty():
			var thickness = hit_position.distance_to(back_hit.position)
			decal_dupe.size.y = thickness
			decal_dupe.global_position -= hit_normal * thickness * (0.5 - SAFE_OFFSET)

		hit_collider.collision_layer = hit_collider_layer
		hit_collider.collision_mask = hit_collider_mask

	var rotate_around = hit_normal.cross(Vector3.UP).normalized()
	if Vector3.UP.cross(hit_normal) == Vector3.ZERO:
		decal_dupe.transform.basis = Basis(
			Quaternion(hit_normal, add_rotation_rad)
		)
	else:
		decal_dupe.transform.basis = Basis(
			rotate_around,
			hit_normal,
			hit_normal.cross(rotate_around)
		).rotated(hit_normal, add_rotation_rad)
