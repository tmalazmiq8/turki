import Ionicons from '@expo/vector-icons/Ionicons';
import { Link } from 'expo-router';
import { useMemo, useState } from 'react';
import { FlatList, Linking, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { useLanguage } from '@/context/language-context';
import { defaultIFRARecords } from '@/data/ifra-defaults';
import { materials } from '@/data/materials';
import { IFRAInfo } from '@/lib/ifra';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { ifraStatusLabel, materialName } from '@/types/material';

const ifraRecords = defaultIFRARecords();

const statusColor = {
  restricted: Theme.gold,
  prohibited: Theme.danger,
  specification: Theme.secondaryText,
  notListed: Theme.secondaryText,
  unverified: Theme.secondaryText,
} as const;

export default function IFRAScreen() {
  const { language, isRTL } = useLanguage();
  const [query, setQuery] = useState('');
  const [restrictedOnly, setRestrictedOnly] = useState(false);

  const filtered = useMemo(() => {
    return materials.filter((material) => {
      const record = ifraRecords[material.id];
      const statusMatch = !restrictedOnly || record?.status === 'restricted' || record?.status === 'prohibited';
      if (!statusMatch) return false;
      if (!query.trim()) return true;
      const q = query.trim().toLowerCase();
      return `${material.nameAr} ${material.nameEn}`.toLowerCase().includes(q);
    });
  }, [query, restrictedOnly]);

  return (
    <Screen title={t(S.ifra, language)}>
      <FlatList
        data={filtered}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListHeaderComponent={
          <View style={{ gap: 12, marginBottom: 12 }}>
            <Card style={{ gap: 8 }}>
              <View style={[styles.headerRow, isRTL && styles.rowReverse]}>
                <Ionicons name="shield-outline" size={16} color={Theme.gold} />
                <Text style={styles.cardTitle}>{t(S.ifraSection, language)}</Text>
              </View>
              <Text style={styles.disclaimer}>{t(S.ifraDisclaimer, language)}</Text>
              <Text style={styles.disclaimerSmall}>{t(S.ifraNoAutoCompliance, language)}</Text>
            </Card>

            <Pressable onPress={() => Linking.openURL(IFRAInfo.materialsSearch)}>
              <Card style={[styles.linkCard, isRTL && styles.rowReverse]}>
                <Ionicons name="globe-outline" size={16} color={Theme.gold} />
                <Text style={styles.linkText}>{t(S.ifraOfficialSearch, language)}</Text>
                <View style={{ flex: 1 }} />
                <Ionicons name="open-outline" size={14} color={Theme.secondaryText} />
              </Card>
            </Pressable>

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

            <Pressable onPress={() => setRestrictedOnly((v) => !v)}>
              <View style={[styles.chip, restrictedOnly && styles.chipSelected]}>
                <Text style={[styles.chipText, restrictedOnly && styles.chipTextSelected]}>
                  {t(S.ifraMaterialsWithLimits, language)}
                </Text>
              </View>
            </Pressable>
          </View>
        }
        ListEmptyComponent={<Text style={styles.empty}>{t(S.noResults, language)}</Text>}
        renderItem={({ item }) => {
          const record = ifraRecords[item.id];
          const color = record ? statusColor[record.status] : Theme.secondaryText;
          return (
            <Link href={{ pathname: '/material/[id]', params: { id: item.id } }} asChild>
              <Pressable>
                <Card style={[styles.row, isRTL && styles.rowReverse]}>
                  <View style={{ flex: 1 }}>
                    <Text style={[styles.name, { textAlign: isRTL ? 'right' : 'left' }]}>
                      {materialName(item, language)}
                    </Text>
                    <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>
                      {record?.maxConcentrationPercent != null
                        ? `${t(S.ifraMax, language)}: ${record.maxConcentrationPercent}%`
                        : t(S.ifraUnverified, language)}
                    </Text>
                  </View>
                  {record ? (
                    <View style={[styles.badge, { backgroundColor: `${color}1F` }]}>
                      <Text style={[styles.badgeText, { color }]}>{t(ifraStatusLabel[record.status], language)}</Text>
                    </View>
                  ) : null}
                </Card>
              </Pressable>
            </Link>
          );
        }}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24, gap: 10 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  rowReverse: { flexDirection: 'row-reverse' },
  cardTitle: { fontSize: 14, fontWeight: '600', color: Theme.ink },
  disclaimer: { fontSize: 13, color: Theme.secondaryText },
  disclaimerSmall: { fontSize: 12, color: Theme.secondaryText, opacity: 0.9 },
  linkCard: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14 },
  linkText: { fontSize: 15, fontWeight: '500', color: Theme.ink },
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
  chip: {
    alignSelf: 'flex-start',
    paddingHorizontal: 14,
    height: 34,
    borderRadius: 17,
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chipSelected: { backgroundColor: Theme.gold, borderColor: Theme.gold },
  chipText: { fontSize: 12, fontWeight: '600', color: Theme.ink },
  chipTextSelected: { color: Theme.surface },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: Theme.tileRadius },
  name: { fontSize: 15, fontWeight: '500', color: Theme.ink },
  subtitle: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  badge: { paddingHorizontal: 10, height: 24, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  badgeText: { fontSize: 11, fontWeight: '600' },
  empty: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
