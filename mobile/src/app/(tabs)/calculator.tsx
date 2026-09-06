import Ionicons from '@expo/vector-icons/Ionicons';
import { useRouter } from 'expo-router';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { Card } from '@/components/card';
import { GoldButton } from '@/components/buttons';
import { Screen } from '@/components/screen';
import { useAppData } from '@/context/data-context';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { concentrationLabel, newFormula, totalPercent } from '@/types/formula';

export default function CalculatorScreen() {
  const { language, isRTL } = useLanguage();
  const { formulas, addFormula } = useAppData();
  const router = useRouter();

  const createFormula = () => {
    const formula = newFormula(t(S.newFormula, language));
    addFormula(formula);
    router.push({ pathname: '/formula/[id]', params: { id: formula.id } });
  };

  return (
    <Screen title={t(S.calculator, language)}>
      <View style={{ paddingHorizontal: Theme.margin, marginBottom: 12 }}>
        <GoldButton title={t(S.newFormula, language)} onPress={createFormula} />
      </View>
      <FlatList
        data={formulas}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="options-outline" size={28} color={Theme.secondaryText} />
            <Text style={styles.emptyText}>{t(S.noFormulas, language)}</Text>
          </View>
        }
        renderItem={({ item }) => (
          <Pressable onPress={() => router.push({ pathname: '/formula/[id]', params: { id: item.id } })}>
            <Card style={[styles.row, isRTL && styles.rowReverse]}>
              <View style={{ flex: 1 }}>
                <Text style={[styles.name, { textAlign: isRTL ? 'right' : 'left' }]}>{item.name}</Text>
                <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>
                  {t(concentrationLabel[item.concentration], language)} · {Math.round(item.bottleSizeML)}{' '}
                  {t(S.milliliters, language)} · {totalPercent(item).toFixed(0)}%
                </Text>
              </View>
              <Ionicons name={isRTL ? 'chevron-back-outline' : 'chevron-forward-outline'} size={16} color={Theme.secondaryText} />
            </Card>
          </Pressable>
        )}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24, gap: 10 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 14, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  name: { fontSize: 15, fontWeight: '600', color: Theme.ink },
  subtitle: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  empty: { alignItems: 'center', gap: 8, marginTop: 60 },
  emptyText: { color: Theme.secondaryText },
});
