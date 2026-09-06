import { StyleSheet, Text } from 'react-native';
import { Theme } from '@/lib/theme';
import { useLanguage } from '@/context/language-context';

type Tone = 'info' | 'error' | 'success';

const toneColor: Record<Tone, string> = {
  info: Theme.secondaryText,
  error: Theme.danger,
  success: Theme.gold,
};

export function Banner({ text, tone = 'info' }: { text: string; tone?: Tone }) {
  const { isRTL } = useLanguage();
  const color = toneColor[tone];
  return (
    <Text
      style={[
        styles.text,
        { color, borderColor: color, backgroundColor: `${color}1F`, textAlign: isRTL ? 'right' : 'left' },
      ]}
    >
      {text}
    </Text>
  );
}

const styles = StyleSheet.create({
  text: {
    fontSize: 13,
    fontWeight: '500',
    padding: 12,
    borderRadius: 12,
    borderWidth: 1,
    overflow: 'hidden',
  },
});
