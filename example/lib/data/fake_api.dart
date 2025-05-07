import 'dart:io';

class FakeNetwork {
  Future<int> get(String path) async {
    await Future.delayed(const Duration(seconds: 2));

    if (path == '/ok') {
      return HttpStatus.ok;
    }
    if (path == '/not-found') {
      return HttpStatus.notFound;
    }

    throw const HttpException('Internal Server Error');
  }
}
