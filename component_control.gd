extends Component
## This component is for demonstration purposes only.
## It is not intended to be used in a game.

func _input(event: InputEvent) -> void:
	var cMovable: Component = other("ComponentMovable")
	if cMovable:
		if cMovable.is_moving:
			return
		if event.is_action_pressed("left"):
			cMovable.move(Vector2(-1, 0))
		elif event.is_action_pressed("right"):
			cMovable.move(Vector2(1, 0))
		elif event.is_action_pressed("up"):
			cMovable.move(Vector2(0, -1))
		elif event.is_action_pressed("down"):
			cMovable.move(Vector2(0, 1))
