extends CharacterBody3D

@export var speed = 5
@export var gravity = -5
var target = Vector3.ZERO
var moving = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera3d = $Camera3D
		var from = camera3d.project_ray_origin(event.position)
		var to = from + camera3d.project_ray_normal(event.position) * 80
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if  result.has("position"):
			target = result.position
			$"../Marker".global_transform.origin = target

func _physics_process(delta):
	velocity.y += gravity
	if target and moving:
		look_at(target, Vector3.UP)
		rotation.x = 0
		velocity = -transform.basis.z * speed
		if transform.origin.distance_to(target) < 2:
			target = Vector3.ZERO
			velocity = Vector3.ZERO
	move_and_slide()


func _on_input_timer_timeout() -> void:
	moving = true
