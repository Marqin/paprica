extends KinematicBody2D

var age = 0
const AGE_FACTOR = 5

func max_age():
	var tmp = 1.0 - float(get_node("/root/global").player_count) / get_node("/root/global").MAX_PLAYER
	return floor(tmp*AGE_FACTOR) + 1

func player_scale(MA):
	if age <= 0:
		return
	if age >= MA:
		set_scale(Vector2(1, 1))
		return
	var s = log(lerp(1.0, 2.7, age/MA))/2.0 + 0.5
	set_scale(Vector2(s, s))

func _ready():
	set_meta("player", 0)
	randomize()
	set_scale(Vector2(0.5, 0.5))
	set_fixed_process(true)

var velocity = Vector2(0,0);

func _fixed_process(delta):
	if velocity.length() > 0.0:
		var motion = move(velocity*delta)
		if is_colliding() and not get_collider().has_meta("player"):
			var n = get_collision_normal()
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
		velocity /= (1.01 + rand_range(0.01, 0.05))
		if velocity.length() < 0.01:
			velocity = Vector2(0,0)
	
	var MA = max_age()
	var DA = 2*max_age()
	
	age += delta
	
	if age >= DA:
		if is_queued_for_deletion():
			return
		get_node("/root/global").player_count -= 1
		queue_free()
	
	if age < MA:
		player_scale(MA)
	else:
		var c = lerp(0.0, 1.0, ((age-MA)/(DA-MA)))
		c = 1.0-c
		get_node("Sprite").set_modulate(Color(c,c,c))


var chld = load("res://player.tscn")
func _on_player_input_event( viewport, event, shape_idx ):
	if is_queued_for_deletion():
		return
	if (event.type==InputEvent.MOUSE_BUTTON and event.pressed and age >= max_age()):
		get_node("/root/global").player_count -= 1
		for i in range(2):
			if get_node("/root/global").player_count >= get_node("/root/global").MAX_PLAYER:
				break
				
			get_node("/root/global").player_count += 1

			var ch = chld.instance()
			ch.set_pos(get_pos())
			get_parent().add_child(ch)
			var x = i
			if x == 0:
				x = -1
			ch.velocity = Vector2(100+rand_range(-15, 15), x*300+rand_range(-15, 15))
		queue_free()



