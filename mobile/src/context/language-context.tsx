import { createContext, useContext, useMemo, useState, type ReactNode } from 'react';
import type { Language } from '@/lib/strings';

// No persistence across app restarts on purpose — see the comment in
// lib/supabase.ts. The language choice just lives for the current session.
interface LanguageContextValue {
  language: Language;
  isRTL: boolean;
  toggleLanguage: () => void;
  setLanguage: (language: Language) => void;
}

const LanguageContext = createContext<LanguageContextValue | null>(null);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguage] = useState<Language>('ar');

  const value = useMemo<LanguageContextValue>(
    () => ({
      language,
      isRTL: language === 'ar',
      toggleLanguage: () => setLanguage((current) => (current === 'ar' ? 'en' : 'ar')),
      setLanguage,
    }),
    [language],
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useLanguage(): LanguageContextValue {
  const ctx = useContext(LanguageContext);
  if (!ctx) throw new Error('useLanguage must be used within LanguageProvider');
  return ctx;
}
