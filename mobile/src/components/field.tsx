import { StyleSheet, Text, TextInput, View, type KeyboardTypeOptions } from 'react-native';
import { Theme } from '@/lib/theme';
import { useLanguage } from '@/context/language-context';

interface FieldProps {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  secureTextEntry?: boolean;
  keyboardType?: KeyboardTypeOptions;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
}

export function Field({
  label,
  value,
  onChangeText,
  placeholder,
  secureTextEntry,
  keyboardType,
  autoCapitalize = 'none',
}: FieldProps) {
  const { isRTL } = useLanguage();
  return (
    <View style={styles.wrap}>
      <Text style={[styles.label, { textAlign: isRTL ? 'right' : 'left' }]}>{label}</Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={Theme.secondaryText}
        secureTextEntry={secureTextEntry}
        keyboardType={keyboardType}
        autoCapitalize={autoCapitalize}
        autoCorrect={false}
        style={[styles.input, { textAlign: isRTL ? 'right' : 'left' }]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { gap: 6 },
  label: { fontSize: 13, color: Theme.secondaryText },
  input: {
    height: 48,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: Theme.hairline,
    backgroundColor: Theme.canvas,
    paddingHorizontal: 14,
    fontSize: 15,
    color: Theme.ink,
  },
});
