# plugin.gd
@tool
extends EditorPlugin

var plugin


func _enter_tree():
	var ver_info: Dictionary = Engine.get_version_info()
	if ver_info.major < 4 or ver_info.minor < 1:
		push_error("Composition plugin requires Godot 4.1 or higher.")
		return

	plugin = preload("res://addons/composition/editor/components_inspector_plugin.gd").new()
	plugin.editor_interface = get_editor_interface()
	plugin.compatibility_mode = ver_info.minor < 4

	add_inspector_plugin(plugin)


func _exit_tree():
	if plugin:
		remove_inspector_plugin(plugin)
