import Ionicons from '@expo/vector-icons/Ionicons';
import { Link } from 'expo-router';
import { useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { glossaryTerms } from '@/data/glossary';
import { materials } from '@/data/materials';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { materialName } from '@/types/material';

type Result =
  | { kind: 'material'; id: string; title: string; subtitle: string }
  | { kind: 'glossary'; id: string; title: string; subtitle: string };

export default function SearchScreen() {
  const { language, isRTL } = useLanguage();
  const [query, setQuery] = useState('');

  const results = useMemo<Result[]>(() => {
    const q = query.trim().toLowerCase();
    if (!q) return [];
    const materialResults: Result[] = materials
      .filter((m) => `${m.nameAr} ${m.nameEn}`.toLowerCase().includes(q))
      .map((m) => ({ kind: 'material', id: m.id, title: materialName(m, language), subtitle: t(S.materialsLibrary, language) }));
    const glossaryResults: Result[] = glossaryTerms
      .filter((g) => `${g.termAr} ${g.termEn}`.toLowerCase().includes(q))
      .map((g) => ({
        kind: 'glossary',
        id: g.id,
        title: language === 'ar' ? g.termAr : g.termEn,
        subtitle: t(S.glossary, language),
      }));
    return [...materialResults, ...glossaryResults];
  }, [query, language]);

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <View style={{ padding: Theme.margin }}>
        <View style={styles.searchWrap}>
          <Ionicons name="search-outline" size={16} color={Theme.secondaryText} />
          <TextInput
            autoFocus
            value={query}
            onChangeText={setQuery}
            placeholder={t(S.searchEverything, language)}
            placeholderTextColor={Theme.secondaryText}
            style={[styles.searchInput, { textAlign: isRTL ? 'right' : 'left' }]}
          />
        </View>
      </View>
      <FlatList
        data={results}
        keyExtractor={(item) => `${item.kind}-${item.id}`}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          query.trim() ? <Text style={styles.emptyText}>{t(S.noResults, language)}</Text> : null
        }
        renderItem={({ item }) => (
          <Link
            href={item.kind === 'material' ? { pathname: '/material/[id]', params: { id: item.id } } : { pathname: '/glossary/[id]', params: { id: item.id } }}
            asChild
          >
            <Pressable>
              <Card style={[styles.row, isRTL && styles.rowReverse]}>
                <Ionicons name={item.kind === 'material' ? 'flask-outline' : 'library-outline'} size={16} color={Theme.gold} />
                <View style={{ flex: 1 }}>
                  <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{item.title}</Text>
                  <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>{item.subtitle}</Text>
                </View>
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
  row: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  title: { fontSize: 14, fontWeight: '500', color: Theme.ink },
  subtitle: { fontSize: 11, color: Theme.secondaryText, marginTop: 2 },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
