# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
tool
extends OmniLight
class_name LODOmniLight, "lod_omni_light.svg"

# If `false`, LOD won't update anymore. This can be used for performance comparison
# purposes.
var enable_lod := true

# The maximum shadow distance in units. Past this distance, the shadow will be disabled.
var shadow_max_distance := 25.0

# The distance factor at which the shadow starts fading.
# A value of 0.0 will result in the smoothest transition whereas a value of 1.0 disables fading.
var shadow_fade_start := 0.8

# The maximum shadow distance in units. Past this distance, the light will be hidden.
var light_max_distance := 50.0

# The distance factor at which the light starts fading.
# A value of 0.0 will result in the smoothest transition whereas a value of 1.0 disables fading.
var light_fade_start := 0.8

# The LOD bias in units.
# Positive values will decrease the detail level and improve performance.
# Negative values will improve visual appearance at the cost of performance.
# This can overridden by setting the project setting `lod/bias`.
var lod_bias := 0.0

# The light's energy when it was instanced.
var base_light_energy := light_energy


func set_enable_lod(value: bool) -> void:
	enable_lod = value
	if is_inside_tree() and Engine.editor_hint:
		if enable_lod:
			get_tree().root.get_node("LODManager").register_lod_object(self)
		else:
			get_tree().root.get_node("LODManager").unregister_lod_object(self)


func update_lod() -> void:
	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	var distance := camera.global_transform.origin.distance_to(global_transform.origin) + lod_bias

	visible = distance < light_max_distance
	var light_fade_start_distance := light_max_distance * light_fade_start
	if distance > light_fade_start_distance:
		light_energy = max(0, (1 - (distance - light_fade_start_distance) / (light_max_distance - light_fade_start_distance)) * base_light_energy)
	else:
		# We're close enough to the light to show it at full brightness.
		light_energy = base_light_energy

	shadow_enabled = distance < shadow_max_distance
	var shadow_fade_start_distance := shadow_max_distance * shadow_fade_start
	var shadow_value: float
	if distance > shadow_fade_start_distance:
		shadow_value = min(1, (distance - shadow_fade_start_distance) / (shadow_max_distance - shadow_fade_start_distance))
	else:
		# We're close enough to the light to show its shadow at full darkness.
		shadow_value = 0.0
	shadow_color = Color(shadow_value, shadow_value, shadow_value)


func _get_property_list() -> Array:
	var properties := [
		{name="LODOmniLight", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY},
		{name="enable_lod", type=TYPE_BOOL},
		{name="shadow_max_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
		{name="shadow_fade_start", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0,1,0.01"},
		{name="light_max_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
		{name="light_fade_start", type=TYPE_REAL, hint=PROPERTY_HINT_RANGE, hint_string="0,1,0.01"},
	]
	return properties


func _ready() -> void:
	if Engine.editor_hint:
		return
	if ProjectSettings.has_setting("lod/light_bias"):
		lod_bias = ProjectSettings.get_setting("lod/light_bias")

	get_tree().root.get_node("LODManager").register_lod_object(self)
	update_lod()


func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	get_tree().root.get_node("LODManager").unregister_lod_object(self)
