# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends Spatial
class_name LODSpatial, "lod_spatial.svg"

# If `false`, LOD won't update anymore. This can be used for performance comparison
# purposes.
export var enable_lod := true

# The maximum LOD 0 (high quality) distance in units.
export(float, 0.0, 1000.0, 0.1) var lod_0_max_distance := 10

# The maximum LOD 1 (medium quality) distance in units.
export(float, 0.0, 1000.0, 0.1) var lod_1_max_distance := 25

# The maximum LOD 2 (low quality) distance in units.
# Past this distance, all LOD variants are hidden.
export(float, 0.0, 1000.0, 0.1) var lod_2_max_distance := 100

# The rate at which LODs will be updated (in seconds). Lower values are more reactive
# but use more CPU, which is especially noticeable with large amounts of LOD-enabled nodes.
# Set this accordingly depending on your camera movement speed.
# The default value should suit most projects already.
# Note: Slow cameras don't need to have LOD-enabled objects update their status often.
# This can overridden by setting the project setting `lod/refresh_rate`.
var refresh_rate := 0.25

# The LOD bias in units.
# Positive values will decrease the detail level and improve performance.
# Negative values will improve visual appearance at the cost of performance.
# This can overridden by setting the project setting `lod/bias`.
var lod_bias := 0.0

# The internal refresh timer.
var timer := 0.0


func _ready() -> void:
	if ProjectSettings.has_setting("lod/spatial_bias"):
		lod_bias = ProjectSettings.get_setting("lod/spatial_bias")
	if ProjectSettings.has_setting("lod/refresh_rate"):
		refresh_rate = ProjectSettings.get_setting("lod/refresh_rate")

	# Add random jitter to the timer to ensure LODs don't all swap at the same time.
	randomize()
	timer += rand_range(0, refresh_rate)


# Despite LOD not being related to physics, we chose to run in `_physics_process()`
# to minimize the amount of method calls per second (and therefore decrease CPU usage).
func _physics_process(delta: float) -> void:
	if not enable_lod:
		return

	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	if timer <= refresh_rate:
		timer += delta
		return

	timer = 0.0

	var distance := camera.global_transform.origin.distance_to(global_transform.origin) + lod_bias
	# The LOD level to choose (lower is more detailed).
	var lod: int
	if distance < lod_0_max_distance:
		lod = 0
	elif distance < lod_1_max_distance:
		lod = 1
	elif distance < lod_2_max_distance:
		lod = 2
	else:
		# Hide the LOD object entirely.
		lod = 3

	for node in get_children():
		# `-lod` also matches `-lod0`, `-lod1`, `-lod2`, …
		if node.has_method("set_visible"):
			if "-lod0" in node.name:
				node.visible = lod == 0
			if "-lod1" in node.name:
				node.visible = lod == 1
			if "-lod2" in node.name:
				node.visible = lod == 2
