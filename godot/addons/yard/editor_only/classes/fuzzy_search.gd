## fuzzy_search.gd
## Near-direct port of Godot's core/string/fuzzy_search.{h,cpp} to GDScript.
## Reproduced API:  FuzzySearch, FuzzySearchToken, FuzzyTokenMatch, FuzzySearchResult.
extends RefCounted

## Note: If `class_name FuzzySearch` is enabled, inner classes can access static
## helpers directly and the external namespace indirection can be removed.
#class_name FuzzySearch

const CULL_FACTOR: float = 0.1
const CULL_CUTOFF: float = 30.0

var tokens: Array[FuzzySearchToken] = []
var case_sensitive: bool = false

var start_offset: int = 0
var max_results: int = 100
var max_misses: int = 2
var allow_subsequences: bool = true


static func _is_boundary_codepoint(cp: int) -> bool:
	return cp == 47 or cp == 92 or cp == 45 or cp == 95 or cp == 46 # "/\\-_."


static func _is_valid_interval(iv: Vector2i) -> bool:
	# Empty intervals are represented as (-1, -1).
	return iv.x >= 0 and iv.y >= iv.x


static func _extend_interval(a: Vector2i, b: Vector2i) -> Vector2i:
	if not _is_valid_interval(a):
		return b
	if not _is_valid_interval(b):
		return a
	return Vector2i(min(a.x, b.x), max(a.y, b.y))


static func _is_word_boundary(s: String, index: int) -> bool:
	if index == -1 or index == s.length():
		return true
	return _is_boundary_codepoint(s.unicode_at(index))


static func _find_codepoint(s: String, cp: int, from: int) -> int:
	# Equivalent to C++ String::find_char(cp, from)
	var ch := String.chr(cp)
	var n := s.length()
	for i in range(max(from, 0), n):
		if s[i] == ch:
			return i
	return -1


func set_query(p_query: String, p_case_sensitive: bool = (not _is_lowercase(p_query))) -> void:
	tokens.clear()
	case_sensitive = p_case_sensitive

	for s in p_query.split(" ", false):
		var t := FuzzySearchToken.new()
		t.idx = tokens.size()
		t.string = s if p_case_sensitive else s.to_lower()
		tokens.append(t)

	# Prioritize matching longer tokens before shorter ones since match overlaps are not accepted.
	tokens.sort_custom(
		func(a: FuzzySearchToken, b: FuzzySearchToken) -> bool:
			if a.string.length() == b.string.length():
				return a.idx < b.idx
			return a.string.length() > b.string.length()
	)


func search(p_target: String, p_result: FuzzySearchResult) -> bool:
	p_result._reset_for_search(p_target, p_target.rfind("/"), max_misses)

	var adjusted_target := p_target if case_sensitive else p_target.to_lower()

	# Eagerly generate matches for each token, keep best-scoring non-conflicting one.
	for token in tokens:
		var best_match: FuzzyTokenMatch = null
		var offset := start_offset

		while true:
			var m := FuzzyTokenMatch.new()
			var ok := false

			if allow_subsequences:
				ok = token.try_fuzzy_match(m, adjusted_target, offset, p_result.miss_budget)
			else:
				ok = token.try_exact_match(m, adjusted_target, offset)

			if not ok:
				break

			if p_result.can_add_token_match(m):
				p_result.score_token_match(m, m.is_case_insensitive(p_target, adjusted_target))
				if best_match == null or best_match.score < m.score:
					best_match = m

			if self._is_valid_interval(m.interval):
				offset = m.interval.x + 1
			else:
				break

		if best_match == null:
			return false

		p_result.add_token_match(best_match)

	p_result.maybe_apply_score_bonus()
	return true


func search_all(p_targets: PackedStringArray, p_results: Array[FuzzySearchResult]) -> void:
	p_results.clear()

	for i in range(p_targets.size()):
		var r := FuzzySearchResult.new()
		r.original_index = i
		if search(p_targets[i], r):
			p_results.append(r)

	_sort_and_filter(p_results)


static func _remove_low_scores(p_results: Array[FuzzySearchResult], p_cull_score: float) -> void:
	# Removes all results with score < p_cull_score in-place (two pointers).
	var i := 0
	var j := p_results.size() - 1

	while true:
		while j >= i and p_results[j].score < p_cull_score:
			j -= 1
		while i < j and p_results[i].score >= p_cull_score:
			i += 1
		if i >= j:
			break
		var tmp := p_results[i]
		p_results[i] = p_results[j]
		p_results[j] = tmp
		i += 1
		j -= 1

	p_results.resize(j + 1)


func _sort_and_filter(p_results: Array[FuzzySearchResult]) -> void:
	if p_results.is_empty():
		return

	var avg_score: float = 0.0
	var max_score: float = 0.0

	for r in p_results:
		avg_score += float(r.score)
		max_score = maxf(max_score, float(r.score))

	avg_score /= float(p_results.size())
	var cull_score: float = minf(CULL_CUTOFF, lerpf(avg_score, max_score, CULL_FACTOR))
	_remove_low_scores(p_results, cull_score)

	# Sort on (score desc, length asc, alphanumeric asc) for consistent ordering.
	p_results.sort_custom(
		func(a: FuzzySearchResult, b: FuzzySearchResult) -> bool:
			if a.score == b.score:
				if a.target.length() == b.target.length():
					return a.target < b.target
				return a.target.length() < b.target.length()
			return a.score > b.score
	)

	# En C++: partial_sort si > max_results. Ici: tri complet puis resize (même résultat, perf différente).
	if p_results.size() > max_results:
		p_results.resize(max_results)


