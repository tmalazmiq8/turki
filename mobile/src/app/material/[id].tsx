import Ionicons from '@expo/vector-icons/Ionicons';
import { useLocalSearchParams } from 'expo-router';
import { useMemo } from 'react';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useLanguage } from '@/context/language-context';
import { defaultIFRARecords } from '@/data/ifra-defaults';
import { materialByID } from '@/data/materials';
import { IFRAInfo } from '@/lib/ifra';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { familyLabel, ifraStatusLabel, materialName, stageLabel } from '@/types/material';

const ifraRecords = defaultIFRARecords();

export default function MaterialDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { language, isRTL } = useLanguage();
  const material = useMemo(() => materialByID(id ?? ''), [id]);
  const record = ifraRecords[id ?? ''];

  if (!material) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.notFound}>{t(S.noResults, language)}</Text>
      </SafeAreaView>
    );
  }

  const row = (label: string, value: string) => (
    <View style={[styles.row, isRTL && styles.rowReverse]}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Text style={[styles.rowValue, { textAlign: isRTL ? 'left' : 'right' }]}>{value}</Text>
    </View>
  );

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{materialName(material, language)}</Text>
        <Text style={[styles.family, { textAlign: isRTL ? 'right' : 'left' }]}>
          {t(familyLabel[material.family], language)} · {t(stageLabel[material.stage], language)}
        </Text>

        <Card style={styles.section}>
          {row(t(S.origin, language), t(material.origin, language))}
          <View style={styles.divider} />
          {row(t(S.character, language), t(material.character, language))}
          <View style={styles.divider} />
          {row(t(S.evaporation, language), t(material.evaporation, language))}
          <View style={styles.divider} />
          {row(t(S.typicalUse, language), t(material.typicalUse, language))}
          <View style={styles.divider} />
          {row(t(S.pricePerMl, language), `$${material.pricePerMLUSD.toFixed(2)}`)}
        </Card>

        <Text style={styles.sectionHeader}>{t(S.ifraSection, language)}</Text>
        <Card style={{ gap: 10 }}>
          <Text style={styles.disclaimer}>{t(S.ifraDisclaimer, language)}</Text>
          {record ? (
            <>
              <View style={styles.divider} />
              {row(t(S.ifraStatus, language), t(ifraStatusLabel[record.status], language))}
              <View style={styles.divider} />
              {row(
                t(S.ifraMax, language),
                record.maxConcentrationPercent != null ? `${record.maxConcentrationPercent}%` : t(S.ifraUnverified, language),
              )}
              {record.note ? (
                <>
                  <View style={styles.divider} />
                  <Text style={styles.note}>{t(record.note, language)}</Text>
                </>
              ) : null}
            </>
          ) : null}
        </Card>

        <Pressable onPress={() => Linking.openURL(IFRAInfo.materialsSearch)}>
          <Card style={[styles.linkCard, isRTL && styles.rowReverse]}>
            <Ionicons name="globe-outline" size={18} color={Theme.gold} />
            <Text style={styles.linkText}>{t(S.ifraOfficialSearch, language)}</Text>
          </Card>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 16, paddingBottom: 32 },
  notFound: { textAlign: 'center', marginTop: 40, color: Theme.secondaryText },
  title: { fontSize: 22, fontWeight: '600', color: Theme.ink },
  family: { fontSize: 13, color: Theme.secondaryText },
  section: { gap: 0 },
  sectionHeader: { fontSize: 12, fontWeight: '600', letterSpacing: 1.2, color: Theme.secondaryText, textTransform: 'uppercase' },
  row: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 10, gap: 12 },
  rowReverse: { flexDirection: 'row-reverse' },
  rowLabel: { fontSize: 13, color: Theme.secondaryText },
  rowValue: { fontSize: 14, color: Theme.ink, flex: 1 },
  divider: { height: 1, backgroundColor: Theme.hairline },
  disclaimer: { fontSize: 13, color: Theme.secondaryText },
  note: { fontSize: 12, color: Theme.secondaryText },
  linkCard: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14 },
  linkText: { fontSize: 15, fontWeight: '500', color: Theme.ink },
});
