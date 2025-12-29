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
		for _p in a.get_script().get_script_property_list():
			if _p["usage"] != PROPERTY_USAGE_CATEGORY:
				_p["property"] = _p["name"]
				_p["component"] = a
				_p["name"] = a.name + "." + _p["name"]
				_props.append(_p)

	return _props

func _set(property, value):
	for _p in _get_property_list():
		if _p["name"] == property and _p.has("component") and _p.has("property"):
			var _comp = _p["component"]
			if Engine.is_editor_hint() and is_instance_valid(_comp):
				if _comp.owner != get_tree().edited_scene_root:
					var _pseudo_comp = _comp.duplicate()
					_pseudo_comp.name = _comp.name
					get_parent().add_child(_pseudo_comp)
					_pseudo_comp.owner = get_tree().edited_scene_root
					_comp = _pseudo_comp
				
				_comp.set(_p["property"], value)
				return

func _get(property):
	for _p in _get_property_list():
		if _p["name"] == property and _p.has("component") and _p.has("property"):
			var _comp = _p["component"]
			if is_instance_valid(_comp):
				return _comp.get(_p["property"])


func _property_can_revert(property) -> bool:
	if owner != get_tree().edited_scene_root:
		return false
	
	for _p in _get_property_list():
		if _p["name"] == property and _p.has("component") and _p.has("property"):
			var _comp = _p["component"]
			if is_instance_valid(_comp):
				var _comp_script: Script = _comp.get_script()
				if _comp_script:
					var _default_value = _comp_script.get_property_default_value(_p["property"])
					return _comp.get(_p["property"]) != _default_value
	return false


func _property_get_revert(property) -> Variant:
	for _p in _get_property_list():
		if _p["name"] == property and _p.has("component") and _p.has("property"):
			var _comp = _p["component"]
			if is_instance_valid(_comp):
				var _comp_script: Script = _comp.get_script()
				if _comp_script:
					return _comp_script.get_property_default_value(_p["property"])
	return null
