import { ActivityIndicator, Pressable, StyleSheet, Text } from 'react-native';
import { Theme } from '@/lib/theme';

interface ButtonProps {
  title: string;
  onPress: () => void;
  disabled?: boolean;
  loading?: boolean;
}

/** Primary gold action button — port of GoldButtonStyle. */
export function GoldButton({ title, onPress, disabled, loading }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      style={({ pressed }) => [
        styles.gold,
        (disabled || loading) && styles.disabled,
        pressed && styles.pressed,
      ]}
    >
      {loading ? <ActivityIndicator color={Theme.ink} /> : <Text style={styles.goldText}>{title}</Text>}
    </Pressable>
  );
}

/** Secondary ink-outlined button — port of InkButtonStyle. */
export function InkButton({ title, onPress, disabled, loading }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      style={({ pressed }) => [styles.ink, (disabled || loading) && styles.disabled, pressed && styles.pressed]}
    >
      {loading ? <ActivityIndicator color={Theme.ink} /> : <Text style={styles.inkText}>{title}</Text>}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  gold: {
    minHeight: 50,
    borderRadius: 14,
    backgroundColor: Theme.gold,
    alignItems: 'center',
    justifyContent: 'center',
  },
  goldText: { fontSize: 16, fontWeight: '600', color: Theme.ink },
  ink: {
    minHeight: 50,
    borderRadius: 14,
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: 'rgba(44, 42, 38, 0.25)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  inkText: { fontSize: 16, fontWeight: '500', color: Theme.ink },
  disabled: { opacity: 0.5 },
  pressed: { opacity: 0.82 },
});
