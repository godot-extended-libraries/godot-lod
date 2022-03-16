# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
#
# This script is needed to make the `class_name` script visible in the Create New Node dialog
# once the plugin is enabled.
tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("LODManager", "res://addons/lod/lod_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("LODManager")
