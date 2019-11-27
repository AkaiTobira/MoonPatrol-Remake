extends Node2D

var active_squats = []
var bomber_squats = []
var bombs         = []

func clear():
	active_squats = []
	bomber_squats = []
	bombs         = []

func is_squat_active(squat_id):
	if len(active_squats) <= squat_id: return false
	return active_squats[squat_id][0] != 0

func reduce_number_of_squad(squat_id):
	if len(active_squats) <= squat_id: return
	active_squats[squat_id][0] -= 1

func switch_sqaut_special_active( squat_id, value ):
	if len(active_squats) <= squat_id: return
	active_squats[squat_id][1] = value

func is_sqaut_special_active( squat_id ):
	if len(active_squats) <= squat_id: return false
	return active_squats[squat_id][1] 

func bomber_destroyed( squat_id, numer_id ):
	if len(active_squats) <= squat_id: return
	bomber_squats[squat_id][numer_id] = null

func fill_squat( index, squat, valid ):
	if valid != "Bomber": return
	bomber_squats[index]    = squat
	squat[0].is_squat_lider = true
	for alien in len(squat):
		squat[alien].number_in_squat = alien+1

func fire_bomb( index, bomb ):
	if index > len( bombs ): return
	bombs[index] = bomb
	active_squats[index][1] = true

func bomb_exploded( index ):
	if index > len( bombs ): return
	bombs[index] = null
	active_squats[index][1] = false

func _process(delta):
	for i in len( active_squats ):
		if active_squats[i][0] == 0: continue
		var first_active = null
		for j in bomber_squats[i].size():
			if bomber_squats[i][j] != null:
				if not first_active: first_active = bomber_squats[i][j]
				bomber_squats[i][j].lider = first_active
				bomber_squats[i][j].is_squat_lider = false
		if first_active : first_active.is_squat_lider = true

func register_new_squat(size_of_squat):
	for i in range( len( active_squats ) ):
		if active_squats[i][0] == 0 : 
			active_squats[i] = [ size_of_squat, false ]
			return i
	active_squats.append([size_of_squat, false])
	bomber_squats.append([])
	bombs.append(null)
	return len( active_squats) - 1