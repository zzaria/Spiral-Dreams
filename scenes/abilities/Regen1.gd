extends Ability

@export var speed=1000000.0
@export var acceleration=1000000000.0

func doEffect():
	bearer.regen+=(bearer.timeSinceHit/acceleration+1/speed)*bearer.maxHealth
