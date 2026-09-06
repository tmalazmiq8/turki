import { useLocalSearchParams } from 'expo-router';
import { useMemo } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Card } from '@/components/card';
import { useAppData } from '@/context/data-context';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { listingCategoryLabel } from '@/types/listing';

export default function ListingDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { language, isRTL } = useLanguage();
  const { listings } = useAppData();
  const listing = useMemo(() => listings.find((l) => l.id === id), [listings, id]);

  if (!listing) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={styles.emptyText}>{t(S.noResults, language)}</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{listing.title}</Text>
        <Text style={styles.price}>${listing.priceUSD.toFixed(0)}</Text>
        <Card style={{ gap: 10 }}>
          <View style={[styles.row, isRTL && styles.rowReverse]}>
            <Text style={styles.label}>{t(S.category, language)}</Text>
            <Text style={styles.value}>{t(listingCategoryLabel[listing.category], language)}</Text>
          </View>
          <View style={styles.divider} />
          <Text style={[styles.description, { textAlign: isRTL ? 'right' : 'left' }]}>{listing.description}</Text>
        </Card>
        <Text style={styles.seller}>{listing.sellerEmail}</Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 14 },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
  title: { fontSize: 22, fontWeight: '600', color: Theme.ink },
  price: { fontSize: 20, fontWeight: '700', color: Theme.gold },
  row: { flexDirection: 'row', justifyContent: 'space-between' },
  rowReverse: { flexDirection: 'row-reverse' },
  label: { fontSize: 13, color: Theme.secondaryText },
  value: { fontSize: 14, color: Theme.ink, fontWeight: '500' },
  divider: { height: 1, backgroundColor: Theme.hairline },
  description: { fontSize: 14, color: Theme.ink, lineHeight: 20 },
  seller: { fontSize: 12, color: Theme.secondaryText },
});