func _is_lowercase(s: String) -> bool:
	return s == s.to_lower()


class FuzzySearchToken:
	const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
	const FuzzySearch := Namespace.FuzzySearch

	var idx: int = -1
	var string: String = ""


	func try_exact_match(p_match: FuzzyTokenMatch, p_target: String, p_offset: int) -> bool:
		p_match._reset(idx, string.length())
		var match_idx := p_target.find(string, p_offset)
		if match_idx == -1:
			return false
		p_match.add_substring(match_idx, string.length())
		return true


	func try_fuzzy_match(p_match: FuzzyTokenMatch, p_target: String, p_offset: int, p_miss_budget: int) -> bool:
		p_match._reset(idx, string.length())

		var run_start := -1
		var run_len := 0

		# Search for the subsequence token in target starting from p_offset.
		# Record each substring for later scoring and display.
		var offset := p_offset
		var miss_budget := p_miss_budget

		for i in range(string.length()):
			var cp := string.unicode_at(i)
			var new_offset := FuzzySearch._find_codepoint(p_target, cp, offset)

			if new_offset < 0:
				miss_budget -= 1
				if miss_budget < 0:
					return false
			else:
				if run_start == -1 or offset != new_offset:
					if run_start != -1:
						p_match.add_substring(run_start, run_len)
					run_start = new_offset
					run_len = 1
				else:
					run_len += 1
				offset = new_offset + 1

		if run_start != -1:
			p_match.add_substring(run_start, run_len)

		return true


class FuzzyTokenMatch:
	const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
	const FuzzySearch := Namespace.FuzzySearch

	var score: int = 0
	var substrings: Array[Vector2i] = [] # x: start index, y: length

	var matched_length: int = 0
	var token_length: int = 0
	var token_idx: int = -1
	var interval: Vector2i = Vector2i(-1, -1) # inclusive indices


	func _reset(p_token_idx: int, p_token_length: int) -> void:
		score = 0
		substrings.clear()
		matched_length = 0
		token_length = p_token_length
		token_idx = p_token_idx
		interval = Vector2i(-1, -1)


	func add_substring(p_substring_start: int, p_substring_length: int) -> void:
		substrings.append(Vector2i(p_substring_start, p_substring_length))
		matched_length += p_substring_length
		var substring_interval := Vector2i(p_substring_start, p_substring_start + p_substring_length - 1)
		interval = FuzzySearch._extend_interval(interval, substring_interval)


	func get_miss_count() -> int:
		return token_length - matched_length


	func intersects(p_other_interval: Vector2i) -> bool:
		if not FuzzySearch._is_valid_interval(interval) or not FuzzySearch._is_valid_interval(p_other_interval):
			return false
		return interval.y >= p_other_interval.x and interval.x <= p_other_interval.y


	func is_case_insensitive(p_original: String, p_adjusted: String) -> bool:
		for substr in substrings:
			var end := substr.x + substr.y
			for i in range(substr.x, end):
				if p_original[i] != p_adjusted[i]:
					return true
		return false


class FuzzySearchResult:
	const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
	const FuzzySearch := Namespace.FuzzySearch

	var target: String = ""
	var score: int = 0
	var original_index: int = -1
	var dir_index: int = -1
	var token_matches: Array[FuzzyTokenMatch] = []

	var miss_budget: int = 0
	var match_interval: Vector2i = Vector2i(-1, -1)


	func _reset_for_search(p_target: String, p_dir_index: int, p_max_misses: int) -> void:
		target = p_target
		dir_index = p_dir_index
		miss_budget = p_max_misses
		score = 0
		match_interval = Vector2i(-1, -1)
		token_matches.clear()


	func can_add_token_match(p_match: FuzzyTokenMatch) -> bool:
		if p_match.get_miss_count() > miss_budget:
			return false

		if p_match.intersects(match_interval):
			if token_matches.size() == 1:
				return false
			for existing_match in token_matches:
				if existing_match.intersects(p_match.interval):
					return false

		return true


	func score_token_match(p_match: FuzzyTokenMatch, p_case_insensitive: bool) -> void:
		# Exact matches should almost always be prioritized over broken up matches.
		p_match.score = -20 * p_match.get_miss_count() - (3 if p_case_insensitive else 0)

		for substring in p_match.substrings:
			# Score longer substrings higher than short substrings.
			var substring_score: int = substring.y * substring.y

			# Score matches deeper in path higher than shallower matches.
			if substring.x > dir_index:
				substring_score *= 2

			# Score matches on a word boundary higher than matches within a word.
			if FuzzySearch._is_word_boundary(target, substring.x - 1) \
			or FuzzySearch._is_word_boundary(target, substring.x + substring.y):
				substring_score += 4

			# Score exact query matches higher than non-compact subsequence matches.
			if substring.y == p_match.token_length:
				substring_score += 100

			p_match.score += substring_score


	func add_token_match(p_match: FuzzyTokenMatch) -> void:
		score += p_match.score
		match_interval = FuzzySearch._extend_interval(match_interval, p_match.interval)
		miss_budget -= p_match.get_miss_count()
		token_matches.append(p_match)


	func maybe_apply_score_bonus() -> void:
		# Adds a small bonus to results which match tokens in the same order they appear in the query.
		var token_range_starts := PackedInt32Array()
		token_range_starts.resize(token_matches.size())

		for m in token_matches:
			token_range_starts[m.token_idx] = m.interval.x

		var last := token_range_starts[0]
		for i in range(1, token_matches.size()):
			if last > token_range_starts[i]:
				return
			last = token_range_starts[i]

		score += 1
