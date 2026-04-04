extends Node

signal rewarded_ad_completed
signal rewarded_ad_failed
signal interstitial_shown

# Replace with your real AdMob ad unit IDs before publishing
const ANDROID_REWARDED_AD_ID: String = "ca-app-pub-3940256099942544/5224354917"  # test ID
const ANDROID_INTERSTITIAL_AD_ID: String = "ca-app-pub-3940256099942544/1033173712"  # test ID
const IOS_REWARDED_AD_ID: String = "ca-app-pub-3940256099942544/1712485313"  # test ID
const IOS_INTERSTITIAL_AD_ID: String = "ca-app-pub-3940256099942544/4411468910"  # test ID

var _admob: Node = null
var _rewarded_loaded: bool = false
var _interstitial_loaded: bool = false
var _games_since_last_interstitial: int = 0
const INTERSTITIAL_GAME_FREQUENCY: int = 3

func _ready() -> void:
	_init_admob()

func _init_admob() -> void:
	# The AdMob plugin registers as a singleton named "AdMob"
	# It is only available when the Android/iOS plugin is installed
	if Engine.has_singleton("AdMob"):
		_admob = Engine.get_singleton("AdMob")
		_connect_admob_signals()
		_load_rewarded_ad()
		_load_interstitial_ad()
	else:
		print("[AdManager] AdMob plugin not found. Running in stub mode.")

func _connect_admob_signals() -> void:
	if _admob == null:
		return
	if _admob.has_signal("rewarded_ad_loaded"):
		_admob.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	if _admob.has_signal("rewarded_ad_failed_to_load"):
		_admob.rewarded_ad_failed_to_load.connect(_on_rewarded_failed)
	if _admob.has_signal("rewarded_ad_earned_reward"):
		_admob.rewarded_ad_earned_reward.connect(_on_rewarded_earned)
	if _admob.has_signal("interstitial_ad_loaded"):
		_admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	if _admob.has_signal("interstitial_ad_closed"):
		_admob.interstitial_ad_closed.connect(_on_interstitial_closed)

func _get_rewarded_id() -> String:
	if OS.get_name() == "iOS":
		return IOS_REWARDED_AD_ID
	return ANDROID_REWARDED_AD_ID

func _get_interstitial_id() -> String:
	if OS.get_name() == "iOS":
		return IOS_INTERSTITIAL_AD_ID
	return ANDROID_INTERSTITIAL_AD_ID

func _load_rewarded_ad() -> void:
	if _admob == null:
		return
	_admob.load_rewarded_ad(_get_rewarded_id())

func _load_interstitial_ad() -> void:
	if _admob == null:
		return
	_admob.load_interstitial_ad(_get_interstitial_id())

func show_rewarded_ad() -> void:
	if GameManager.is_ads_removed:
		emit_signal("rewarded_ad_completed")
		return
	if _admob == null:
		# Stub: always succeed in editor/non-mobile
		emit_signal("rewarded_ad_completed")
		return
	if _rewarded_loaded:
		_admob.show_rewarded_ad()
	else:
		emit_signal("rewarded_ad_failed")

func maybe_show_interstitial() -> void:
	if GameManager.is_ads_removed:
		return
	_games_since_last_interstitial += 1
	if _games_since_last_interstitial >= INTERSTITIAL_GAME_FREQUENCY:
		_games_since_last_interstitial = 0
		if _admob != null and _interstitial_loaded:
			_admob.show_interstitial_ad()
		# else: silently skip

func _on_rewarded_loaded() -> void:
	_rewarded_loaded = true

func _on_rewarded_failed(_error_code: int) -> void:
	_rewarded_loaded = false
	emit_signal("rewarded_ad_failed")

func _on_rewarded_earned(_currency: String, _amount: int) -> void:
	_rewarded_loaded = false
	emit_signal("rewarded_ad_completed")
	_load_rewarded_ad()

func _on_interstitial_loaded() -> void:
	_interstitial_loaded = true

func _on_interstitial_closed() -> void:
	_interstitial_loaded = false
	emit_signal("interstitial_shown")
	_load_interstitial_ad()
