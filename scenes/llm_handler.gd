extends Node2D

var api_key : String = ""
var url : String= "https://api.openai.com/v1/chat/completions"
var temperature : float = 0.5
var max_tokens : int = 64
var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
var model : String = "o3-mini"
var messages = []
var request : HTTPRequest
var cache_message = "Didn't Work"

func _ready():
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)


	#dialogue_request("Give me the name of a animal from Hawaii")

func dialogue_request(player_dialogue):
	messages.append({
		"role" : "user",
		"content" : player_dialogue
		})
	var body = JSON.new().stringify({
		"messages" : messages,
		"model" : model
	})
	
	var send_request = request.request(url, headers, HTTPClient.METHOD_POST, body)
	#await get_tree().create_timer(60).timeout

	if send_request != OK:
		print("There was an error")
	
	await request.request_completed
	return cache_message

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("API Error: ", response_code, " - ", body.get_string_from_utf8())
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON parse error")
		return
	
	var response = json.get_data()
	if "choices" in response and response["choices"].size() > 0:
		var message = response["choices"][0]["message"]["content"]
		cache_message = message
	else:
		print("Unexpected API response format:", response)
	
