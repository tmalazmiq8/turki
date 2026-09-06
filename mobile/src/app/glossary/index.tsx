import Ionicons from '@expo/vector-icons/Ionicons';
import { Link } from 'expo-router';
import { useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { glossaryCategoryLabel, glossaryTerms } from '@/data/glossary';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function GlossaryListScreen() {
  const { language, isRTL } = useLanguage();
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    if (!query.trim()) return glossaryTerms;
    const q = query.trim().toLowerCase();
    return glossaryTerms.filter((term) =>
      `${term.termAr} ${term.termEn} ${term.definition.ar} ${term.definition.en}`.toLowerCase().includes(q),
    );
  }, [query]);

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <View style={{ padding: Theme.margin, paddingBottom: 8 }}>
        <Text style={[styles.pageTitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.glossary, language)}</Text>
        <View style={styles.searchWrap}>
          <Ionicons name="search-outline" size={16} color={Theme.secondaryText} />
          <TextInput
            value={query}
            onChangeText={setQuery}
            placeholder={t(S.search, language)}
            placeholderTextColor={Theme.secondaryText}
            style={[styles.searchInput, { textAlign: isRTL ? 'right' : 'left' }]}
          />
        </View>
      </View>
      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={<Text style={styles.emptyText}>{t(S.noResults, language)}</Text>}
        renderItem={({ item }) => (
          <Link href={{ pathname: '/glossary/[id]', params: { id: item.id } }} asChild>
            <Pressable>
              <Card style={[styles.row, isRTL && styles.rowReverse]}>
                <View style={{ flex: 1 }}>
                  <Text style={[styles.term, { textAlign: isRTL ? 'right' : 'left' }]}>
                    {language === 'ar' ? item.termAr : item.termEn}
                  </Text>
                  <Text style={[styles.category, { textAlign: isRTL ? 'right' : 'left' }]}>
                    {t(glossaryCategoryLabel[item.category], language)}
                  </Text>
                </View>
                <Ionicons name={isRTL ? 'chevron-back-outline' : 'chevron-forward-outline'} size={16} color={Theme.secondaryText} />
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
  pageTitle: { fontSize: 22, fontWeight: '600', color: Theme.ink, marginBottom: 10 },
  searchWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    height: 44,
    paddingHorizontal: 14,
    borderRadius: 12,
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
  },
  searchInput: { flex: 1, fontSize: 15, color: Theme.ink },
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24, gap: 8 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  term: { fontSize: 15, fontWeight: '600', color: Theme.ink },
  category: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
