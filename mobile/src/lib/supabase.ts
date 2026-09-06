import 'react-native-url-polyfill/auto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

// Same Supabase project the Swift app uses (see ios-miyar/MIYAR/SupabaseConfig.swift)
// so signing up here or in the iOS app shares the same account and data.
// The publishable key is safe to ship in a client — it can only do what the
// database's Row Level Security policies allow (see supabase/schema.sql).
const SUPABASE_URL = 'https://wqiqyhrqsazarslozlgr.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_0F2tHsFhIxqDd9VVu6syxw_vssDX6kk';

// AsyncStorage's native module isn't reachable in every Expo Go environment
// (it depends on exactly which build the Expo Go client shipped with). When
// it isn't, every call rejects, and supabase-js's background token-refresh
// timer turns that rejection into a recurring red error screen — even
// though sign-in/out still works. Falling back to an in-memory store keeps
// auth working everywhere; it just means the session won't survive an app
// restart on devices where the native module is unavailable.
const memoryStore = new Map<string, string>();

const resilientStorage = {
  async getItem(key: string): Promise<string | null> {
    try {
      return await AsyncStorage.getItem(key);
    } catch {
      return memoryStore.get(key) ?? null;
    }
  },
  async setItem(key: string, value: string): Promise<void> {
    try {
      await AsyncStorage.setItem(key, value);
    } catch {
      memoryStore.set(key, value);
    }
  },
  async removeItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch {
      memoryStore.delete(key);
    }
  },
};

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    storage: resilientStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
