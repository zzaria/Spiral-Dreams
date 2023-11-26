extends Node2D
class_name ability

@export var damage = 1.0 
@export var cooldown = 0.1 
@export var duration = 0.1 
@export var cost = 0
var bearer
var cooldownTimer=0
var durationTimer=-1000000
var autofire=false
var disabled=false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateTimer(delta):
	cooldownTimer-=delta
	durationTimer-=delta
	if durationTimer<0&&durationTimer>-1000000:
		durationTimer=-1000000
		if bearer!=null:
			doAbilityTimeout()

func attemptAbility(mousePos):
	if bearer!=null&&!disabled&&cooldownTimer<0&&cost<bearer.energy:
		doAbility(mousePos)

func doAbility(mousePos):
	cooldownTimer=cooldown
	durationTimer=duration
	bearer.energy-=cost
	if cost>0&&bearer.energyTick>-0.3:
		bearer.energyTick=-0.3
	
func doAbilityTimeout():
	pass
func tryEffect():
	if disabled:
		return
	doEffect()
func doEffect():
	pass

func toggle():
	autofire=!autofire
