@tool
extends VBoxContainer

var ComponentOwnerScript = preload("res://addons/composition/component_owner.gd")

var to_components_button: Button = null

var object: Node = null

func _enter_tree() -> void:
	show_components_button()


func show_components_button():
	to_components_button = Button.new()
	to_components_button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
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
			EditorInterface.inspect_object.call_deferred(component_owner)
