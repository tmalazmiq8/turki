import Ionicons from '@expo/vector-icons/Ionicons';
import { Link } from 'expo-router';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { bookChapters, estimatedMinutes } from '@/data/book';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function BookListScreen() {
  const { language, isRTL } = useLanguage();

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <FlatList
        data={bookChapters}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={styles.list}
        ListHeaderComponent={
          <View style={{ marginBottom: 12 }}>
            <Text style={[styles.pageTitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.book, language)}</Text>
            <Text style={[styles.pageSubtitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.bookSubtitle, language)}</Text>
          </View>
        }
        renderItem={({ item }) => (
          <Link href={{ pathname: '/book/[id]', params: { id: item.id } }} asChild>
            <Pressable disabled={item.isPremium}>
              <Card style={[styles.row, isRTL && styles.rowReverse, item.isPremium && styles.locked]}>
                <View style={styles.numberWrap}>
                  <Text style={styles.number}>{item.id}</Text>
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{t(item.title, language)}</Text>
                  <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(item.subtitle, language)}</Text>
                  <Text style={[styles.meta, { textAlign: isRTL ? 'right' : 'left' }]}>
                    {estimatedMinutes(item)} {t(S.minutesRead, language)}
                  </Text>
                </View>
                {item.isPremium ? (
                  <Ionicons name="lock-closed-outline" size={16} color={Theme.secondaryText} />
                ) : (
                  <Ionicons name={isRTL ? 'chevron-back-outline' : 'chevron-forward-outline'} size={16} color={Theme.secondaryText} />
                )}
              </Card>
            </Pressable>
          </Link>
        )}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  list: { padding: Theme.margin, gap: 10 },
  pageTitle: { fontSize: 22, fontWeight: '600', color: Theme.ink },
  pageSubtitle: { fontSize: 13, color: Theme.secondaryText, marginTop: 2 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 14, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  locked: { opacity: 0.6 },
  numberWrap: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Theme.goldSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  number: { fontSize: 14, fontWeight: '700', color: Theme.gold },
  title: { fontSize: 15, fontWeight: '600', color: Theme.ink },
  subtitle: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  meta: { fontSize: 11, color: Theme.secondaryText, marginTop: 4 },
});
