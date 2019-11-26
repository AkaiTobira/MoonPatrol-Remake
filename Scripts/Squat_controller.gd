extends Node2D

var active_squats = [ ]
var bomber_squats = [ ]

func fill_squat( index, squat, valid ):
	bomber_squats[index]    = squat
	if valid != "Bomber": return 
	squat[0].is_squat_lider = true
	for alien in len(squat):
		squat[alien].number_in_squat = alien+1

func _process(delta):
	for i in len( active_squats ):
		if active_squats[i][0] == 0: continue
		var first_active = null
		for j in bomber_squats[i].size():
			if bomber_squats[i][j] != null:
				if not first_active: first_active = bomber_squats[i][j]
				bomber_squats[i][j].lider = first_active
				bomber_squats[i][j].is_squat_lider = false
		first_active.is_squat_lider = true
				
			
	#print( bomber_squats )
	pass

func register_new_squat(size_of_squat):
	for i in range( len( active_squats ) ):
		if active_squats[i][0] == 0 : 
			active_squats[i] = [ size_of_squat, false ]
			return i
	active_squats.append([size_of_squat, false])
	bomber_squats.append([])
	return len( active_squats) - 1