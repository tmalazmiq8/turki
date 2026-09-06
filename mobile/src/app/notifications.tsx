import Ionicons from '@expo/vector-icons/Ionicons';
import { useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { S, t, type LText } from '@/lib/strings';
import { Theme } from '@/lib/theme';

interface Notification {
  id: string;
  icon: keyof typeof Ionicons.glyphMap;
  text: LText;
  isRead: boolean;
}

const seedNotifications: Notification[] = [
  {
    id: '1',
    icon: 'chatbubble-ellipses-outline',
    text: { ar: 'علّق أحدهم على منشورك بالمجتمع', en: 'Someone commented on your community post' },
    isRead: false,
  },
  {
    id: '2',
    icon: 'shield-checkmark-outline',
    text: { ar: 'تحديث جديد على سجلات IFRA', en: 'New update on IFRA records' },
    isRead: false,
  },
  {
    id: '3',
    icon: 'bag-outline',
    text: { ar: 'إعلانك بالسوق حصل على مشاهدات جديدة', en: 'Your market listing got new views' },
    isRead: true,
  },
];

export default function NotificationsScreen() {
  const { language, isRTL } = useLanguage();
  const [notifications, setNotifications] = useState(seedNotifications);

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <FlatList
        data={notifications}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={<Text style={styles.emptyText}>{t(S.noNotifications, language)}</Text>}
        renderItem={({ item }) => (
          <Pressable
            onPress={() =>
              setNotifications((prev) => prev.map((n) => (n.id === item.id ? { ...n, isRead: true } : n)))
            }
          >
            <Card style={[styles.row, isRTL && styles.rowReverse, !item.isRead && styles.unread]}>
              <Ionicons name={item.icon} size={18} color={Theme.gold} />
              <Text style={[styles.text, { textAlign: isRTL ? 'right' : 'left' }]}>{t(item.text, language)}</Text>
              {!item.isRead ? <View style={styles.dot} /> : null}
            </Card>
          </Pressable>
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  list: { padding: Theme.margin, gap: 10 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  unread: { backgroundColor: Theme.goldSoft },
  text: { flex: 1, fontSize: 14, color: Theme.ink },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: Theme.gold },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
