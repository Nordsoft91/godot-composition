@icon("res://addons/composition/icons/component_owner.png")
@tool
extends Node
## Component owner node.
## All components are attached to this node.


## Emitted when a component is added to the node.
signal added(component: Component)

## Emitted when a component is removed from the node.
signal removed(component: Component)

## Returns all components of the node.
func get_components() -> Array[Component]:
	var _comps: Dictionary #StringName -> Component
	
	for a in get_children(true):
		if a is Component:
			_comps[a.name] = a

	if get_parent():
		for a in get_parent().get_children(true):
			if a is Component:
				_comps[a.name] = a

	var _comps_values: Array[Component]
	_comps_values.assign(_comps.values()) #wierd workaround due to Godot limitation to convert Array to typed Array
	return _comps_values



func _init() -> void:
	name = Component.COMPONENT_OWNER_NAME

func _get_property_list() -> Array[Dictionary]:
	var _props: Array[Dictionary]
	for a in get_components():
		_props.append({
			"name": a.name,
			"class_name": &"",
			"type": 0,
			"hint": 0,
			"hint_string": a.name,
			"usage": PROPERTY_USAGE_CATEGORY
		})
		_props.append_array(a.get_script().get_script_property_list())

	return _props

func _set(property, value):
	for a in get_components():
		var _props = a.get_script().get_script_property_list()
		for _prop in _props:
			if _prop["name"] == property:
				a.set(property, value)
				return

func _get(property):
	for a in get_components():
		var _props = a.get_script().get_script_property_list()
		for _prop in _props:
			if _prop.name == property:
				return a.get(property)
