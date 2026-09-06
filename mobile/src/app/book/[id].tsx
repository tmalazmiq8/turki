import { useLocalSearchParams } from 'expo-router';
import { useMemo } from 'react';
import { ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLanguage } from '@/context/language-context';
import { bookChapterByID } from '@/data/book';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function BookChapterScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { language, isRTL } = useLanguage();
  const chapter = useMemo(() => bookChapterByID(Number(id)), [id]);

  if (!chapter) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.empty}>{t(S.noResults, language)}</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.chapterNumber, { textAlign: isRTL ? 'right' : 'left' }]}>
          {chapter.id.toString().padStart(2, '0')}
        </Text>
        <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{t(chapter.title, language)}</Text>
        <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(chapter.subtitle, language)}</Text>
        {chapter.paragraphs.map((paragraph, index) => (
          <Text key={index} style={[styles.paragraph, { textAlign: isRTL ? 'right' : 'left' }]}>
            {t(paragraph, language)}
          </Text>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.sepia },
  content: { padding: Theme.margin, paddingBottom: 40 },
  empty: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
  chapterNumber: { fontSize: 13, fontWeight: '700', color: Theme.gold, letterSpacing: 1 },
  title: { fontSize: 24, fontWeight: '700', color: Theme.ink, marginTop: 6, marginBottom: 4 },
  subtitle: { fontSize: 14, color: Theme.secondaryText, marginBottom: 20 },
  paragraph: { fontSize: 17, lineHeight: 28, color: Theme.ink, marginBottom: 18 },
});
