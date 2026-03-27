extends PanelContainer

const TALK_ICO: CompressedTexture2D = preload("res://aseets/talk_ico.svg")
const KEYBOARD_ICO: CompressedTexture2D = preload("res://aseets/keyboard_ico.svg")
const KEYBOARD_SAFE_MARGIN: float = 24.0 # 虚拟键盘与输入框之间的安全距离，单位为像素
const BAR_MOVE_SPEED_UP: float = 80.0 # 输入法弹出时，底部栏移动的速度，数值越大移动越快
const BAR_MOVE_SPEED_DOWN: float = 8.0 # 输入法收起时，底部栏移动的速度，数值越大移动越快

var input_mode: bool = true # true: 输入模式，false: 语音模式
var record_text: String # 录音按钮的初始文本
var base_offset_top: float # 底部栏的初始顶部偏移，用于计算虚拟键盘弹出时的调整
var base_offset_bottom: float # 底部栏的初始底部偏移，用于计算虚拟键盘弹出时的调整
var current_lift: float # 当前底部栏的提升高度，用于平滑过渡虚拟键盘弹出或收起时的动画
var support_virtual_keyboard: bool # 是否支持虚拟键盘功能，基于当前平台的特性进行判断

@onready var switch_input: Button = $VBoxContainer/HBoxContainer/SwitchInput
@onready var edit_container: MarginContainer = $VBoxContainer/EditContainer
@onready var record: Button = $VBoxContainer/HBoxContainer/Record

func _ready() -> void:
	record_text = record.text
	base_offset_top = offset_top
	base_offset_bottom = offset_bottom
	support_virtual_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)

func _process(delta: float) -> void:
	_match_virtual_keyboard(delta)

func _on_swicth_input_pressed() -> void:
	input_mode = !input_mode
	edit_container.visible = !input_mode
	record.text = record_text if input_mode else ""
	switch_input.icon = TALK_ICO if input_mode else KEYBOARD_ICO
	if input_mode && support_virtual_keyboard:
		DisplayServer.virtual_keyboard_hide()

func _match_virtual_keyboard(delta: float) -> void:
	if !support_virtual_keyboard:
		return
	var keyboard_height: float = float(DisplayServer.virtual_keyboard_get_height())
	var target_lift: float = (keyboard_height + KEYBOARD_SAFE_MARGIN) if keyboard_height > 0.0 else 0.0
	var move_speed: float = BAR_MOVE_SPEED_UP if target_lift > current_lift else BAR_MOVE_SPEED_DOWN
	current_lift = lerp(current_lift, target_lift, move_speed * delta)
	if absf(current_lift - target_lift) < 0.5:
		current_lift = target_lift
	offset_top = base_offset_top - current_lift
	offset_bottom = base_offset_bottom - current_lift