# 🚀 Supabase Setup Instructions

Your ADHD Task Triage app is now ready for cloud sync with Supabase! Follow these steps to get it running:

## 📝 **Step 1: Create a Supabase Project**

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Click "New Project"
3. Choose your organization and enter:
   - **Project Name**: `adhd-task-triage`
   - **Database Password**: (choose a strong password)
   - **Region**: (choose closest to your location)
4. Click "Create new project" and wait 2-3 minutes

## 🔑 **Step 2: Get Your API Keys**

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (looks like: `https://your-project.supabase.co`)
   - **Project API Key** (anon, public - the long string)

## 🛠️ **Step 3: Update Configuration**

1. Open `lib/supabase_config.dart`
2. Replace the placeholder values:

```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

## 🗄️ **Step 4: Create the Database Table**

1. In Supabase dashboard, go to **Table Editor**
2. Click "Create a new table"
3. Table name: `tasks`
4. Add these columns:

| Column Name | Type | Primary | Default Value | Nullable |
|-------------|------|---------|---------------|----------|
| id | text | ✅ | | No |
| user_id | uuid | | auth.uid() | No |
| title | text | | | No |
| description | text | | | Yes |
| priority | text | | | No |
| is_completed | boolean | | false | No |
| created_at | timestamptz | | now() | No |

5. Click "Save"

## 🔒 **Step 5: Set Up Row Level Security (RLS)**

1. In Table Editor, click on your `tasks` table
2. Go to **Settings** tab → **Enable RLS**
3. Go to **Authentication** → **Policies**
4. Click "Create Policy" for the `tasks` table
5. Use this template for SELECT policy:

```sql
-- Allow users to view their own tasks
CREATE POLICY "Users can view own tasks" ON "public"."tasks"
AS PERMISSIVE FOR SELECT
TO authenticated
USING (auth.uid() = user_id)
```

6. Create similar policies for INSERT, UPDATE, DELETE operations.

## ⚡ **Step 6: Enable Authentication**

1. Uncomment the Supabase initialization in `main.dart`:

```dart
```

2. Update the home route in `main.dart`:

```dart
home: const HomeScreen(),

home: authService.isSignedIn ? const HomeScreen() : const LoginScreen(),
```

## 🎉 **That's It!**

Your app now has:
- ✅ **User Authentication** (Sign up/Sign in)
- ✅ **Cloud Sync** across all devices
- ✅ **Real-time Updates**
- ✅ **Offline Support** (Hive backup)
- ✅ **Secure Data** (Row Level Security)

## 🧪 **Demo Mode**

The app currently runs in **demo mode** with local storage only. This means:
- ✅ All features work locally
- ❌ No cloud sync yet
- ❌ No user authentication

To enable cloud features, just follow the setup steps above!

## 🆘 **Need Help?**

If you run into issues:
1. Check your Supabase project URL and API key are correct
2. Verify the database table was created properly
3. Make sure RLS policies are set up correctly
4. Check the Flutter console for any error messages

## 💡 **Pro Tips**

- **Free Tier**: Supabase gives you 50,000 monthly active users for free
- **No Credit Card**: Required only if you exceed free limits
- **Migration**: Your local tasks can be easily migrated to cloud storage
- **Backup**: Your Hive local storage acts as a perfect offline backup
