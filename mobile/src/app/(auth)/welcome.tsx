import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { GoldButton, InkButton } from '@/components/buttons';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';

const logo = require('../../../assets/images/logo.png');

export default function WelcomeScreen() {
  const router = useRouter();
  const { language, toggleLanguage } = useLanguage();

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.langRow}>
        <Text onPress={toggleLanguage} style={styles.langToggle}>
          {language === 'ar' ? 'English' : 'العربية'}
        </Text>
      </View>

      <View style={styles.content}>
        <Image source={logo} style={styles.logo} contentFit="contain" />
        <Text style={styles.name}>MIYAR</Text>
        <Text style={styles.tagline}>{t(S.appTagline, language)}</Text>

        <View style={styles.card}>
          <Text style={styles.title}>{t(S.welcomeTitle, language)}</Text>
          <Text style={styles.subtitle}>{t(S.welcomeSubtitle, language)}</Text>

          <View style={styles.buttons}>
            <GoldButton title={t(S.createAccount, language)} onPress={() => router.push('/(auth)/sign-up')} />
            <InkButton title={t(S.signIn, language)} onPress={() => router.push('/(auth)/sign-in')} />
          </View>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  langRow: { alignItems: 'flex-end', paddingHorizontal: Theme.margin, paddingTop: 8 },
  langToggle: { color: Theme.gold, fontSize: 13, fontWeight: '600' },
  content: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: Theme.margin, gap: 8 },
  logo: { width: 84, height: 84, marginBottom: 8 },
  name: { fontSize: 28, fontWeight: '600', letterSpacing: 6, color: Theme.ink },
  tagline: { fontSize: 14, color: Theme.secondaryText, marginBottom: 24, textAlign: 'center' },
  card: {
    width: '100%',
    backgroundColor: Theme.surface,
    borderRadius: Theme.cardRadius,
    borderWidth: 1,
    borderColor: Theme.hairline,
    padding: 20,
    gap: 14,
  },
  title: { fontSize: 19, fontWeight: '600', color: Theme.ink, textAlign: 'center' },
  subtitle: { fontSize: 14, color: Theme.secondaryText, textAlign: 'center' },
  buttons: { gap: 10, marginTop: 6 },
});
