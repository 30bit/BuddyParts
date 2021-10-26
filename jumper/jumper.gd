class_name Jumper
extends KinematicBody2D

export (float, 0, 10) var vertical_rush
export (float, 0, 10) var horizontal_rush
export (float, 0, 1) var vertical_bounce
export (float, 0, 1) var horizontal_bounce

export (Curve) var move_speed
export (float, 0, 10) var move_period
export (bool) var move_wraps

export (Curve) var floor_friction
export (float, 0, 10) var floor_period
export (bool) var floor_wraps

export (Curve) var jump_speed
export (float, 0, 10) var jump_period
export (bool) var jump_wraps

export (Curve) var air_resistance
export (float, 0, 10) var air_period
export (bool) var air_wraps

export (Curve) var gravity
export (float, 0, 10) var gravity_period
export (bool) var gravity_wraps

var velocity: Vector2

var _t_move: float
var _t_brake: float
var _t_charge: float
var _t_gravity: float
var _airborne: bool
var _frozen: bool

enum HorizontalInput { NONE, LEFT, RIGHT }
enum VerticalInput { NONE, CHARGE, JUMP }

signal flip_left
signal flip_right
signal begin_move
signal begin_brake
signal begin_charge
signal jump
signal begin_fly
signal land
signal bounce
signal freeze
signal unfreeze

func freeze_kinematics():
	if not _frozen:
		emit_signal("freeze")
		_frozen = true
		forget_state()

func unfreeze_kinematics():
	if _frozen:
		emit_signal("unfreeze")
		_frozen = false
		forget_state()

func move_and_jump(delta: float, horizontal_input: int, vertical_input: int):
	if _frozen:
		return
	gravitate(delta)
	if is_on_floor():
		if _airborne:
			_airborne = false
			emit_signal("land")
		_input_horizontal(delta, horizontal_input)
		
		if vertical_input == VerticalInput.CHARGE:
			charge(delta)
			if _t_charge == 0:
				emit_signal("begin_charge")
		if vertical_input == VerticalInput.JUMP:
			jump()
			velocity.y *= vertical_rush
			velocity.x *= log(abs(velocity.x / 2)) * horizontal_rush
			emit_signal("jump")
	else:
		fly(delta)
		if not _airborne:
			_airborne = true
			emit_signal("begin_fly")
		var normal := Vector2.ZERO
		for i in range(get_slide_count()):
			normal += get_slide_collision(i).normal
		if normal != Vector2.ZERO:
			velocity.x += normal.normalized().x * velocity.length() * horizontal_bounce
			velocity.y *= vertical_bounce
			emit_signal("bounce")
	velocity = move_and_slide(velocity, Vector2.UP)

func _input_horizontal(delta: float, horizontal_input: int):
	match horizontal_input:
				HorizontalInput.RIGHT:
					if _t_brake != 0:
						emit_signal("begin_move")
						_t_brake = 0
					if face_right(delta) == _Face.FLIP:
						emit_signal("flip_right")
				HorizontalInput.LEFT:
					if _t_brake != 0:
						emit_signal("begin_move")
						_t_brake = 0
					if face_left(delta) != _Face.FLIP:
						emit_signal("flip_left")
				HorizontalInput.NONE:
					if _t_brake == 0:
						emit_signal("begin_brake")
						_t_move = 0
						_t_charge = 0
					brake(delta)

func forget_state():
	_t_gravity = 0
	_t_move = 0
	_t_brake = 0
	_t_charge = 0
	_airborne = !is_on_floor()

enum _Face { FLIP, CONTINUE }

func face_left(delta: float) -> int:
	var face = _Face.CONTINUE
	if velocity.x > 0:
		_t_move = 0
		_t_charge = 0
		_t_brake = 0
		face = _Face.FLIP
	velocity.x = lerp(velocity.x, -_map(_t_move, move_period, move_speed), 0.5)
	_t_move = _next(_t_move, delta, move_period, move_wraps)
	return face

func face_right(delta: float) -> int:
	var face = _Face.CONTINUE
	if velocity.x < 0:
		_t_move = 0
		_t_charge = 0
		_t_brake = 0
		face = _Face.FLIP
	velocity.x = lerp(velocity.x, _map(_t_move, move_period, move_speed), 0.5)
	_t_move = _next(_t_move, delta, move_period, move_wraps)
	return face

func brake(delta: float):
	var acceleration = _map(_t_brake, floor_period, floor_friction)
	_t_brake = _next(_t_brake, delta, floor_period, floor_wraps)
	velocity.x = lerp(velocity.x - acceleration, 0, acceleration)

func fly(delta: float):
	var acceleration = _map(_t_brake, air_period, air_resistance)
	_t_brake = _next(_t_brake, delta, air_period, air_wraps)
	velocity.x = lerp(velocity.x, 0, acceleration)

func charge(delta: float):
	_t_charge = _next(_t_charge, delta, jump_period, jump_wraps)

func gravitate(delta: float):
	velocity.y += _map(_t_gravity, gravity_period, gravity)
	_t_gravity = _next(_t_gravity, delta, gravity_period, gravity_wraps)

func jump():
	velocity.y -= _map(_t_charge, jump_period, jump_speed)
	_t_gravity = 0
	_t_move = 0
	_t_brake = 0
	_t_charge = 0

func _next(accum: float, delta: float, period: float, wraps: bool) -> float:
	accum += delta
	if accum > period:
		if wraps: 
			return fmod(accum, period)
		else:
			return period
	return accum

func _map(next: float, period: float, curve: Curve) -> float:
	return abs(curve.interpolate(next / period))
