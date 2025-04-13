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
	if ver_info.minor < 4:
		plugin.compatibility_mode = true
		push_warning("Composition plugin is running in compatibility mode. Some features may not work as expected. Please update Godot to 4.4 or higher.")

	add_inspector_plugin(plugin)


func _exit_tree():
	if plugin:
		remove_inspector_plugin(plugin)
