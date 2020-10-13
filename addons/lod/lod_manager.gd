# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends Node

# Registered lod objects.
var lod_objects := []

# Index in the lod array that was last processed.
var current_idx := 0

# Number of lods processed in the current frame. Access this for debugging.
var lods_processed := 0

# How much time can be used to process lods in milliseconds.
# If not all the lods can be processed within this time, they'll be processed in the next frame.
var refresh_threshold_ms := 5


func _ready() -> void:
	if ProjectSettings.has_setting("lod/refresh_threshold_ms"):
		refresh_threshold_ms = ProjectSettings.get_setting("lod/refresh_threshold_ms")


func _process(_delta: float) -> void:
	if lod_objects.empty():
		return

	if current_idx >= lod_objects.size():
		current_idx = 0

	lods_processed = 0
	var prev_idx := current_idx
	var time := OS.get_ticks_msec()

	while OS.get_ticks_msec() - time < refresh_threshold_ms:
		lod_objects[current_idx].update_lod()
		lods_processed += 1

		current_idx = wrapi(current_idx + 1, 0, lod_objects.size())
		if prev_idx == current_idx:
			break

# Register lod object, if it's not already in the list.
func register_lod_object(object: Spatial) -> void:
	if not lod_objects.has(object):
		lod_objects.append(object)

# Unregister lod object, if it's still in the list.
func unregister_lod_object(object: Spatial) -> void:
	if lod_objects.has(object):
		lod_objects.erase(object)
