extends CanvasLayer

@onready var time_label: Label = $Control/TimeLabel
@onready var sun: DirectionalLight2D = $DirectionalLight2D

var game_hour: float = 19.00
const SECONDS_PER_HOUR: float = 45.0

# Keyframy: godzina → [godzina, energy, color]
# Subtract mode: energy 0.0 = jasno, 1.0 = ciemno
const KEYFRAMES = [
	[0.0,  1.0,  Color(0.834, 0.841, 0.965, 1.0)],   # północ     — ciemno, niebiesko
	[4.0,  1.0,  Color(0.834, 0.841, 0.965, 1.0)],   # 4:00       — nadal noc
	[6.0,  0.0,  Color(1.0, 0.95, 0.8)],  # 6:00 świt  — jasno, ciepło
	[12.0, 0.0,  Color(1.0, 1.0,  1.0)],  # południe   — pełne światło
	[18.0, 0.0,  Color(1.0, 0.8,  0.5)],  # 18:00      — złota godzina
	[20.0, 0.5,  Color(0.8, 0.4,  0.2)],  # 20:00      — zachód
	[22.0, 1.0,  Color(0.834, 0.841, 0.965, 1.0)],  # 22:00      — noc
	[24.0, 1.0,  Color(0.834, 0.841, 0.965 , 1.0)],  # 24:00 = 0  — noc
]

func _process(delta: float) -> void:
	game_hour += delta / SECONDS_PER_HOUR  # SZYBKOSC DNIA JAK PRZEZ MNIEJSZA LICZBA TO SZYBCIEJ LECI DZIEN
	if game_hour >= 24.0:
		game_hour -= 24.0

	_update_light_smooth()
	_update_label()

func _update_light_smooth() -> void:
	# Znajdź między którymi keyframami jesteśmy
	for i in range(KEYFRAMES.size() - 1):
		var hour0: float   = KEYFRAMES[i][0]
		var hour1: float   = KEYFRAMES[i + 1][0]

		if game_hour >= hour0 and game_hour < hour1:
			# t = ile przeszliśmy między h0 a h1 (0.0 → 1.0)
			var t: float = remap(game_hour, hour0, hour1, 0.0, 1.0)

			var e0: float  = KEYFRAMES[i][1]
			var e1: float  = KEYFRAMES[i + 1][1]
			var c0: Color  = KEYFRAMES[i][2]
			var c1: Color  = KEYFRAMES[i + 1][2]

			sun.energy = lerp(e0, e1, t)
			sun.color  = c0.lerp(c1, t)
			return

func _update_label() -> void:
	var h = int(game_hour)
	var m = int((game_hour - h) * 60.0)
	time_label.text = "%02d:%02d" % [h, m]
