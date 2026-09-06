import Ionicons from '@expo/vector-icons/Ionicons';
import { Image } from 'expo-image';
import { Link } from 'expo-router';
import { Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Card } from '@/components/card';
import { Screen } from '@/components/screen';
import { useLanguage } from '@/context/language-context';
import { IFRAInfo } from '@/lib/ifra';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

const logo = require('../../../assets/images/logo.png');

function greeting(): typeof S.goodMorning {
  const hour = new Date().getHours();
  if (hour < 12) return S.goodMorning;
  if (hour < 18) return S.goodAfternoon;
  return S.goodEvening;
}

export default function HomeScreen() {
  const { language, isRTL } = useLanguage();

  return (
    <Screen>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={[styles.header, isRTL && styles.rowReverse]}>
          <View style={[styles.headerLeft, isRTL && styles.rowReverse]}>
            <Image source={logo} style={styles.logo} contentFit="contain" />
            <View>
              <Text style={styles.greeting}>{t(greeting(), language)}</Text>
              <Text style={styles.appName}>{t(S.appName, language)}</Text>
            </View>
          </View>
          <Pressable onPress={() => Linking.openURL(IFRAInfo.materialsSearch)} style={styles.iconButton}>
            <Ionicons name="shield-checkmark-outline" size={20} color={Theme.ink} />
          </Pressable>
        </View>

        <Text style={styles.sectionHeader}>{t(S.quickActions, language)}</Text>
        <View style={[styles.quickRow, isRTL && styles.rowReverse]}>
          <Link href="/materials" asChild>
            <Pressable style={{ flex: 1 }}>
              <Card style={styles.quickCard}>
                <Ionicons name="flask-outline" size={22} color={Theme.gold} />
                <Text style={styles.quickText}>{t(S.materialsLibrary, language)}</Text>
              </Card>
            </Pressable>
          </Link>
          <Link href="/ifra" asChild>
            <Pressable style={{ flex: 1 }}>
              <Card style={styles.quickCard}>
                <Ionicons name="shield-checkmark-outline" size={22} color={Theme.gold} />
                <Text style={styles.quickText}>{t(S.ifra, language)}</Text>
              </Card>
            </Pressable>
          </Link>
        </View>

        <Pressable onPress={() => Linking.openURL(IFRAInfo.materialsSearch)}>
          <Card style={[styles.linkCard, isRTL && styles.rowReverse]}>
            <Ionicons name="globe-outline" size={18} color={Theme.gold} />
            <Text style={styles.linkText}>{t(S.ifraOfficialSearch, language)}</Text>
            <View style={{ flex: 1 }} />
            <Ionicons name={isRTL ? 'arrow-up-outline' : 'arrow-up-outline'} size={14} color={Theme.secondaryText} />
          </Card>
        </Pressable>
      </ScrollView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  content: { padding: Theme.margin, gap: 18 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  headerLeft: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  rowReverse: { flexDirection: 'row-reverse' },
  logo: { width: 36, height: 36 },
  greeting: { fontSize: 13, color: Theme.secondaryText },
  appName: { fontSize: 20, fontWeight: '600', color: Theme.ink },
  iconButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sectionHeader: {
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 1.4,
    color: Theme.secondaryText,
    textTransform: 'uppercase',
  },
  quickRow: { flexDirection: 'row', gap: 12 },
  quickCard: { alignItems: 'center', gap: 8, paddingVertical: 20 },
  quickText: { fontSize: 13, fontWeight: '600', color: Theme.ink, textAlign: 'center' },
  linkCard: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14 },
  linkText: { fontSize: 15, fontWeight: '500', color: Theme.ink },
});
