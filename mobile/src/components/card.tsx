import { StyleSheet, View, type ViewProps } from 'react-native';
import { Theme } from '@/lib/theme';

interface CardProps extends ViewProps {
  padding?: number;
  radius?: number;
}

/** White elevated card on the ivory canvas — port of the Swift `.miyarCard()` modifier. */
export function Card({ padding = 16, radius = Theme.cardRadius, style, children, ...rest }: CardProps) {
  return (
    <View style={[styles.base, { padding, borderRadius: radius }, style]} {...rest}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  base: {
    backgroundColor: Theme.surface,
    borderWidth: 1,
    borderColor: Theme.hairline,
  },
});
