## Holds item and powerup ID constants
extends Node

const HOVERFLY_POWERUP = &'hoverfly'
const HEAVY_BEETLE_POWERUP = &'heavy_beetle'
const HOPPERPOP_POWERUP = &'hopperpop'
const BLINKFLY_POWERUP = &'blinkfly'
const SUPER_GRUB_POWERUP = &'super_grub'
const BUBBLEBEE_POWERUP = &'bubblebee'
const ANTIBUG_POWERUP = &'antibug'
const NO_POWERUP = &'none'
const YUMFLY_ITEM = &'yum_fly'

const _POWERUPS: Array[StringName] = [
	HOVERFLY_POWERUP,
	HEAVY_BEETLE_POWERUP,
	HOPPERPOP_POWERUP,
	BLINKFLY_POWERUP,
	SUPER_GRUB_POWERUP,
	BUBBLEBEE_POWERUP,
	ANTIBUG_POWERUP
]

const _ITEMS: Array[StringName] = [
	YUMFLY_ITEM,
]

func is_item_powerup(item_id: String) -> bool:
	return _POWERUPS.has(item_id)

