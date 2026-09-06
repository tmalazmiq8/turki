import { useState } from 'react';
import { Alert, ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Banner } from '@/components/banner';
import { GoldButton, InkButton } from '@/components/buttons';
import { Field } from '@/components/field';
import { useAuth } from '@/context/auth-context';
import { useLanguage } from '@/context/language-context';
import { supabase } from '@/lib/supabase';
import { S, t, type LText } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function SecurityScreen() {
  const { language, isRTL } = useLanguage();
  const { session, signOut } = useAuth();
  const [current, setCurrent] = useState('');
  const [next, setNext] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [error, setError] = useState<LText | null>(null);
  const [success, setSuccess] = useState<LText | null>(null);
  const [working, setWorking] = useState(false);

  const changePassword = async () => {
    setError(null);
    setSuccess(null);
    if (next.length < 8) {
      setError(S.errShortPassword);
      return;
    }
    if (next !== confirmation) {
      setError(S.errPasswordMismatch);
      return;
    }
    const email = session?.user.email;
    if (!email) return;
    setWorking(true);
    // Re-authenticate with the current password first, same as the Swift
    // app: a stolen unlocked session alone can't be used to lock the real
    // owner out.
    const { error: signInError } = await supabase.auth.signInWithPassword({ email, password: current });
    if (signInError) {
      setWorking(false);
      setError(S.errWrongCredentials);
      return;
    }
    const { error: updateError } = await supabase.auth.updateUser({ password: next });
    setWorking(false);
    if (updateError) {
      setError({ ar: updateError.message, en: updateError.message });
      return;
    }
    setSuccess({ ar: 'تم تغيير كلمة المرور.', en: 'Password changed.' });
    setCurrent('');
    setNext('');
    setConfirmation('');
  };

  const confirmDelete = () => {
    Alert.alert(t(S.deleteAccount, language), t(S.deleteWarning, language), [
      { text: t(S.cancel, language), style: 'cancel' },
      { text: t(S.deleteAccount, language), style: 'destructive', onPress: signOut },
    ]);
  };

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.sectionTitle, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.changePassword, language)}</Text>
        <Field label={t(S.currentPassword, language)} value={current} onChangeText={setCurrent} secureTextEntry />
        <Field label={t(S.newPassword, language)} value={next} onChangeText={setNext} secureTextEntry />
        <Field label={t(S.confirmPassword, language)} value={confirmation} onChangeText={setConfirmation} secureTextEntry />
        {error ? <Banner text={t(error, language)} tone="error" /> : null}
        {success ? <Banner text={t(success, language)} tone="success" /> : null}
        <GoldButton title={t(S.save, language)} onPress={changePassword} loading={working} />

        <Text style={[styles.sectionTitle, { textAlign: isRTL ? 'right' : 'left', marginTop: 24 }]}>
          {t(S.deleteAccount, language)}
        </Text>
        <Text style={[styles.hint, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.deleteAccountHint, language)}</Text>
        <InkButton title={t(S.deleteAccount, language)} onPress={confirmDelete} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 14 },
  sectionTitle: { fontSize: 16, fontWeight: '600', color: Theme.ink },
  hint: { fontSize: 13, color: Theme.secondaryText },
});
