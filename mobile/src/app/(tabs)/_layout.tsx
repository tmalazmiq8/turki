import Ionicons from '@expo/vector-icons/Ionicons';
import { Tabs } from 'expo-router';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function TabsLayout() {
  const { language } = useLanguage();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: Theme.gold,
        tabBarInactiveTintColor: Theme.secondaryText,
        tabBarStyle: { backgroundColor: Theme.surface, borderTopColor: Theme.hairline },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: t(S.tabHome, language),
          tabBarIcon: ({ color, size }) => <Ionicons name="home-outline" size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="calculator"
        options={{
          title: t(S.tabCalculator, language),
          tabBarIcon: ({ color, size }) => <Ionicons name="options-outline" size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="market"
        options={{
          title: t(S.tabMarket, language),
          tabBarIcon: ({ color, size }) => <Ionicons name="bag-outline" size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="community"
        options={{
          title: t(S.tabCommunity, language),
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="chatbubbles-outline" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="account"
        options={{
          title: t(S.tabAccount, language),
          tabBarIcon: ({ color, size }) => <Ionicons name="person-outline" size={size} color={color} />,
        }}
      />
    </Tabs>
  );
}
