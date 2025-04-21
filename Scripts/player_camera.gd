extends Camera3D
var tween
func _process(delta: float) -> void:
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.tween_property(self, "global_transform:origin:x", get_parent().transform.origin.x, 1.5)
	tween.parallel().tween_property(self, "global_transform:origin:z", get_parent().transform.origin.z, 1.5)
	tween.parallel().tween_property(self, "global_transform:origin:y", get_parent().transform.origin.y+16, 1.5)
