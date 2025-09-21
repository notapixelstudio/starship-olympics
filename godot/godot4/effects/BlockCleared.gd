@tool
extends Node2D

@export var color := 0 : set = set_color
@export var liquid := false : set = set_liquid
@export var tile_size := Vector2(200,200) : set = set_tile_size

signal done

func set_color(v:int) -> void:
	color = v
	refresh()
	
func set_liquid(v:bool) -> void:
	liquid = v
	refresh()

func set_tile_size(v:Vector2) -> void:
	tile_size = v
	refresh()
	
func _ready() -> void:
	refresh()
	
func refresh() -> void:
	%Sprite2D.region_rect = Rect2(tile_size.x*(Block.BlockTile.TILEMAP_START_X + color + (Block.BlockTile.COLORS if liquid else 0)), 0, tile_size.x, tile_size.y)
	%GravitonField.position = Vector2(tile_size.x/2.0, tile_size.y/2.0)
	 
func notify_done() -> void:
	done.emit()
