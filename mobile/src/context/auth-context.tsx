import type { Session } from '@supabase/supabase-js';
import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { supabase } from '@/lib/supabase';
import { S, type LText } from '@/lib/strings';

interface AuthContextValue {
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<LText | null>;
  signUp: (name: string, email: string, password: string, confirmation: string) => Promise<LText | null>;
  resetPassword: (email: string) => Promise<LText | null>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function isEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function mapAuthError(error: { message: string; status?: number } | null): LText | null {
  if (!error) return null;
  const message = error.message.toLowerCase();
  if (message.includes('already registered') || message.includes('already exists')) return S.errEmailTaken;
  if (message.includes('invalid login') || message.includes('invalid_credentials')) return S.errWrongCredentials;
  if (message.includes('password')) return S.errShortPassword;
  return { ar: error.message, en: error.message };
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setLoading(false);
    });
    const { data: subscription } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession);
    });
    return () => subscription.subscription.unsubscribe();
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      session,
      loading,
      async signIn(email, password) {
        const trimmed = email.trim().toLowerCase();
        if (!isEmail(trimmed)) return S.errInvalidEmail;
        const { error } = await supabase.auth.signInWithPassword({ email: trimmed, password });
        return mapAuthError(error);
      },
      async signUp(name, email, password, confirmation) {
        if (!name.trim()) return S.errEmptyName;
        const trimmed = email.trim().toLowerCase();
        if (!isEmail(trimmed)) return S.errInvalidEmail;
        if (password.length < 8) return S.errShortPassword;
        if (password !== confirmation) return S.errPasswordMismatch;

        const { data, error } = await supabase.auth.signUp({ email: trimmed, password });
        if (error) return mapAuthError(error);

        if (data.user) {
          // Best-effort profile row — the "profiles are updatable by owner"
          // RLS policy plus the protect_profile_trust_fields trigger (see
          // supabase/schema.sql) keep this safe even though it's a plain
          // client write.
          await supabase.from('profiles').upsert({
            id: data.user.id,
            name_ar: name,
            name_en: name,
          });
        }
        return null;
      },
      async resetPassword(email) {
        const trimmed = email.trim().toLowerCase();
        if (!isEmail(trimmed)) return S.errInvalidEmail;
        const { error } = await supabase.auth.resetPasswordForEmail(trimmed);
        return mapAuthError(error);
      },
      async signOut() {
        await supabase.auth.signOut();
      },
    }),
    [session, loading],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
