extends Node

@export var mob_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $UserInterface/Retry.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  pass

func _on_mob_timer_timeout() -> void:
  # Create new instance of the mob scene
  var mob = mob_scene.instantiate()

  # Choose a random location along the SpawnPath
  # Store a reference to the SpawnLocation node
  var mob_spawn_location = $SpawnPath/SpawnLocation
  # Give it a random offset
  mob_spawn_location.progress_ratio = randf()

  var player_position = $Player.position
  mob.initialize(mob_spawn_location.position, player_position)

  # Spawn mob by adding it to the scene
  add_child(mob)
  
  # Connect the mob to the score label to update upon squishing a mob
  mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())
  
func _on_player_hit() -> void:
  $UserInterface/Retry.show()
  $MobTimer.stop()
  
func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
    # Restart current game
    get_tree().reload_current_scene()
  
