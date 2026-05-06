import 'package:flutter_test/flutter_test.dart';
import 'package:thriftshop_koeln/services/api_service.dart';
import 'package:thriftshop_koeln/services/auth_service.dart';

void main() {
  print('=== Flutter Service Tests ===');
  
  test('ApiService class exists', () {
    expect(ApiService, isNotNull);
    print('✓ ApiService class is available');
  });
  
  test('AuthService class exists', () {
    expect(AuthService, isNotNull);
    print('✓ AuthService class is available');
  });
  
  print('=== Service Tests completed ===');
}
