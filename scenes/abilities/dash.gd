extends ability
var dashing
@export var distance=300
func _ready():
	dashing=false

func doAbility(_mousePos):
	super.doAbility(_mousePos)
	dashing=true

func doEffect():
	if dashing:
		bearer.speed+=distance/duration
		bearer.acceleration+=distance/duration*15
func doAbilityTimeout():
	dashing=false
