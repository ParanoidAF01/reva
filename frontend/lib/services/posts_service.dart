import 'api_service.dart';

class PostsService {
  final ApiService _apiService = ApiService();

  // Create a new post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    try {
      return await _apiService.post('/posts', postData);
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get all posts
  Future<Map<String, dynamic>> getAllPosts() async {
    try {
      return await _apiService.get('/posts');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get my posts
  Future<Map<String, dynamic>> getMyPosts() async {
    try {
      return await _apiService.get('/posts/me');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Get post by ID
  Future<Map<String, dynamic>> getPostById(String postId) async {
    try {
      return await _apiService.get('/posts/$postId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Update post
  Future<Map<String, dynamic>> updatePost(
      String postId, Map<String, dynamic> postData) async {
    try {
      return await _apiService.put('/posts/$postId', postData);
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Delete post
  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      return await _apiService.delete('/posts/$postId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Toggle like on post
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      return await _apiService.post('/posts/$postId/like', {});
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Add comment to post
  Future<Map<String, dynamic>> addComment(
      String postId, Map<String, dynamic> commentData) async {
    try {
      return await _apiService.post('/posts/$postId/comments', commentData);
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  // Delete comment
  Future<Map<String, dynamic>> deleteComment(
      String postId, String commentId) async {
    try {
      return await _apiService.delete('/posts/$postId/comments/$commentId');
    } catch (e) {
      throw Exception(_filterError(e));
    }
  }

  String _filterError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Failed host lookup')) {
      return 'Network error: Please check your internet connection.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('401')) {
      return 'Session expired. Please log in again.';
    }
    // Add more filters as needed
    return msg.replaceAll('Exception:', '').trim();
  }
}
