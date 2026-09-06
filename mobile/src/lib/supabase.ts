import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

// Same Supabase project the Swift app uses (see ios-miyar/MIYAR/SupabaseConfig.swift)
// so signing up here or in the iOS app shares the same account and data.
// The publishable key is safe to ship in a client — it can only do what the
// database's Row Level Security policies allow (see supabase/schema.sql).
const SUPABASE_URL = 'https://wqiqyhrqsazarslozlgr.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_0F2tHsFhIxqDd9VVu6syxw_vssDX6kk';

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
