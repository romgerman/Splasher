extends Resource

@export var size: Vector3

@export var param_emission_energy: float
@export var param_modulate: Color
@export var param_albedo_mix: float
@export var param_normal_fade: float

@export var vertical_fade_upper_fade: float
@export var vertical_fade_lower_fade: float

@export var distance_fade_enabled: bool
@export var distance_fade_begin: float
@export var distance_fade_length: float

@export var cull_mask: int

func apply_to(decal: Decal) -> void:
	decal.emission_energy = param_emission_energy
	decal.modulate = param_modulate
	decal.albedo_mix = param_albedo_mix
	decal.normal_fade = param_normal_fade

	decal.upper_fade = vertical_fade_upper_fade
	decal.lower_fade = vertical_fade_lower_fade

	decal.distance_fade_enabled = distance_fade_enabled
	decal.distance_fade_begin = distance_fade_begin
	decal.distance_fade_length = distance_fade_length

	decal.cull_mask = cull_mask

static func make_from(decal: Decal):
	var props_res := new()

	props_res.param_emission_energy = decal.emission_energy
	props_res.param_modulate = decal.modulate
	props_res.param_albedo_mix = decal.albedo_mix
	props_res.param_normal_fade = decal.normal_fade

	props_res.vertical_fade_upper_fade = decal.upper_fade
	props_res.vertical_fade_lower_fade = decal.lower_fade

	props_res.distance_fade_enabled = decal.distance_fade_enabled
	props_res.distance_fade_begin = decal.distance_fade_begin
	props_res.distance_fade_length = decal.distance_fade_length

	props_res.cull_mask = decal.cull_mask

	return props_res
