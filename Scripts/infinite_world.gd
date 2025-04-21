extends Node3D


func _on_water_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		var tree = get_tree() 
		tree.call_deferred("change_scene_to_file", "res://Scenes/lose.tscn")
