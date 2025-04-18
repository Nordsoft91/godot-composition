@icon("res://addons/composition/icons/component.png")
class_name Component extends Node

## Base class for all components.
##
## Components are used to extend the functionality of a node.
## They are attached to the ComponentOwner node.
## Components can be added to the ComponentOwner node or to any other node that has a ComponentOwner.
##
## Components can be edited from the inspector. To do this, select the node and press the "Components" button.
## New components can be created by pressing the "Create component" button, which opens a popup menu where you can select a script or a component scene. 
##
## To define a component, create a new script that extends Component class.
##
## Limitations:
## - Avoid same property names in different components.

## @virtual
## Override this method to perform initialization when you need to guarantee that all components are ready.
func _node_ready() -> void:
	pass

## Returns node that owns this component.
func get_object() -> Node:
	var co = get_parent()
	if co.name ==  COMPONENT_OWNER_NAME:
		return co.get_parent()
	return co

## Returns sibling component with the given name.
func other(component_name: String) -> Component:
	return find(get_object(), component_name)

## Returns component owner object for a given node.
static func component_owner(object: Node) -> Node:
	if object.has_node(COMPONENT_OWNER_NAME):
		var co = object.get_node(COMPONENT_OWNER_NAME)
		return co
	return null

## Returns component with the given name.
## If component is not found, returns null.
static func find(object: Node, component_name: String) -> Component:
	var co = component_owner(object)
	if co and co.has_node(component_name):
		return co.get_node(component_name)
	return null

## Returns all components of a given node.
static func all(object: Node) -> Array[Component]:
	return component_owner(object).get_components()

## Adds a component to a node. The component should not have a parent.
## There is no opposite remove method. To remove a component, use `queue_free`, `free` or `remove_child` methods.
static func add(object: Node, component: Component) -> void:
	var co = component_owner(object)
	if co:
		co.add_child(component)


const COMPONENT_OWNER_NAME: String = "ComponentOwner"
		
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		__fix_parenting()
		
	# local override mode
	if get_parent().name == COMPONENT_OWNER_NAME and get_object().has_node(NodePath(name)):
		queue_free()
		return
	
	if not get_object().ready.is_connected(_node_ready):
		get_object().ready.connect(_node_ready)

func _exit_tree() -> void:
	if get_parent().name == COMPONENT_OWNER_NAME:
		get_parent().removed.emit(self)

func __fix_parenting() -> void:
	var co = component_owner(get_parent())
	if co:
		if co.has_node(NodePath(name)):
			co.get_node(NodePath(name)).name = "@to_remove"
		reparent.call_deferred(co)
		co.added.emit(self)
	
	else:
		get_parent().added.emit(self)
