@tool
extends Node3D

const RAY_LENGTH = 100

var decal: Decal
var decal_dupe: Decal
var last_collider: CollisionObject3D

var on_object = false
var add_rotation_rad = 0.0
var add_scale = Vector3(1.0, 1.0, 1.0)

func _ready():
	decal = Decal.new()
	decal.upper_fade
	_get_editor_manager().select_decal.connect(_decal_selected)

func _decal_selected(path: String):
	var texture = ImageTexture.create_from_image(Image.load_from_file(path))
	decal.texture_albedo = texture

func _create_decal():
	if decal_dupe: return
	var root = EditorInterface.get_edited_scene_root()
	decal_dupe = decal.duplicate()
	decal_dupe.process_mode = Node.PROCESS_MODE_DISABLED
	var upper_fade = _get_editor_manager().upper_fade
	var lower_fade = _get_editor_manager().lower_fade
	decal_dupe.upper_fade = upper_fade
	decal_dupe.lower_fade = lower_fade
	root.add_child(decal_dupe, true)
	decal_dupe.owner = root

func _remove_decal():
	decal_dupe.free()
	decal_dupe = null
	last_collider = null

func _place_decal():
	decal_dupe.process_mode = Node.PROCESS_MODE_INHERIT
	decal_dupe = null

func _input(event):
	var event_was_handled = false
	var rot_iter = _get_editor_manager().rotation_step
	var scale_step = _get_editor_manager().scale_step
	var scale_iter = Vector3(scale_step, scale_step, scale_step)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var viewport = EditorInterface.get_editor_viewport_3d(0)
			var mouse_pos = viewport.get_mouse_position()
			var rect = viewport.get_visible_rect()
			
			if decal_dupe and on_object and rect.has_point(mouse_pos):
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
	if not _get_editor_manager(): return
	if not _get_editor_manager().enabled:
		if decal_dupe:
			_remove_decal()
		return
	if not _get_editor_manager().has_items and not _get_editor_manager().selected_decal:
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
		on_object = true
		var collider: CollisionObject3D = result.collider
		last_collider = collider
		var normal: Vector3 = result.normal
		
		if type_exists("DebugDraw3D"):
			Engine.get_singleton("DebugDraw3D").draw_line(result.position, result.position + normal, Color.RED)
		
		if not decal_dupe:
			_create_decal()
		elif decal_dupe:
			decal_dupe.position = result.position
			decal_dupe.size = add_scale
			var rotate_around = normal.cross(Vector3.UP).normalized()
			if Vector3.UP.cross(normal) == Vector3.ZERO:
				decal_dupe.transform.basis = Basis(
					Quaternion(normal, add_rotation_rad)
				)
			else:
				var rot = rotate_around.angle_to(normal)
				decal_dupe.transform.basis = Basis(
					Quaternion(rotate_around, rot) *
					Quaternion(normal.cross(rotate_around), add_rotation_rad)
				)
	else:
		on_object = false
		if last_collider and decal_dupe:
			_remove_decal()

func _get_editor_manager():
	return Engine.get_main_loop().root.get_node_or_null("SplasherEditorManager")
