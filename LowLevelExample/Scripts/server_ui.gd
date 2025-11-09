extends CanvasLayer


func _on_server_button_pressed() -> void:
	NetworkHandler.startServer()
	visible = false

func _on_client_button_pressed() -> void:
	NetworkHandler.startClient()
	visible = false
