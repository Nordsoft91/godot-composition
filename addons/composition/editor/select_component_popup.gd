@tool
extends Popup

signal component_selected(filename: String)


func _on_close_requested() -> void:
	queue_free()


func _on_about_to_popup() -> void:
	var filesystem: EditorFileSystemDirectory = EditorInterface.get_resource_filesystem().get_filesystem()
	var dir_stack: Array[EditorFileSystemDirectory] = [filesystem]
	
	while not dir_stack.is_empty():
		var current_dir: EditorFileSystemDirectory = dir_stack.pop_back()
		for i in range(current_dir.get_subdir_count()):
			dir_stack.append(current_dir.get_subdir(i))
	
		for i in range(current_dir.get_file_count()):
			var add_to_list: bool = false
			var icon: Texture2D = null
			var ftype = current_dir.get_file_type(i)
			var fullpath = current_dir.get_path() + current_dir.get_file(i)
			if ftype == "PackedScene":
				var packed_scene: PackedScene = load(fullpath)
				var state: SceneState = packed_scene.get_state()
				for ni in range(state.get_node_count()):
					if state.get_node_path(ni, true).is_empty():
						for npi in range(state.get_node_property_count(ni)):
							var prop = state.get_node_property_name(ni, npi)
							if prop == "script":
								var script: Script = state.get_node_property_value(ni, npi)
								var base_script = script.get_base_script()
								if (base_script and base_script.get_global_name() == "Component") or script.get_global_name() == "Component":
									if EditorInterface.get_editor_theme():
										icon = EditorInterface.get_editor_theme().get_icon("PackedScene", "EditorIcons")
									add_to_list = true #scene
									
				
			var class_extends = current_dir.get_file_script_class_extends(i)
			if class_extends == "Component":
				if EditorInterface.get_editor_theme():
					icon = EditorInterface.get_editor_theme().get_icon("Script", "EditorIcons")
				add_to_list = true #script
			
			if add_to_list:
				var file = current_dir.get_file(i)
				var idx = %ComponentList.add_item(file, icon)
				%ComponentList.set_item_metadata(idx, fullpath)

	call_deferred("update_size")

func update_size():
	var component_list: ItemList = %ComponentList
	if component_list.item_count > 10:
		var one_item_size = component_list.get_minimum_size().y / component_list.item_count
		print(one_item_size)
		%ScrollContainer.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		%ScrollContainer.custom_minimum_size.y = one_item_size * 10


func activate_component(index: int) -> void:
	var item = %ComponentList.get_item_metadata(index)
	component_selected.emit(item)
	queue_free()


func _on_button_pressed() -> void:
	var selected = %ComponentList.get_selected_items()
	if selected.size() == 1:
		activate_component(selected[0])
