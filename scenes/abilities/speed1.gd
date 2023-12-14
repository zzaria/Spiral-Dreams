extends Ability

@export var speed=0
@export var acceleration=0

func doEffect():
	bearer.speed+=speed
	bearer.acceleration+=acceleration
