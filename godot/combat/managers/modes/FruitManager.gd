extends Node

func start():
	# listen to collect events from all Collectors
	for collector in traits.get_all_with('Collector'):
		collector.connect('collect', self, '_on_collect', [collector])

func _on_collect(what, who):
	if what is Diamond and who is Ship:
		who.trail.add_duration(0.5)
		
