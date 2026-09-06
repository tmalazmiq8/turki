import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { I18nManager, View } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { AuthProvider, useAuth } from '@/context/auth-context';
import { LanguageProvider } from '@/context/language-context';
import { Theme } from '@/lib/theme';

SplashScreen.preventAutoHideAsync().catch(() => {});
I18nManager.allowRTL(true);

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
        <Stack.Screen
          name="material/[id]"
          options={{
            headerShown: true,
            headerStyle: { backgroundColor: Theme.canvas },
            headerTintColor: Theme.ink,
            headerTitle: '',
            headerBackTitle: '',
          }}
        />
      </Stack.Protected>
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <LanguageProvider>
        <AuthProvider>
          <RootNavigator />
        </AuthProvider>
      </LanguageProvider>
    </GestureHandlerRootView>
  );
}
