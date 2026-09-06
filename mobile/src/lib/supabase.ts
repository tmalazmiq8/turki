import 'react-native-url-polyfill/auto';
import { createClient } from '@supabase/supabase-js';

// Same Supabase project the Swift app uses (see ios-miyar/MIYAR/SupabaseConfig.swift)
// so signing up here or in the iOS app shares the same account and data.
// The publishable key is safe to ship in a client — it can only do what the
// database's Row Level Security policies allow (see supabase/schema.sql).
const SUPABASE_URL = 'https://wqiqyhrqsazarslozlgr.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_0F2tHsFhIxqDd9VVu6syxw_vssDX6kk';

// Plain in-memory session store — no native module involved at all. Some
// Expo Go builds can't reach @react-native-async-storage/async-storage's
// native side (its calls come back "Native module is null"), which made
// supabase-js's background token-refresh timer spam an uncaught-rejection
// red screen even though sign-in still worked underneath it. Trading
// cross-restart session persistence for zero native dependency removes
// that failure mode entirely; a real device/dev-client build can swap
// this back for AsyncStorage or expo-secure-store later.
const memoryStore = new Map<string, string>();

const memoryStorage = {
  async getItem(key: string): Promise<string | null> {
    return memoryStore.get(key) ?? null;
  },
  async setItem(key: string, value: string): Promise<void> {
    memoryStore.set(key, value);
  },
  async removeItem(key: string): Promise<void> {
    memoryStore.delete(key);
  },
};

export const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    storage: memoryStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
