extends MeshInstance3D
@export var color:Gradient
@export var height_scale:float = 10
var tree = preload("res://Scenes/tree.tscn")
var coconut = preload("res://Scenes/coconut.tscn")
signal collision_changed(new_collision)
@export var fnl = FastNoiseLite.new()
@export var river_fnl = FastNoiseLite.new()
var mdt = MeshDataTool.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_parent().ready
	generate_world(5, 1)
func generate_world(fnl_seed, day):
	if day == 4 or day == 7:
		height_scale += 10
	fnl.seed = fnl_seed
	var plane = PlaneMesh.new()
	plane.size = Vector2(200,200)
	plane.subdivide_depth = 200
	plane.subdivide_width = 200
	var arrs = plane.get_mesh_arrays()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrs)
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var nx = 1.5*vertex.x/100
		var nz = 1.5*vertex.z/100
		var d = 1 - (1-pow(nx, 2)) * (1-pow(nz,2))
		var noise = fnl.get_noise_2d(vertex.x, vertex.z)
		noise = lerp(noise, 1.0-d, 0.6)*1.5
		vertex.y = noise*height_scale
		if (noise > 0.3) and (noise < 0.6):
			randomize()
			if randf() < 0.5 + day/20:
				if i % 183 == 0:
					var instance = tree.instantiate()
					get_parent().add_child(instance)
					instance.global_transform.origin = global_transform.origin + vertex
					instance.scale_object_local(Vector3(0.5,0.5,0.5))
					instance.body_entered.connect(get_node("../../HUD")._on_tree_body_entered)
				elif i % 160 == 0:
					var instance = coconut.instantiate()
					get_parent().add_child(instance)
					instance.global_transform.origin = global_transform.origin + vertex
					instance.scale_object_local(Vector3(0.5,0.5,0.5))
					instance.body_entered.connect(get_node("../../HUD")._on_water_body_entered)
		var color_noise = (noise/2)+0.5
		#var river_noise = river_fnl.get_noise_2d(get_parent().global_transform.origin.x + vertex.x, get_parent().global_transform.origin.x + vertex.z)
		#river_noise = pow(river_noise*1.2, 0.55)
		#if river_noise > 0.75:
		#	mdt.set_vertex_color(i, Color(0,0,1,1))
		#else:
		mdt.set_vertex_color(i, color.sample(color_noise))
		# Save your change.
		mdt.set_vertex(i, vertex)
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	var surfacetool: SurfaceTool = SurfaceTool.new()
	surfacetool.append_from(mesh, 0, Transform3D())
	surfacetool.generate_normals()
	surfacetool.index()
	mesh.clear_surfaces()
	surfacetool.commit(mesh)
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, mat)
	var collision_shape = mesh.create_trimesh_shape()
	collision_changed.emit(collision_shape)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
