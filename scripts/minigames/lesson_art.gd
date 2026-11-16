class_name LessonArt
extends RefCounted
## Shared look for the hands-on lessons (Days 1-3): the world dimmed behind a framed panel,
## a stage area for the activity, step pips, a footer and a result card. Drawing only.

const PANEL := Rect2(16, 12, 448, 246)
const STAGE := Rect2(28, 56, 424, 158)
const STAGE_BG := Color("0c1226")
const SHADOW := Color(0.0, 0.0, 0.0, 0.45)


static func frame(c: CanvasItem, t: float, title: String, why: String, accent: Color) -> void:
	c.draw_rect(Rect2(0, 0, 480, 270), Color(0.02, 0.03, 0.08, 0.78))
	c.draw_rect(Rect2(PANEL.position + Vector2(3, 4), PANEL.size), SHADOW)
	c.draw_rect(PANEL, UiKit.PANEL)
	c.draw_rect(PANEL, accent, false, 1.0)
	c.draw_rect(PANEL.grow(-2), Color(accent, 0.25), false, 1.0)
	for corner in [PANEL.position, Vector2(PANEL.end.x - 4, PANEL.position.y), Vector2(PANEL.position.x, PANEL.end.y - 4), PANEL.end - Vector2(4, 4)]:
		c.draw_rect(Rect2(corner, Vector2(4, 4)), accent)
	# Header strip with a small blinking "live" light.
	c.draw_rect(Rect2(PANEL.position + Vector2(2, 2), Vector2(PANEL.size.x - 4, 38)), Color(accent, 0.10))
	c.draw_rect(Rect2(PANEL.position.x + 10, 25, 5, 5), accent if int(t * 2.0) % 2 == 0 else Color(accent, 0.3))
	UiKit.draw_text(c, Vector2(PANEL.position.x + 20, 31), title, "title", UiKit.AMBER)
	UiKit.draw_text(c, Vector2(PANEL.position.x + 12, 47), why, "small", UiKit.TEXT)
	# Stage.
	c.draw_rect(STAGE, STAGE_BG)
	for x in range(int(STAGE.position.x) + 8, int(STAGE.end.x), 16):
		for y in range(int(STAGE.position.y) + 8, int(STAGE.end.y), 16):
			c.draw_rect(Rect2(x, y, 1, 1), Color(1, 1, 1, 0.06))
	c.draw_rect(STAGE, UiKit.LINE, false, 1.0)


## Instruction line inside the stage's top-left, on a dark chip.
static func instruction(c: CanvasItem, text: String) -> void:
	var w := UiKit.text_width(text, "small") + 12.0
	c.draw_rect(Rect2(STAGE.position + Vector2(4, 4), Vector2(w, 13)), Color(0, 0, 0, 0.55))
	UiKit.draw_text(c, STAGE.position + Vector2(10, 14), text, "small", UiKit.TEXT)


static func pips(c: CanvasItem, right_top: Vector2, done: int, total: int, accent: Color) -> void:
	for i in total:
		var r := Rect2(right_top + Vector2(-total * 9 + i * 9, 0), Vector2(6, 6))
		c.draw_rect(r, accent if i < done else UiKit.LINE)
		if i == done:
			c.draw_rect(r.grow(1), accent, false, 1.0)


static func footer(c: CanvasItem, feedback: String, caveat: String) -> void:
	if not feedback.is_empty():
		c.draw_rect(Rect2(28, 218, 424, 14), Color(UiKit.TEAL, 0.12))
		UiKit.draw_text(c, Vector2(34, 228), feedback, "small", UiKit.TEXT)
	UiKit.draw_text(c, Vector2(28, 248), caveat, "small", UiKit.TEXT_DIM)
	UiKit.draw_text(c, Vector2(PANEL.end.x - 12 - UiKit.text_width("Esc: leave", "small"), 248), "Esc: leave", "small", UiKit.TEXT_DIM)


static func star(c: CanvasItem, at: Vector2, r: float, filled: bool) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + i * PI / 5.0
		pts.append(at + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	if filled:
		c.draw_colored_polygon(pts, UiKit.AMBER)
	pts.append(pts[0])
	c.draw_polyline(pts, UiKit.AMBER if filled else UiKit.LINE, 1.0)


## The finished card: stars, "You learned", and the keys. Returns the stage rect left below it.
static func result(c: CanvasItem, t: float, stars: int, learned: String) -> void:
	var card := Rect2(STAGE.position + Vector2(20, 10), Vector2(STAGE.size.x - 40, 98))
	c.draw_rect(card, Color(UiKit.GREEN, 0.10))
	c.draw_rect(card, UiKit.GREEN, false, 1.0)
	UiKit.draw_text(c, card.position + Vector2(12, 18), "TRAINING COMPLETE!", "title", UiKit.GREEN)
	for i in 3:
		var pop := clampf(t * 3.0 - i * 0.6, 0.0, 1.0)
		star(c, card.position + Vector2(card.size.x - 60 + i * 20, 14), 4.0 + 3.0 * pop, i < stars and pop >= 1.0)
	UiKit.draw_text(c, card.position + Vector2(12, 40), "YOU LEARNED", "small", UiKit.AMBER)
	var y := 54.0
	for line in wrap_text(learned, card.size.x - 24):
		UiKit.draw_text(c, card.position + Vector2(12, y), line, "small", UiKit.TEXT)
		y += 12.0
	var keys := "E: finish and earn it"
	var blink := 1.0 if int(t * 2.5) % 2 == 0 else 0.45
	UiKit.draw_text(c, card.position + Vector2(12, card.size.y - 6), "> " + keys, "small", Color(UiKit.AMBER, blink))


static func wrap_text(text: String, width: float) -> PackedStringArray:
	var lines := PackedStringArray()
	var line := ""
	for word in text.split(" "):
		var next := word if line.is_empty() else line + " " + word
		if UiKit.text_width(next, "small") > width and not line.is_empty():
			lines.append(line)
			line = word
		else:
			line = next
	if not line.is_empty():
		lines.append(line)
	return lines


## A selectable choice chip; the chosen one blinks and gets an arrow (never colour alone).
static func chip(c: CanvasItem, r: Rect2, label: String, chosen: bool, t: float) -> void:
	var on := chosen and int(t * 3.0) % 2 == 0
	c.draw_rect(r, Color(UiKit.AMBER, 0.18) if chosen else Color(0, 0, 0, 0.35))
	c.draw_rect(r, UiKit.AMBER if on else (UiKit.AMBER_DIM if chosen else UiKit.LINE), false, 1.0)
	var text := ("> " if chosen else "") + label
	UiKit.draw_text(c, Vector2(r.position.x + (r.size.x - UiKit.text_width(text, "small")) / 2.0, r.position.y + r.size.y / 2.0 + 4.0), text, "small", UiKit.AMBER if chosen else UiKit.TEXT)


static func stars_for(mistakes: int) -> int:
	return maxi(1, 3 - mistakes / 3)
