import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseTestService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> testDatabaseConnection() async {
    if (kDebugMode) {
      print('🔍 Testing Supabase database connection...');

      try {
        final user = _supabase.auth.currentUser;
        print(
          '📱 Auth Status: ${user != null ? "Signed In" : "Not Signed In"}',
        );

        if (user != null) {
          print('👤 User ID: ${user.id}');
          print('📧 User Email: ${user.email}');

          try {
            final response = await _supabase
                .from('tasks')
                .select('count')
                .eq('user_id', user.id);

            print('✅ Tasks table accessible');
            print('📊 User tasks count: ${response.length}');
          } catch (e) {
            print('❌ Tasks table not accessible: $e');
            print(
              '💡 You need to create the tasks table in Supabase dashboard',
            );
            print('📋 Run the SQL script from supabase_schema.sql');
          }
        }

        print('🏥 Supabase connection: OK');
      } catch (e) {
        print('❌ Database connection test failed: $e');
      }
    }
  }

  static Future<void> testTaskCreation() async {
    if (kDebugMode) {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ Cannot test task creation: User not authenticated');
        return;
      }

      try {
        print('🧪 Testing task creation...');

        final testTask = {
          'title': 'Test Task - ${DateTime.now().millisecondsSinceEpoch}',
          'description':
              'This is a test task created by the database test service',
          'priority': 'couldDo',
          'is_completed': false,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        };

        final response = await _supabase
            .from('tasks')
            .insert(testTask)
            .select()
            .single();

        print('✅ Test task created successfully');
        print('📝 Task ID: ${response['id']}');

        await _supabase.from('tasks').delete().eq('id', response['id']);

        print('🗑️ Test task cleaned up');
      } catch (e) {
        print('❌ Task creation test failed: $e');
      }
    }
  }
}
