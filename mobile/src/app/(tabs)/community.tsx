import Ionicons from '@expo/vector-icons/Ionicons';
import { useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Card } from '@/components/card';
import { GoldButton } from '@/components/buttons';
import { Screen } from '@/components/screen';
import { useAuth } from '@/context/auth-context';
import { useAppData } from '@/context/data-context';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import { postKindLabel, type Post } from '@/types/post';

export default function CommunityScreen() {
  const { language, isRTL } = useLanguage();
  const { posts, addPost, toggleLike } = useAppData();
  const { session } = useAuth();
  const [draft, setDraft] = useState('');

  const submit = () => {
    if (!draft.trim()) return;
    const post: Post = {
      id: `post-${Date.now()}`,
      authorEmail: session?.user.email ?? 'me@miyar.app',
      kind: 'discussion',
      body: draft.trim(),
      createdAt: Date.now(),
      likeCount: 0,
      isLiked: false,
    };
    addPost(post);
    setDraft('');
  };

  return (
    <Screen title={t(S.community, language)}>
      <FlatList
        data={posts}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListHeaderComponent={
          <Card style={{ gap: 10, marginBottom: 12 }}>
            <TextInput
              value={draft}
              onChangeText={setDraft}
              placeholder={t(S.writeSomething, language)}
              placeholderTextColor={Theme.secondaryText}
              multiline
              style={[styles.composer, { textAlign: isRTL ? 'right' : 'left' }]}
            />
            <GoldButton title={t(S.post, language)} onPress={submit} disabled={!draft.trim()} />
          </Card>
        }
        ListEmptyComponent={<Text style={styles.emptyText}>{t(S.noPosts, language)}</Text>}
        renderItem={({ item }) => (
          <Card style={{ gap: 8 }}>
            <View style={[styles.headerRow, isRTL && styles.rowReverse]}>
              <Text style={styles.author}>{item.authorEmail}</Text>
              <View style={{ flex: 1 }} />
              <View style={styles.badge}>
                <Text style={styles.badgeText}>{t(postKindLabel[item.kind], language)}</Text>
              </View>
            </View>
            <Text style={[styles.body, { textAlign: isRTL ? 'right' : 'left' }]}>{item.body}</Text>
            <Pressable onPress={() => toggleLike(item.id)} style={[styles.likeRow, isRTL && styles.rowReverse]}>
              <Ionicons
                name={item.isLiked ? 'heart' : 'heart-outline'}
                size={16}
                color={item.isLiked ? Theme.danger : Theme.secondaryText}
              />
              <Text style={styles.likeCount}>{item.likeCount}</Text>
            </Pressable>
          </Card>
        )}
        ItemSeparatorComponent={() => <View style={{ height: 10 }} />}
      />
    </Screen>
  );
}

const styles = StyleSheet.create({
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24 },
  composer: { minHeight: 60, fontSize: 14, color: Theme.ink },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  rowReverse: { flexDirection: 'row-reverse' },
  author: { fontSize: 12, color: Theme.secondaryText },
  badge: { paddingHorizontal: 10, height: 22, borderRadius: 11, backgroundColor: Theme.goldSoft, alignItems: 'center', justifyContent: 'center' },
  badgeText: { fontSize: 10, fontWeight: '600', color: Theme.ink },
  body: { fontSize: 14, color: Theme.ink, lineHeight: 20 },
  likeRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  likeCount: { fontSize: 12, color: Theme.secondaryText },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
});
