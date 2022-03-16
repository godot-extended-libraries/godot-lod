# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
tool
extends Spatial
class_name LODSpatial, "lod_spatial.svg"

# If `false`, LOD won't update anymore. This can be used for performance comparison
# purposes.
var enable_lod := true setget set_enable_lod

# The maximum LOD 0 (high quality) distance in units.
var lod_0_max_distance := 10.0

# The maximum LOD 1 (medium quality) distance in units.
var lod_1_max_distance := 25.0

# The maximum LOD 2 (low quality) distance in units.
# Past this distance, all LOD variants are hidden.
var lod_2_max_distance := 100.0

# The LOD bias in units.
# Positive values will decrease the detail level and improve performance.
# Negative values will improve visual appearance at the cost of performance.
# This can overridden by setting the project setting `lod/bias`.
var lod_bias := 0.0


func set_enable_lod(value: bool) -> void:
	enable_lod = value
	if is_inside_tree() and not Engine.editor_hint:
		if enable_lod:
			get_tree().root.get_node("LODManager").register_lod_object(self)
		else:
			get_tree().root.get_node("LODManager").unregister_lod_object(self)


func update_lod() -> void:
	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	# The LOD level to choose (lower is more detailed).
	var lod: int

	var distance := camera.global_transform.origin.distance_to(global_transform.origin) + lod_bias
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
		if "-lod0" in node.name:
			node.visible = lod == 0
		elif "-lod1" in node.name:
			node.visible = lod == 1
		elif "-lod2" in node.name:
			node.visible = lod == 2


func _get_property_list() -> Array:
	var properties := [
		{name="LODSpatial", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY},
		{name="enable_lod", type=TYPE_BOOL},
		{name="lod_0_max_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
		{name="lod_1_max_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
		{name="lod_2_max_distance", type=TYPE_REAL, hint=PROPERTY_HINT_EXP_RANGE, hint_string="0,1000,0.01,or_greater"},
	]
	return properties


func _ready() -> void:
	if Engine.editor_hint:
		return
	if ProjectSettings.has_setting("lod/spatial_bias"):
		lod_bias = ProjectSettings.get_setting("lod/spatial_bias")

	get_tree().root.get_node("LODManager").register_lod_object(self)
	update_lod()


func _exit_tree() -> void:
	if Engine.editor_hint:
		return
	get_tree().root.get_node("LODManager").unregister_lod_object(self)


## Note from SIsilicon:
## Some leftover code that's meant to calculate LODs based on screen coverage.
## Just leaving this here incase it's ever needed.
#var base_aabb: AABB
#	for node in get_children():
#		if node is VisualInstance and "-lod0" in node.name:
#			if base_aabb:
#				base_aabb.merge(node.get_transformed_aabb())
#			else:
#				base_aabb = node.get_transformed_aabb()
#	var rect: Rect2
#	for i in 8:
#		var screen_point := camera.unproject_position(base_aabb.get_endpoint(i))
#		if rect:
#			rect = rect.expand(screen_point)
#		else:
#			rect = Rect2(screen_point, Vector2.ZERO)
#
#	var coverage := sqrt(rect.get_area() / Rect2(Vector2.ZERO, get_viewport().size).get_area()) * 100.0
#
#	if coverage > lod_0_min_coverage:
#		lod = 0
#	elif coverage > lod_1_min_coverage:
#		lod = 1
#	elif coverage > lod_2_min_coverage:
#		lod = 2
#	else:
#		# Hide the LOD object entirely.
#		lod = 3
