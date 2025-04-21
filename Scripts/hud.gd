extends CanvasLayer

var bar_red = preload("res://barHorizontal_red.png")
var bar_green = preload("res://barHorizontal_green.png")
var bar_yellow = preload("res://barHorizontal_yellow.png")

@onready var water_bar = $WaterBar
@onready var food_bar = $FoodBar
var food = 10
var water = 10
var day = 0
signal generate_world(seed, day)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()

func update_bar(bar, value):
	if value !=0:
		bar.texture_progress = bar_green
		if value < bar.max_value * 0.7:
			bar.texture_progress = bar_yellow
		if value < bar.max_value * 0.35:
			bar.texture_progress = bar_red
		if value < bar.max_value:
			show()
		bar.value = value
	else:
		get_tree().change_scene_to_file("res://Scenes/lose.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tree_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		food += 1
		$AnimationPlayer.play("food_plus")
		update_bar($FoodBar, food)
func _on_water_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		water += 1
		$AnimationPlayer.play("water_plus")
		update_bar($WaterBar, water)

func _on_timer_timeout() -> void:
	if randf() > 0.5:
		water -= 1
		update_bar($WaterBar, water)
	else:
		food -=1
		update_bar($FoodBar, food)

func _on_day_timer_timeout() -> void:
	print($DayLabel)
	day += 1
	if day == 11:
		get_tree().change_scene_to_file("res://Scenes/win.tscn")
	else:
		$DayLabel.text = "Day "+str(day)
		$DayLabel.visible = true
		$Timer.wait_time = 3-(0.2*day)
		print($Timer.wait_time)
		print($DayLabel.text)
		water = 10
		food = 10
		$"../Player".moving = false
		$"../Player".target = Vector3.ZERO
		get_tree().create_timer(3).timeout.connect($"../Player"._on_input_timer_timeout)
		update_bar($WaterBar, 10)
		update_bar($FoodBar, 10)
		$"../Player".global_transform.origin = Vector3(0, 100, 0)
		$"../Player/Camera3D".global_transform.origin = Vector3(0, 116, 0)
		$"../Marker".global_transform.origin = Vector3.ZERO
		generate_world.emit(randi_range(5,100), day)
		$AnimationPlayer.play("fade_out")
		$DayTimer.start()

func start() -> void:
	water = 10
	food = 10
	update_bar($WaterBar, 10)
	update_bar($FoodBar, 10)
	day += 1
	$DayLabel.text = "Day "+str(day)
	get_tree().create_timer(3).timeout.connect($"../Player"._on_input_timer_timeout)
	$"../Player".moving = false
	$"../Player".global_transform.origin = Vector3(0, 100, 0)
	$"../Player/Camera3D".global_transform.origin = Vector3(0,116,0)
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("fade_out")
	$DayTimer.start()
