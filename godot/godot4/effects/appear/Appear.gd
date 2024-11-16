extends Node2D

signal done

func _done():
	done.emit()

func _done_and_destroy():
	_done()
	queue_free()
