extends CharacterBody3D

signal hit

# Player movement speed in m/s
@export var speed = 14
# Downward acceleration when in air in m/s^2
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
  # Local variable for input direction
  var direction = Vector3.ZERO

  # Check each move input and update accordingly
  if Input.is_action_pressed("move_right"):
    direction.x += 1
  if Input.is_action_pressed("move_left"):
    direction.x -= 1
  if Input.is_action_pressed("move_back"):
    #in 3D x and z are the ground plane, y is the altitude
    direction.z += 1
  if Input.is_action_pressed("move_forward"):
    direction.z -= 1

  # Jumping!
  if is_on_floor() and Input.is_action_just_pressed("jump"):
    target_velocity.y = jump_impulse

  # Squashing bugs! Iterate through all collisions that have occurred this frame
  for index in range(get_slide_collision_count()):
    # Get a collision's data
    var collision = get_slide_collision(index)
    
    # If there are duplicate collisions with a mob in a single frame
    # the mob will be deleted after the first, and a second call to 
    # get_collider will return null, resulting in a null pointer when calling
    # collision.get_collider().is_in_group("mob")
    # Prevent that.
    if collision.get_collider() == null:
      continue

    # If the collider intersects with a mob...
    if collision.get_collider().is_in_group("mob"):
      var mob = collision.get_collider()
      # check that we are landing on it
      if Vector3.UP.dot(collision.get_normal()) > 0.01:
        # and if so, SQUASH THE BUG!
        mob.squash()
        target_velocity.y = bounce_impulse
        # And prevent further calls
        break

  # Normalize for vector movement (Up and Left at same time, f.ex.)
  if direction != Vector3.ZERO:
    direction = direction.normalized()
    # Setting the basis property affects node rotation
    $Pivot.basis = Basis.looking_at(direction)

  # Animation movement scaling
  if direction != Vector3.ZERO:
    $AnimationPlayer.speed_scale = 4
  else:
    $AnimationPlayer.speed_scale = 1

  # Ground velocity
  target_velocity.x = direction.x * speed
  target_velocity.z = direction.z * speed

  # Vertical velocity
  if not is_on_floor(): # If in the air, fall. Gravity.
    target_velocity.y = target_velocity.y - (fall_acceleration * delta)

  # Arcing when jumping
  $Pivot.rotation.x = PI / 6 * velocity.y /jump_impulse
  
  # Move the character
  velocity = target_velocity
  move_and_slide()

func die() -> void:
  hit.emit()
  queue_free()
  
func _on_mob_detector_body_entered(_body: Node3D) -> void:
  die()
