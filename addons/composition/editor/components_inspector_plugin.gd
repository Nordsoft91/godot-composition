# my_inspector_plugin.gd
extends EditorInspectorPlugin

var ComponentOwnerControl = preload("res://addons/composition/editor/component_owner_control.gd")
var ComponentOwnerScript = preload("res://addons/composition/component_owner.gd")
var ComponentBaseScript = preload("res://addons/composition/component.gd")

var editor_interface: EditorInterface = null
var compatibility_mode: bool = false

func _can_handle(object: Object):
	return object is Node and not object is Component
	
func _parse_begin(object: Object):
	if not compatibility_mode and object.get_script() == ComponentOwnerScript:
		var button_new = Button.new()
		button_new.text = "Create component"
		button_new.tooltip_text = "Create new component. Select a script or a component scene."
		button_new.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button_new.pressed.connect(_on_button_new_component.bind(object), CONNECT_DEFERRED)
		add_custom_control(button_new)

func _parse_category(object: Object, category: String):
	if category == "Node":
		if object.get_script() == ComponentOwnerScript:
			var button_back = Button.new()
			button_back.text = "Node Properties"
			button_back.tooltip_text = "Return to node properties"
			button_back.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			button_back.pressed.connect(_on_button_back_pressed.bind(object), CONNECT_DEFERRED)
			add_custom_control(button_back)
		
		else:
			var component_owner_check = ComponentOwnerControl.new()
			component_owner_check.object = object
			component_owner_check.editor_interface = editor_interface
			add_custom_control(component_owner_check)


func _on_button_back_pressed(object):
	if object.get_components().is_empty():
		object.queue_free()

	editor_interface.inspect_object(object.get_parent())


func _on_button_new_component(object):
	editor_interface.call_deferred("popup_quick_open", _on_component_selected.bind(object), ["Script", "PackedScene"])


func _on_component_selected(res: String, object):
	if res.is_empty():
		return

	var resource = load(res)
	var script: Script

	if resource is PackedScene:
		var type = resource.get_state().get_node_type(0)
		for i in range(resource.get_state().get_node_property_count(0)):
			var prop = resource.get_state().get_node_property_name(0, i)
			if prop == "script":
				script = resource.get_state().get_node_property_value(0, i)
				break
		
		if not script:
			var error_dialog = AcceptDialog.new()
			error_dialog.title = "Error"
			error_dialog.dialog_text = "Selected scene does not contain a script."
			editor_interface.popup_dialog_centered.call_deferred(error_dialog)
			return
	
	elif resource is Script:
		script = resource

	if script == ComponentBaseScript:
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Error"
		error_dialog.dialog_text = "Cannot add abstract component. Create a new component instead."
		editor_interface.popup_dialog_centered.call_deferred(error_dialog)
		return

	var inherited_from_component: bool = false
	var script_base = script.get_base_script()
	while script_base:
		if script_base == ComponentBaseScript:
			inherited_from_component = true
			break
		script_base = script_base.get_base_script()
	
	if not inherited_from_component:
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Error"
		error_dialog.dialog_text = "Component must extend Component class"
		editor_interface.popup_dialog_centered.call_deferred(error_dialog)
		return

	var global_component_mode: bool = editor_interface.get_edited_scene_root() == object.get_parent() or object.get_parent().scene_file_path.is_empty()
	
	var component_name = res.get_file().get_slice('.', 0).to_pascal_case()
	if global_component_mode and object.has_node(component_name) or object.get_parent().has_node(component_name):
		var error_dialog = AcceptDialog.new()
		error_dialog.title = "Error"
		error_dialog.dialog_text = "Component with the same name already exists"
		editor_interface.popup_dialog_centered.call_deferred(error_dialog)
		return

	var component: Component
	if resource is PackedScene:
		component = resource.instantiate()
		component.name = component_name
	else:
		component = Component.new()
		component.set_script(script)
		component.name = component_name
	
	if global_component_mode:
		object.add_child(component)
		component.owner = object.owner
	else:
		object.get_parent().add_child(component)
		component.owner = object.get_parent().owner

	editor_interface.edit_node(component)
	editor_interface.edit_node.call_deferred(object)
	
	
