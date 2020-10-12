# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
tool
extends Particles
class_name LODParticles, "lod_particles.svg"

# If `false`, LOD won't update anymore. This can be used for performance comparison
# purposes.
var enable_lod := true setget set_enable_lod

# The maximum particle emitting distance in units. Past this distance, particles will no longer emit.
var max_emit_distance := 50.0

# The LOD bias in units.
# Positive values will decrease the detail level and improve performance.
# Negative values will improve visual appearance at the cost of performance.
# This can overridden by setting the project setting `lod/bias`.
var lod_bias := 0.0


func set_enable_lod(value: bool) -> void:
	enable_lod = value
	if is_inside_tree() and Engine.editor_hint:
		if enable_lod:
			LODManager.register_lod_object(self)
		else:
			LODManager.unregister_lod_object(self)


func update_lod() -> void:
	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	var distance := camera.global_transform.origin.distance_to(global_transform.origin) + lod_bias
	emitting = distance < max_emit_distance


func _get_property_list() -> Array:
	var properties := [
		{name="LODParticles", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY},
		{name="enable_lod", type=TYPE_BOOL},
		{name="max_emit_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
	]
	return properties


func _ready() -> void:
	if Engine.editor_hint:
		return
	if ProjectSettings.has_setting("lod/particle_bias"):
		lod_bias = ProjectSettings.get_setting("lod/particle_bias")

	LODManager.register_lod_object(self)
	update_lod()


func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	LODManager.unregister_lod_object(self)
