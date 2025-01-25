extends Control

signal resume
@onready var _vbox = $ScrollContainer/MarginContainer/VBoxContainer
@onready var _xr = Util.is_xr()
@onready var post_processing_options = ["none", "crt"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  GlobalMenuEvents.ui_cancel_pressed.connect(ui_cancel_pressed)
  if _xr:
    _vbox.get_node("FPSOptions").visible = false
    _vbox.get_node("ReflectionOptions").visible = false
    _vbox.get_node("DisplayOptions").visible = false

func ui_cancel_pressed():
  if visible:
    call_deferred("_on_resume_pressed")

func _on_visibility_changed():
  if visible and is_inside_tree():
    _load_settings()
    _vbox.get_node("MainOptions/Back").grab_focus()

func _load_settings():
  var e = GraphicsManager.get_env()

  _vbox.get_node("FPSOptions/MaxFPS").value = GraphicsManager.fps_limit
  _vbox.get_node("FPSOptions/LimitFPS").button_pressed = GraphicsManager.limit_fps
  _vbox.get_node("DisplayOptions/Fullscreen").button_pressed = GraphicsManager.fullscreen
  _vbox.get_node("DisplayOptions/RenderScale").value = GraphicsManager.render_scale
  _vbox.get_node("ReflectionOptions/ReflectionQuality").value = e.ssr_max_steps
  _vbox.get_node("ReflectionOptions/EnableReflections").button_pressed = e.ssr_enabled
  _vbox.get_node("LightOptions/AmbientLight").value = e.ambient_light_energy
  _vbox.get_node("LightOptions/EnableSSIL").button_pressed = e.ssil_enabled
  _vbox.get_node("FogOptions/EnableFog").button_pressed = e.fog_enabled

  var post_processing = GraphicsManager.post_processing
  var idx = post_processing_options.find(post_processing)
  _vbox.get_node("PostProcessingOptions/PostProcessingEffect").select(idx if idx >= 0 else 0)

  _refresh_cache_label()

func _on_restore_pressed():
  GraphicsManager.restore_default_settings()
  _load_settings()

func _on_resume_pressed():
  GraphicsManager.save_settings()
  emit_signal("resume")

func _on_reflection_quality_value_changed(value: float):
  GraphicsManager.get_env().ssr_max_steps = int(value)
  _vbox.get_node("ReflectionOptions/ReflectionQualityValue").text = str(int(value))

func _on_enable_reflections_toggled(toggled_on: bool):
  GraphicsManager.get_env().ssr_enabled = toggled_on

func _on_enable_ssil_toggled(toggled_on: bool):
  GraphicsManager.get_env().ssil_enabled = toggled_on

func _on_ambient_light_value_changed(value: float):
  GraphicsManager.get_env().ambient_light_energy = value
  _vbox.get_node("LightOptions/AmbientLightValue").text = "%3.2f" % value

func _on_max_fps_value_changed(value: float):
  GraphicsManager.set_fps_limit(value)
  _vbox.get_node("FPSOptions/MaxFPSValue").text = str(int(value))

func _on_limit_fps_toggled(toggled_on: bool):
  GraphicsManager.enable_fps_limit(toggled_on)

func _on_enable_fog_toggled(toggled_on: bool):
  GraphicsManager.get_env().fog_enabled = toggled_on

func _on_clear_cache_pressed():
  CacheControl.clear_cache()
  _refresh_cache_label()

func _refresh_cache_label():
  var result = CacheControl.get_cache_size()
  _vbox.get_node("CacheOptions/CacheLabel").text = "Cache (%s items, %3.2f GB)" % [result.count, result.size / 1000000000.0]

func _on_fullscreen_toggled(toggled_on: bool):
  GraphicsManager.set_fullscreen(toggled_on)

func _on_render_scale_value_changed(value: float):
  GraphicsManager.set_render_scale(value)
  _vbox.get_node("DisplayOptions/RenderScaleValue").text = str(value)

func _on_pause_menu_settings() -> void:
  pass # Replace with function body.

func _on_post_processing_effect_item_selected(index: int):
  GraphicsManager.set_post_processing(post_processing_options[index])
