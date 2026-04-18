extends Node2D

# --- 変数設定 ---
var ball_pos = Vector2(100, 100)
var ball_vel = Vector2(0, 0)
var gravity = 600.0
var points = []
var goal_pos = Vector2(550, 450)
var goal_radius = 40.0
var is_cleared = false

func _process(delta):
	if is_cleared:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			get_tree().reload_current_scene()
		return

	# 1. 線を引く
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var m_pos = get_local_mouse_position()
		if points.size() == 0 or points[-1].distance_to(m_pos) > 5:
			points.append(m_pos)

	# 2. ボールの移動と物理
	ball_vel.y += gravity * delta
	var next_pos = ball_pos + ball_vel * delta

	if points.size() > 1:
		for i in range(points.size() - 1):
			var p1 = points[i]
			var p2 = points[i+1]
			var line_vec = p2 - p1
			var t = clamp((ball_pos - p1).dot(line_vec) / line_vec.length_squared(), 0, 1)
			var closest = p1 + line_vec * t
			
			if ball_pos.distance_to(closest) < 15:
				var normal = (ball_pos - closest).normalized()
				ball_vel = ball_vel.bounce(normal) * 0.4
				next_pos = closest + normal * 16
	
	ball_pos = next_pos

	# 3. ゴール判定
	if ball_pos.distance_to(goal_pos) < goal_radius:
		if not is_cleared:
			print("GOAL!") # コンソールに出力
			is_cleared = true

	queue_redraw()

func _draw():
	# 背景
	draw_rect(get_viewport_rect(), Color(0.1, 0.1, 0.1))

	# ゴール (クリアしたら色が変わる)
	draw_circle(goal_pos, goal_radius, Color.GREEN if is_cleared else Color.GOLD)
	
	# 描いた線
	if points.size() > 1:
		draw_polyline(points, Color.WHITE, 5.0)
	
	# ボール
	draw_circle(ball_pos, 15, Color.CYAN)

	# クリア演出（文字を使わず四角形で表示）
	if is_cleared:
		draw_rect(Rect2(200, 200, 200, 100), Color.DARK_SLATE_BLUE)
		# 簡易的な「OK」の図形
		draw_line(Vector2(250, 250), Vector2(270, 270), Color.WHITE, 5)
		draw_line(Vector2(270, 270), Vector2(320, 220), Color.WHITE, 5)
