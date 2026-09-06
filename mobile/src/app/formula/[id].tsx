import Ionicons from '@expo/vector-icons/Ionicons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Alert, FlatList, Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { GoldButton, InkButton } from '@/components/buttons';
import { useAppData } from '@/context/data-context';
import { useLanguage } from '@/context/language-context';
import { materials } from '@/data/materials';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import {
  type Concentration,
  concentrationDefaultPercent,
  concentrationLabel,
  formatCurrencyFromUSD,
  ingredientCostUSD,
  ingredientFromMaterial,
  totalCostUSD,
  totalPercent,
} from '@/types/formula';
import { materialName, stageLabel } from '@/types/material';

const concentrations: Concentration[] = ['parfum', 'edp', 'edt', 'edc', 'custom'];

export default function FormulaEditorScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { language, isRTL } = useLanguage();
  const { formulas, updateFormula, deleteFormula } = useAppData();
  const router = useRouter();
  const [pickerOpen, setPickerOpen] = useState(false);

  const formula = useMemo(() => formulas.find((f) => f.id === id), [formulas, id]);

  if (!formula) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.emptyText}>{t(S.noResults, language)}</Text>
      </SafeAreaView>
    );
  }

  const total = totalPercent(formula);
  const cost = totalCostUSD(formula);

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <TextInput
          value={formula.name}
          onChangeText={(name) => updateFormula({ ...formula, name })}
          style={[styles.nameInput, { textAlign: isRTL ? 'right' : 'left' }]}
          placeholder={t(S.formulaName, language)}
          placeholderTextColor={Theme.secondaryText}
        />

        <Card style={{ gap: 12 }}>
          <View style={[styles.fieldRow, isRTL && styles.rowReverse]}>
            <Text style={styles.fieldLabel}>{t(S.bottleSize, language)}</Text>
            <TextInput
              value={String(formula.bottleSizeML)}
              onChangeText={(v) => updateFormula({ ...formula, bottleSizeML: Number(v) || 0 })}
              keyboardType="numeric"
              style={styles.fieldInput}
            />
            <Text style={styles.fieldUnit}>{t(S.milliliters, language)}</Text>
          </View>

          <Text style={styles.fieldLabel}>{t(S.concentration, language)}</Text>
          <View style={[styles.chipRow, isRTL && styles.rowReverse]}>
            {concentrations.map((c) => (
              <Pressable
                key={c}
                onPress={() =>
                  updateFormula({ ...formula, concentration: c, oilPercent: concentrationDefaultPercent[c] })
                }
              >
                <View style={[styles.chip, formula.concentration === c && styles.chipSelected]}>
                  <Text style={[styles.chipText, formula.concentration === c && styles.chipTextSelected]}>
                    {t(concentrationLabel[c], language)}
                  </Text>
                </View>
              </Pressable>
            ))}
          </View>
        </Card>

        <View style={[styles.sectionHeaderRow, isRTL && styles.rowReverse]}>
          <Text style={styles.sectionHeader}>{t(S.materialsLibrary, language)}</Text>
          <Pressable onPress={() => setPickerOpen((v) => !v)}>
            <View style={[styles.addButton, isRTL && styles.rowReverse]}>
              <Ionicons name="add" size={16} color={Theme.ink} />
              <Text style={styles.addButtonText}>{t(S.addMaterial, language)}</Text>
            </View>
          </Pressable>
        </View>

        {pickerOpen ? (
          <Card style={{ maxHeight: 260, padding: 0 }}>
            <FlatList
              data={materials}
              keyExtractor={(m) => m.id}
              renderItem={({ item }) => (
                <Pressable
                  onPress={() => {
                    updateFormula({ ...formula, ingredients: [...formula.ingredients, ingredientFromMaterial(item, 5)] });
                    setPickerOpen(false);
                  }}
                >
                  <View style={[styles.pickerRow, isRTL && styles.rowReverse]}>
                    <Text style={styles.pickerText}>{materialName(item, language)}</Text>
                  </View>
                </Pressable>
              )}
            />
          </Card>
        ) : null}

        {formula.ingredients.length === 0 ? (
          <Text style={styles.emptyText}>{t(S.noResults, language)}</Text>
        ) : (
          formula.ingredients.map((ingredient) => (
            <Card key={ingredient.id} style={[styles.ingredientRow, isRTL && styles.rowReverse]}>
              <View style={{ flex: 1 }}>
                <Text style={[styles.name, { textAlign: isRTL ? 'right' : 'left' }]}>
                  {language === 'ar' ? ingredient.nameAr : ingredient.nameEn}
                </Text>
                <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]}>
                  {t(stageLabel[ingredient.stage], language)} ·{' '}
                  {formatCurrencyFromUSD(ingredientCostUSD(formula, ingredient), formula.currency, language)}
                </Text>
              </View>
              <TextInput
                value={String(ingredient.percent)}
                onChangeText={(v) =>
                  updateFormula({
                    ...formula,
                    ingredients: formula.ingredients.map((i) =>
                      i.id === ingredient.id ? { ...i, percent: Number(v) || 0 } : i,
                    ),
                  })
                }
                keyboardType="numeric"
                style={styles.percentInput}
              />
              <Text style={styles.fieldUnit}>%</Text>
              <Pressable
                onPress={() =>
                  updateFormula({ ...formula, ingredients: formula.ingredients.filter((i) => i.id !== ingredient.id) })
                }
              >
                <Ionicons name="close-circle-outline" size={20} color={Theme.danger} />
              </Pressable>
            </Card>
          ))
        )}

        <Card style={{ gap: 10 }}>
          <View style={[styles.fieldRow, isRTL && styles.rowReverse]}>
            <Text style={styles.fieldLabel}>{t(S.totalPercentage, language)}</Text>
            <Text style={[styles.totalValue, { color: Math.abs(total - 100) < 1 ? Theme.gold : Theme.danger }]}>
              {total.toFixed(0)}%
            </Text>
          </View>
          <View style={styles.divider} />
          <View style={[styles.fieldRow, isRTL && styles.rowReverse]}>
            <Text style={styles.fieldLabel}>{t(S.totalCost, language)}</Text>
            <Text style={styles.totalValue}>{formatCurrencyFromUSD(cost, formula.currency, language)}</Text>
          </View>
        </Card>

        <InkButton
          title={t(S.delete, language)}
          onPress={() => {
            Alert.alert(t(S.delete, language), formula.name, [
              { text: t(S.cancel, language), style: 'cancel' },
              {
                text: t(S.delete, language),
                style: 'destructive',
                onPress: () => {
                  deleteFormula(formula.id);
                  router.back();
                },
              },
            ]);
          }}
        />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 16, paddingBottom: 32 },
  nameInput: { fontSize: 22, fontWeight: '600', color: Theme.ink, padding: 4 },
  fieldRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  rowReverse: { flexDirection: 'row-reverse' },
  fieldLabel: { fontSize: 13, color: Theme.secondaryText, flex: 1 },
  fieldInput: {
    minWidth: 60,
    textAlign: 'center',
    borderWidth: 1,
    borderColor: Theme.hairline,
    borderRadius: 8,
    paddingVertical: 6,
    color: Theme.ink,
  },
  fieldUnit: { fontSize: 12, color: Theme.secondaryText },
  chipRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  chip: {
    paddingHorizontal: 12,
    height: 32,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: Theme.hairline,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chipSelected: { backgroundColor: Theme.gold, borderColor: Theme.gold },
  chipText: { fontSize: 12, fontWeight: '600', color: Theme.ink },
  chipTextSelected: { color: Theme.surface },
  sectionHeaderRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  sectionHeader: { fontSize: 12, fontWeight: '600', letterSpacing: 1.2, color: Theme.secondaryText, textTransform: 'uppercase' },
  addButton: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  addButtonText: { fontSize: 13, fontWeight: '600', color: Theme.gold },
  pickerRow: { padding: 12, borderBottomWidth: 1, borderBottomColor: Theme.hairline },
  pickerText: { fontSize: 14, color: Theme.ink },
  ingredientRow: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12, borderRadius: Theme.tileRadius },
  name: { fontSize: 14, fontWeight: '500', color: Theme.ink },
  subtitle: { fontSize: 11, color: Theme.secondaryText, marginTop: 2 },
  percentInput: {
    width: 44,
    textAlign: 'center',
    borderWidth: 1,
    borderColor: Theme.hairline,
    borderRadius: 8,
    paddingVertical: 4,
    color: Theme.ink,
  },
  divider: { height: 1, backgroundColor: Theme.hairline },
  totalValue: { fontSize: 15, fontWeight: '700', color: Theme.ink },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 20 },
});
