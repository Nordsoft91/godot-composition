@tool
extends VBoxContainer

var ComponentOwnerScript = preload("res://addons/composition/component_owner.gd")

var to_components_button: Button = null

var object: Node = null

var editor_interface: EditorInterface

func _enter_tree() -> void:
	show_components_button()


func show_components_button():
	to_components_button = Button.new()
	#Node.AUTO_TRANSLATE_MODE_DISABLED, hardcoded for compatibility
	if to_components_button.get("auto_translate_mode") != null:
		to_components_button.set("auto_translate_mode", 2) 
	to_components_button.icon = preload("res://addons/composition/icons/component_owner.png")
	to_components_button.expand_icon = true
	to_components_button.text = "Components"
	to_components_button.tooltip_text = "Go to components"
	to_components_button.set_h_size_flags(SIZE_EXPAND_FILL)
	to_components_button.pressed.connect(_on_components_button_pressed)
	add_child(to_components_button, false)
	

func _on_components_button_pressed():
	if is_instance_valid(object):
		var component_owner = Component.component_owner(object)
		if not component_owner:
			component_owner = ComponentOwnerScript.new()
			object.add_child(component_owner, false)
			component_owner.owner = get_tree().edited_scene_root

		if component_owner:
			editor_interface.inspect_object.call_deferred(component_owner)
