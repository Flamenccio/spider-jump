extends Node

signal collected_item(item_id: String)
signal collected_powerup(powerup_id: String)

const YUMFLY_STAMINA_RECOVERY = 0.25
const SWIFT_YUMFLY_STAMINA_RECOVERY = 0.125

func _on_item_collided(item: Node2D) -> void:
	if item is not Item:
		return
	var item_class := item as Item
	_on_item_collected(item_class)
	item.on_item_collected()


func _on_item_collected(item: Item) -> void:

	if ItemIds.is_item_powerup(item.item_id):
		collected_powerup.emit(item.item_id)
		PlayerEventBus.player_consumed_item.emit(item)
		return

	if item.item_id == ItemIds.YUMFLY_ITEM:
		PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, YUMFLY_STAMINA_RECOVERY)
		PlayerEventBus.player_consumed_item.emit(item)
		PlayerEventBus.item_collected.emit(item.item_id)
		collected_item.emit(item.item_id)
		GlobalFlashParticleSpawner.spawn_particle("item_collected", item.global_position, 0.0)
		return

	if item.item_id == ItemIds.SWIFT_YUMFLY_ITEM:
		PlayerStatsInterface.change_stat.emit(PlayerStatsInterface.STATS_STAMINA, SWIFT_YUMFLY_STAMINA_RECOVERY)
		PlayerEventBus.player_consumed_item.emit(item)
		PlayerEventBus.item_collected.emit(item.item_id)
		collected_item.emit(item.item_id)
		GlobalFlashParticleSpawner.spawn_particle("item_collected", item.global_position, 0.0)
		return

	push_error('item handler: unknown item id "{0}"'.format({'0': item.item_id}))


