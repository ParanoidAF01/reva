import 'api_service.dart';

class PostsService {
  final ApiService _apiService = ApiService();

  // Create a new post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    return await _apiService.post('/posts', postData);
  }

  // Get all posts
  Future<Map<String, dynamic>> getAllPosts() async {
    return await _apiService.get('/posts');
  }

  // Get my posts
  Future<Map<String, dynamic>> getMyPosts() async {
    return await _apiService.get('/posts/me');
  }

  // Get post by ID
  Future<Map<String, dynamic>> getPostById(String postId) async {
    return await _apiService.get('/posts/$postId');
  }

  // Update post
  Future<Map<String, dynamic>> updatePost(
      String postId, Map<String, dynamic> postData) async {
    return await _apiService.put('/posts/$postId', postData);
  }

  // Delete post
  Future<Map<String, dynamic>> deletePost(String postId) async {
    return await _apiService.delete('/posts/$postId');
  }

  // Toggle like on post
  Future<Map<String, dynamic>> toggleLike(String postId) async {
    return await _apiService.post('/posts/$postId/like', {});
  }

  // Add comment to post
  Future<Map<String, dynamic>> addComment(
      String postId, Map<String, dynamic> commentData) async {
    return await _apiService.post('/posts/$postId/comments', commentData);
  }

  // Delete comment
  Future<Map<String, dynamic>> deleteComment(
      String postId, String commentId) async {
    return await _apiService.delete('/posts/$postId/comments/$commentId');
  }
}
