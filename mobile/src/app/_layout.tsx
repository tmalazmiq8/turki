import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { I18nManager, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { AuthProvider, useAuth } from '@/context/auth-context';
import { DataProvider } from '@/context/data-context';
import { LanguageProvider } from '@/context/language-context';
import { Theme } from '@/lib/theme';

SplashScreen.preventAutoHideAsync().catch(() => {});
I18nManager.allowRTL(true);

const detailHeaderOptions = {
  headerShown: true,
  headerStyle: { backgroundColor: Theme.canvas },
  headerTintColor: Theme.ink,
  headerTitle: '',
  headerBackTitle: '',
} as const;

function RootNavigator() {
  const { session, loading } = useAuth();

  useEffect(() => {
    if (!loading) SplashScreen.hideAsync().catch(() => {});
  }, [loading]);

  if (loading) return <View style={{ flex: 1, backgroundColor: Theme.canvas }} />;

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Protected guard={!session}>
        <Stack.Screen name="(auth)" />
      </Stack.Protected>
      <Stack.Protected guard={!!session}>
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="material/[id]" options={detailHeaderOptions} />
        <Stack.Screen name="materials" options={detailHeaderOptions} />
        <Stack.Screen name="ifra" options={detailHeaderOptions} />
        <Stack.Screen name="listing/[id]" options={detailHeaderOptions} />
        <Stack.Screen name="formula/[id]" options={detailHeaderOptions} />
      </Stack.Protected>
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <LanguageProvider>
        <AuthProvider>
          <DataProvider>
            <RootNavigator />
          </DataProvider>
        </AuthProvider>
      </LanguageProvider>
    </GestureHandlerRootView>
  );
}
