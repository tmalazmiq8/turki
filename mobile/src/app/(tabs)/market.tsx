import Ionicons from '@expo/vector-icons/Ionicons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { FlatList, Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { Card } from '@/components/card';
import { GoldButton } from '@/components/buttons';
import { Field } from '@/components/field';
import { Screen } from '@/components/screen';
import { useAuth } from '@/context/auth-context';
import { useAppData } from '@/context/data-context';
import { useLanguage } from '@/context/language-context';
import { S, t } from '@/lib/strings';
import { Theme } from '@/lib/theme';
import type { Listing } from '@/types/listing';

export default function MarketScreen() {
  const { language, isRTL } = useLanguage();
  const { listings, addListing } = useAppData();
  const { session } = useAuth();
  const router = useRouter();
  const [modalOpen, setModalOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');

  const submit = () => {
    if (!title.trim()) return;
    const listing: Listing = {
      id: `listing-${Date.now()}`,
      title: title.trim(),
      description: description.trim(),
      category: 'fullBottle',
      priceUSD: Number(price) || 0,
      sellerEmail: session?.user.email ?? 'me@miyar.app',
      createdAt: Date.now(),
    };
    addListing(listing);
    setTitle('');
    setDescription('');
    setPrice('');
    setModalOpen(false);
  };

  return (
    <Screen title={t(S.market, language)}>
      <View style={{ paddingHorizontal: Theme.margin, marginBottom: 12 }}>
        <GoldButton title={t(S.newListing, language)} onPress={() => setModalOpen(true)} />
      </View>

      <FlatList
        data={listings}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={<Text style={styles.emptyText}>{t(S.noListings, language)}</Text>}
        renderItem={({ item }) => (
          <Pressable onPress={() => router.push({ pathname: '/listing/[id]', params: { id: item.id } })}>
            <Card style={[styles.row, isRTL && styles.rowReverse]}>
              <View style={styles.iconWrap}>
                <Ionicons name="bag-outline" size={18} color={Theme.gold} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={[styles.name, { textAlign: isRTL ? 'right' : 'left' }]}>{item.title}</Text>
                <Text style={[styles.subtitle, { textAlign: isRTL ? 'right' : 'left' }]} numberOfLines={1}>
                  {item.description}
                </Text>
              </View>
              <Text style={styles.price}>${item.priceUSD.toFixed(0)}</Text>
            </Card>
          </Pressable>
        )}
      />

      <Modal visible={modalOpen} animationType="slide" transparent onRequestClose={() => setModalOpen(false)}>
        <View style={styles.modalBackdrop}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>{t(S.newListing, language)}</Text>
            <Field label={t(S.listingTitle, language)} value={title} onChangeText={setTitle} />
            <Field label={t(S.description, language)} value={description} onChangeText={setDescription} />
            <Field label={`${t(S.price, language)} (USD)`} value={price} onChangeText={setPrice} keyboardType="numeric" />
            <View style={{ flexDirection: 'row', gap: 10, marginTop: 8 }}>
              <View style={{ flex: 1 }}>
                <GoldButton title={t(S.post, language)} onPress={submit} />
              </View>
              <View style={{ flex: 1 }}>
                <Pressable onPress={() => setModalOpen(false)} style={styles.cancelButton}>
                  <Text style={styles.cancelText}>{t(S.cancel, language)}</Text>
                </Pressable>
              </View>
            </View>
          </View>
        </View>
      </Modal>
    </Screen>
  );
}

const styles = StyleSheet.create({
  list: { paddingHorizontal: Theme.margin, paddingBottom: 24, gap: 10 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: Theme.tileRadius },
  rowReverse: { flexDirection: 'row-reverse' },
  iconWrap: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: Theme.goldSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  name: { fontSize: 15, fontWeight: '500', color: Theme.ink },
  subtitle: { fontSize: 12, color: Theme.secondaryText, marginTop: 2 },
  price: { fontSize: 14, fontWeight: '700', color: Theme.gold },
  emptyText: { textAlign: 'center', color: Theme.secondaryText, marginTop: 40 },
  modalBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'flex-end' },
  modalCard: {
    backgroundColor: Theme.canvas,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: Theme.margin,
    gap: 12,
  },
  modalTitle: { fontSize: 18, fontWeight: '600', color: Theme.ink, textAlign: 'center' },
  cancelButton: {
    height: 50,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
  },
  cancelText: { fontSize: 16, fontWeight: '500', color: Theme.ink },
});
