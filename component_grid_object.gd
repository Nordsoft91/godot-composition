extends Component
## This component is for demonstration purposes only.
## It is not intended to be used in a game.

@export var solid: bool = false

const TILE_SIZE: int = 64

func _node_ready() -> void:
	add_to_group("grid_objects")

func get_cell() -> Vector2:
	return get_object().position / TILE_SIZE

func get_object_cell(cell: Vector2) -> Node2D:
	for n in get_tree().get_nodes_in_group("grid_objects"):
		if n.get_cell() == cell:
			return n.get_object()
	return null

func is_cell_solid(cell: Vector2) -> bool:
	for n in get_tree().get_nodes_in_group("grid_objects"):
		if n.get_cell() == cell and n.solid:
			return true
	return false

func can_move_at(cell: Vector2) -> bool:
	if not is_cell_solid(cell):
		return true

	var obj_at_cell: Node2D = get_object_cell(cell)
	if obj_at_cell:
		var cPushable: Component = Component.find(obj_at_cell, "ComponentPushable")
		if cPushable:
			return cPushable.can_push_to(cell - get_cell())
	
	return false
