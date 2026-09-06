import { useRouter } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Banner } from '@/components/banner';
import { GoldButton } from '@/components/buttons';
import { Field } from '@/components/field';
import { useAuth } from '@/context/auth-context';
import { useLanguage } from '@/context/language-context';
import { S, t, type LText } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function ResetPasswordScreen() {
  const router = useRouter();
  const { language } = useLanguage();
  const { resetPassword } = useAuth();

  const [email, setEmail] = useState('');
  const [error, setError] = useState<LText | null>(null);
  const [info, setInfo] = useState<LText | null>(null);
  const [working, setWorking] = useState(false);

  const submit = async () => {
    setError(null);
    setInfo(null);
    setWorking(true);
    const failure = await resetPassword(email);
    setWorking(false);
    if (failure) {
      setError(failure);
      return;
    }
    setInfo(S.resetLinkSent);
  };

  return (
    <SafeAreaView style={styles.safe}>
      <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1 }}>
        <ScrollView contentContainerStyle={styles.content}>
          <Text style={styles.title}>{t(S.resetPassword, language)}</Text>
          <Text style={styles.hint}>{t(S.resetPasswordHint, language)}</Text>
          <Field label={t(S.email, language)} value={email} onChangeText={setEmail} keyboardType="email-address" placeholder="name@example.com" />
          {error ? <Banner text={t(error, language)} tone="error" /> : null}
          {info ? <Banner text={t(info, language)} tone="success" /> : null}
          <GoldButton title={t(S.resetPassword, language)} onPress={submit} loading={working} />
          <Text style={styles.link} onPress={() => router.replace('/(auth)/sign-in')}>
            {t(S.backToSignIn, language)}
          </Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 14, flexGrow: 1, justifyContent: 'center' },
  title: { fontSize: 22, fontWeight: '600', color: Theme.ink, textAlign: 'center', marginBottom: 4 },
  hint: { fontSize: 14, color: Theme.secondaryText, textAlign: 'center', marginBottom: 8 },
  link: { color: Theme.gold, fontSize: 14, fontWeight: '600', textAlign: 'center', marginTop: 4 },
});
