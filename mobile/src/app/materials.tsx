import Ionicons from '@expo/vector-icons/Ionicons';
import { Link } from 'expo-router';
import { useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { useLanguage } from '@/context/language-context';
import { materials } from '@/data/materials';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { familyIcon, familyLabel, materialName, stageLabel } from '@/types/material';

export default function MaterialsScreen() {
  const { language, isRTL } = useLanguage();
  const [query, setQuery] = useState('');

  const filtered = useMemo(() => {
    if (!query.trim()) return materials;
    const q = query.trim().toLowerCase();
    return materials.filter((m) => {
      const haystack = [m.nameAr, m.nameEn, familyLabel[m.family].ar, familyLabel[m.family].en].join(' ').toLowerCase();
      return haystack.includes(q);
    });
  }, [query]);

  return (
    <Screen title={t(S.materialsLibrary, language)}>
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

      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <Text style={styles.empty}>{t(S.noResults, language)}</Text>
        }
        renderItem={({ item }) => (
          <Link href={{ pathname: '/material/[id]', params: { id: item.id } }} asChild>
            <Pressable>
              <Card style={[styles.row, isRTL && styles.rowReverse]}>
                <View style={styles.familyIcon}>
                  <Ionicons name={familyIcon[item.family] as any} size={18} color={Theme.gold} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={[styles.name, { textAlign: isRTL ? 'right' : 'left' }]}>
                    {materialName(item, language)}
                  </Text>
                  <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>
                    {t(familyLabel[item.family], language)} · {t(stageLabel[item.stage], language)}
                  </Text>
                </View>
                <Ionicons name={isRTL ? 'chevron-back-outline' : 'chevron-forward-outline'} size={16} color={Theme.secondaryText} />
              </Card>
            </Pressable>
          </Link>
        )}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  searchWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginHorizontal: Theme.margin,
    marginBottom: 12,
    height: 44,
    paddingHorizontal: 14,
    borderRadius: 12,
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
  },
  searchInput: { flex: 1, fontSize: 15, color: Theme.ink },
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24, gap: 10 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  familyIcon: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: Theme.goldSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  name: { fontSize: 15, fontWeight: '500', color: Theme.ink },
  subtitle: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  empty: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
