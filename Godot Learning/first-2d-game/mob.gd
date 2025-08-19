extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
  $AnimatedSprite2D.animation = mob_types.pick_random()
  $AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_visible_on_screen_notifier_2d_screen_exited():
  await get_tree().create_timer(1.5).timeout 
  queue_free()
