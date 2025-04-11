extends Component
## This component is for demonstration purposes only.
## It is not intended to be used in a game.

func can_push_to(direction: Vector2) -> bool:
	var cGridObject: Component = Component.find(get_object(), "ComponentGridObject")
	if cGridObject and other("ComponentMovable"):
		return cGridObject.can_move_at(cGridObject.get_cell() + direction)
	return false

func push(direction: Vector2) -> void:
	var cMovable: Component = other("ComponentMovable")
	if not cMovable:
		return
	cMovable.move(direction)
