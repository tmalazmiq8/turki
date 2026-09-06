import { Link, useLocalSearchParams } from 'expo-router';
import { useMemo } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { glossaryCategoryLabel, glossaryTermByID, glossaryTerms } from '@/data/glossary';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function GlossaryDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { language, isRTL } = useLanguage();
  const term = useMemo(() => glossaryTermByID(id ?? ''), [id]);

  if (!term) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.emptyText}>{t(S.noResults, language)}</Text>
      </SafeAreaView>
    );
  }

  const related = term.related.map((rid) => glossaryTerms.find((t2) => t2.id === rid)).filter(Boolean);

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.category, { textAlign: isRTL ? 'right' : 'left' }]}>
          {t(glossaryCategoryLabel[term.category], language)}
        </Text>
        <Text style={[styles.term, { textAlign: isRTL ? 'right' : 'left' }]}>
          {language === 'ar' ? term.termAr : term.termEn}
        </Text>
        <Card style={{ gap: 10 }}>
          <Text style={[styles.definition, { textAlign: isRTL ? 'right' : 'left' }]}>{t(term.definition, language)}</Text>
          <View style={styles.divider} />
          <Text style={[styles.exampleLabel, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.example, language)}</Text>
          <Text style={[styles.example, { textAlign: isRTL ? 'right' : 'left' }]}>{t(term.example, language)}</Text>
        </Card>

        {related.length > 0 ? (
          <View style={{ gap: 8 }}>
            <Text style={styles.sectionHeader}>{t(S.relatedTerms, language)}</Text>
            <View style={[styles.chipRow, isRTL && styles.rowReverse]}>
              {related.map((r) =>
                r ? (
                  <Link key={r.id} href={{ pathname: '/glossary/[id]', params: { id: r.id } }} asChild>
                    <Text style={styles.chip}>{language === 'ar' ? r.termAr : r.termEn}</Text>
                  </Link>
                ) : null,
              )}
            </View>
          </View>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 16 },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
  category: { fontSize: 12, fontWeight: '600', color: Theme.gold, textTransform: 'uppercase' },
  term: { fontSize: 24, fontWeight: '700', color: Theme.ink },
  definition: { fontSize: 15, color: Theme.ink, lineHeight: 22 },
  divider: { height: 1, backgroundColor: Theme.hairline },
  exampleLabel: { fontSize: 11, fontWeight: '600', color: Theme.secondaryText, textTransform: 'uppercase' },
  example: { fontSize: 14, color: Theme.secondaryText, fontStyle: 'italic' },
  sectionHeader: { fontSize: 12, fontWeight: '600', letterSpacing: 1.2, color: Theme.secondaryText, textTransform: 'uppercase' },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  rowReverse: { flexDirection: 'row-reverse' },
  chip: {
    fontSize: 13,
    fontWeight: '600',
    color: Theme.ink,
    backgroundColor: Theme.goldSoft,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 16,
    overflow: 'hidden',
  },
});
