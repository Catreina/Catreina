extends CharacterBody3D

signal squashed

# Minimum mob speed in m/s
@export var min_speed = 10

# Maximum mob speed in m/s
@export var max_speed = 18

func _physics_process(_delta) -> void:
  move_and_slide()

func initialize(start_position, player_position):
  # Position the mob at start_position, and rotate it towards player_position
  # so that it's looking at the player
  look_at_from_position(start_position, player_position, Vector3.UP)
  # then Rotate it randomly within +/- 45 degrees so it doesn't move directly
  # towards the player
  rotate_y(randf_range(-PI / 4, PI / 4))

  # Randomize the mobs speed
  var random_speed = randi_range(min_speed, max_speed)
  # Calculate the forward velocity based on this random speed
  velocity = Vector3.FORWARD * random_speed
  # Then rotate velocity vector based on mob's Y rotation to move in the 
  # direction the mob is facing
  velocity = velocity.rotated(Vector3.UP, rotation.y)
  
  # Change speed of animation based on mob speed scaling
  $AnimationPlayer.speed_scale = random_speed / min_speed
  

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
  queue_free()
  
func squash():
  squashed.emit()
  queue_free()
