extends Component
## This component is for demonstration purposes only.
## It is not intended to be used in a game.

@export var move_time: float = 0.3 ## How much time it takes to move, in seconds

const TILE_SIZE: int = 64

var is_moving: bool = false

func move(direction: Vector2):
	var cGridObject: Component = other("ComponentGridObject")
	if cGridObject and not cGridObject.can_move_at(cGridObject.get_cell() + direction.sign()):
		return

	#push
	if cGridObject:
		var obj_at_cell: Node2D = cGridObject.get_object_cell(cGridObject.get_cell() + direction.sign())
		if obj_at_cell:
			var cPushable: Component = Component.find(obj_at_cell, "ComponentPushable")
			if cPushable:
				cPushable.push(direction.sign())

	assert(!is_moving)
	is_moving = true
	var tween: Tween = get_object().create_tween()
	tween.tween_property(get_object(), "position", get_object().position + direction.sign() * Vector2(TILE_SIZE, TILE_SIZE), move_time)
	tween.tween_callback(set.bind("is_moving", false))
