import { StyleSheet, Text, View, type ViewProps } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Theme } from '@/lib/theme';
import { useLanguage } from '@/context/language-context';

interface ScreenProps extends ViewProps {
  title?: string;
  children: React.ReactNode;
}

/** Ivory canvas + optional title header, matching the Swift app's MiyarScreen. */
export function Screen({ title, children, style, ...rest }: ScreenProps) {
  const { isRTL } = useLanguage();
  return (
    <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
      <View style={[styles.container, style]} {...rest}>
        {title ? (
          <Text style={[styles.title, { textAlign: isRTL ? 'right' : 'left' }]}>{title}</Text>
        ) : null}
        {children}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Theme.canvas },
  container: { flex: 1, backgroundColor: Theme.canvas },
  title: {
    fontSize: 22,
    fontWeight: '600',
    color: Theme.ink,
    paddingHorizontal: Theme.margin,
    paddingTop: 12,
    paddingBottom: 4,
  },
});
