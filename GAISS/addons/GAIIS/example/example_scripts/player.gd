class_name Player extends CharacterBody3D


const move_speed : float = 170.0

@export var camera : Camera3D
@export var camera_sensitivity : float = 1.0
@export var mouse_captured : bool = true
var look_dir : Vector2


func _ready() -> void:
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()

func _physics_process(delta: float) -> void:
	var input = Input.get_vector(
		"left",
		"right",
		"forward",
		"backward"
	)
	var forward = camera.global_transform.basis * Vector3(input.x, 0, input.y)
	var direction = Vector3(forward.x, 0, forward.z).normalized()
	
	if !is_on_floor():
		velocity += get_gravity() * 2
	
	velocity = Vector3(direction.x, velocity.y, direction.z) * move_speed * delta
	
	move_and_slide()

func _rotate_camera(sens_mod := 1.0) -> void:
	rotation.y -= look_dir.x * camera_sensitivity * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sensitivity * sens_mod, -1.5, 1.5)
