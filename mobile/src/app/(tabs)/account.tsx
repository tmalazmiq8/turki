import Ionicons from '@expo/vector-icons/Ionicons';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Card } from '@/components/card';
import { InkButton } from '@/components/buttons';
import { Screen } from '@/components/screen';
import { useAuth } from '@/context/auth-context';
import { useLanguage } from '@/context/language-context';
import { IFRAInfo } from '@/lib/ifra';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function AccountScreen() {
  const { language, isRTL, toggleLanguage } = useLanguage();
  const { session, signOut } = useAuth();

  return (
    <Screen title={t(S.account, language)}>
      <ScrollView contentContainerStyle={styles.content}>
        <Card style={{ gap: 4 }}>
          <Text style={[styles.label, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.email, language)}</Text>
          <Text style={[styles.value, { textAlign: isRTL ? 'right' : 'left' }]}>{session?.user.email ?? '—'}</Text>
        </Card>

        <Pressable onPress={toggleLanguage}>
          <Card style={[styles.row, isRTL && styles.rowReverse]}>
            <Ionicons name="language-outline" size={18} color={Theme.gold} />
            <Text style={styles.rowText}>{t(S.language, language)}</Text>
            <View style={{ flex: 1 }} />
            <Text style={styles.rowValue}>{language === 'ar' ? 'العربية' : 'English'}</Text>
          </Card>
        </Pressable>

        <Text style={styles.sectionHeader}>{t(S.officialWebsites, language)}</Text>
        <Pressable onPress={() => Linking.openURL(IFRAInfo.materialsSearch)}>
          <Card style={[styles.row, isRTL && styles.rowReverse]}>
            <Ionicons name="globe-outline" size={18} color={Theme.gold} />
            <Text style={styles.rowText}>{t(S.ifraOfficialSearch, language)}</Text>
            <View style={{ flex: 1 }} />
            <Ionicons name="open-outline" size={14} color={Theme.secondaryText} />
          </Card>
        </Pressable>

        <InkButton title={t(S.signOut, language)} onPress={signOut} />
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  content: { padding: Theme.margin, gap: 14 },
  label: { fontSize: 12, color: Theme.secondaryText },
  value: { fontSize: 15, color: Theme.ink, fontWeight: '500' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14 },
  rowReverse: { flexDirection: 'row-reverse' },
  rowText: { fontSize: 15, fontWeight: '500', color: Theme.ink },
  rowValue: { fontSize: 13, color: Theme.secondaryText },
  sectionHeader: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1.2,
    color: Theme.secondaryText,
    textTransform: 'uppercase',
    marginTop: 6,
  },
});
