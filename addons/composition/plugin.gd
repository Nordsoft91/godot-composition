# plugin.gd
@tool
extends EditorPlugin

var plugin

const script_templates = [
	"default"
]
const ProjectSettingsTemplatesPath = "editor/script/templates_search_path"
const ScriptTemplateComponent = "/Component"
const AddonScriptTemplates = "res://addons/composition/script_templates"

func _enable_plugin() -> void:
	var templates_path = ProjectSettings.get_setting(ProjectSettingsTemplatesPath)
	if templates_path:
		if DirAccess.make_dir_recursive_absolute(templates_path+ScriptTemplateComponent) == OK:
			for script_template in script_templates:
				var source = AddonScriptTemplates+ScriptTemplateComponent+"/"+script_template+".txt"
				var destination = templates_path+ScriptTemplateComponent+"/"+script_template+".gd"
				if DirAccess.copy_absolute(source, destination) == OK:
					print_rich("[color=cyan][b]COMPOSITION:[/b] Script template added: ", destination, "[/color]")

func _disable_plugin() -> void:
	var templates_path = ProjectSettings.get_setting(ProjectSettingsTemplatesPath)
	if templates_path:
		for script_template in script_templates:
			var target = templates_path+ScriptTemplateComponent+"/"+script_template+".gd"
			if DirAccess.remove_absolute(target) == OK:
				print_rich("[color=cyan][b]COMPOSITION:[/b] Script template removed: ", target, "[/color]")
				EditorInterface.get_resource_filesystem().update_file(target)
		DirAccess.remove_absolute(templates_path+ScriptTemplateComponent)

func _enter_tree():
	var ver_info: Dictionary = Engine.get_version_info()
	if ver_info.major < 4 or ver_info.minor < 1:
		push_error("Composition plugin requires Godot 4.1 or higher.")
		return

	plugin = preload("res://addons/composition/editor/components_inspector_plugin.gd").new()
	plugin.editor_interface = get_editor_interface()
	if ver_info.major == 4 and ver_info.minor < 4:
		plugin.compatibility_mode = true
		push_warning("Composition plugin is running in compatibility mode. Some features may not work as expected. Please update Godot to 4.4 or higher.")

	add_inspector_plugin(plugin)


func _exit_tree():
	if plugin:
		remove_inspector_plugin(plugin)
