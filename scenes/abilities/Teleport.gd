extends Ability

func doAbility(mousePos):
	super.doAbility(mousePos)
	bearer.position+=mousePos
