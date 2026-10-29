class DeleteUserResponseModel {
  final String message;

  DeleteUserResponseModel({required this.message});

  // Since the API response is plain text, we handle JSON accordingly
  factory DeleteUserResponseModel.fromJson(dynamic response) {
    if (response is String) {
      return DeleteUserResponseModel(message: response);
    } else if (response is Map<String, dynamic>) {
      return DeleteUserResponseModel(
          message: response["message"] ?? "No message");
    } else {
      throw Exception("Unexpected response format");
    }
  }
}
