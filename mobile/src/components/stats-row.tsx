import { StyleSheet, Text, View } from 'react-native';
import { Card } from './card';
import { Theme } from '@/lib/theme';
import { useLanguage } from '@/context/language-context';

export function StatsRow({ stats }: { stats: { value: string | number; label: string }[] }) {
  const { isRTL } = useLanguage();
  return (
    <Card style={[styles.row, isRTL && styles.rowReverse]}>
      {stats.map((stat, index) => (
        <View key={index} style={styles.stat}>
          <Text style={styles.value}>{stat.value}</Text>
          <Text style={styles.label}>{stat.label}</Text>
        </View>
      ))}
    </Card>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', justifyContent: 'space-around', paddingVertical: 14 },
  rowReverse: { flexDirection: 'row-reverse' },
  stat: { alignItems: 'center', gap: 2 },
  value: { fontSize: 18, fontWeight: '700', color: Theme.gold },
  label: { fontSize: 11, color: Theme.secondaryText },
});
