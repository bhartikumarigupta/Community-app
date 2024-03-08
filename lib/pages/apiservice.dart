// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/helper/helper_function.dart';
import 'package:http/http.dart' as http;

class APIService {
  Future<http.Response> requestOpenAI(String userInput, String mode,
      int maximumTokens, String api, String Model) async {
    final String openAiApiUrl =
        mode == "chat" ? "v1/chat/completions" : "v1/images/generations";
    const String url = "https://api.openai.com/";

    final body = mode == "chat"

        // as per OpenAI documentation for asking questions
        ? {
            "model": Model,
            "messages": [
              {
                "role": "system",
                "content":
                    "You are a helpful assistant. That help user to chat in a natural way. user will ask questions and you will answer them. short and simple"
              },
              {"role": "user", "content": userInput}
            ],
            "max_tokens": 2000,
            "temperature": 0,
            "n": 1
          }
        // for image generation as per OpenAI:
        : {
            "prompt": userInput,
          };

    final responseFromOpenAPI = await http.post(
      Uri.parse(url + openAiApiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $api"
      },
      body: jsonEncode(body),
    );

    return responseFromOpenAPI;
  }
}
