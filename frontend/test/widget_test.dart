import 'package:flutter_test/flutter_test.dart';
import 'package:thriftshop_koeln/services/api_service.dart';
import 'package:thriftshop_koeln/services/auth_service.dart';

void main() {
  test('ApiService class exists', () {
    expect(ApiService, isNotNull);
  });
  
  test('AuthService class exists', () {
    expect(AuthService, isNotNull);
  });
}
