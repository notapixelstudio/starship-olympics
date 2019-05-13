extends Node2D

class_name MapPoint

var neighbours = {}

func set_neighbour(n, dir):
	neighbours[dir] = n
	