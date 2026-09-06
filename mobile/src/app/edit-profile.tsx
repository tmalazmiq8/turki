import { useEffect, useState } from 'react';
import { ScrollView, StyleSheet, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Banner } from '@/components/banner';
import { GoldButton } from '@/components/buttons';
import { Field } from '@/components/field';
import { useAuth } from '@/context/auth-context';
import { useLanguage } from '@/context/language-context';
import { supabase } from '@/lib/supabase';
import { S, t, type LText } from '@/lib/strings';
import { Theme } from '@/lib/theme';

export default function EditProfileScreen() {
  const { language, isRTL } = useLanguage();
  const { session } = useAuth();
  const [name, setName] = useState('');
  const [bio, setBio] = useState('');
  const [location, setLocation] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState<LText | null>(null);

  useEffect(() => {
    if (!session) return;
    supabase
      .from('profiles')
      .select('name_en, bio_en, location_en')
      .eq('id', session.user.id)
      .maybeSingle()
      .then(({ data }) => {
        if (data) {
          setName(data.name_en ?? '');
          setBio(data.bio_en ?? '');
          setLocation(data.location_en ?? '');
        }
        setLoading(false);
      });
  }, [session]);

  const save = async () => {
    if (!session) return;
    setSaving(true);
    setFeedback(null);
    const { error } = await supabase.from('profiles').upsert({
      id: session.user.id,
      name_ar: name,
      name_en: name,
      bio_ar: bio,
      bio_en: bio,
      location_ar: location,
      location_en: location,
    });
    setSaving(false);
    setFeedback(
      error
        ? { ar: 'تعذّر الحفظ. حاول مرة أخرى.', en: 'Could not save. Try again.' }
        : { ar: 'تم حفظ التغييرات.', en: 'Changes saved.' },
    );
  };

  return (
    <SafeAreaView style={styles.safe} edges={['bottom', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{t(S.editProfile, language)}</Text>
        <Field label={t(S.fullName, language)} value={name} onChangeText={setName} />
        <Field label={t(S.bio, language)} value={bio} onChangeText={setBio} />
        <Field label={t(S.location, language)} value={location} onChangeText={setLocation} />
        {feedback ? <Banner text={t(feedback, language)} tone="success" /> : null}
        <GoldButton title={t(S.saveChanges, language)} onPress={save} loading={saving || loading} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  content: { padding: Theme.margin, gap: 14 },
  title: { fontSize: 22, fontWeight: '600', color: Theme.ink, marginBottom: 4 },
});
