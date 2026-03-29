import React, { useState } from 'react';
import { 
  View, 
  TextInput, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  TextInputProps, 
  ViewStyle, 
  TextStyle 
} from 'react-native';
import { Colors, AppTheme } from '../../theme/theme';
import { LucideIcon, Eye, EyeOff } from 'lucide-react-native';

interface CustomInputProps extends TextInputProps {
  label?: string;
  error?: string;
  leftIcon?: LucideIcon;
  containerStyle?: ViewStyle;
  inputStyle?: TextStyle;
  isPassword?: boolean;
}

const CustomInput = ({ 
  label, 
  error, 
  leftIcon: LeftIcon, 
  containerStyle, 
  inputStyle, 
  isPassword,
  ...props 
}: CustomInputProps) => {
  const [isFocused, setIsFocused] = useState(false);
  const [showPassword, setShowPassword] = useState(!isPassword);

  return (
    <View style={[styles.container, containerStyle]}>
      {label && <Text style={styles.label}>{label}</Text>}
      <View style={[
        styles.inputContainer, 
        isFocused && styles.inputFocused, 
        error && styles.inputError
      ]}>
        {LeftIcon && <LeftIcon size={20} stroke={isFocused ? Colors.primary : Colors.neutral} style={styles.icon} />}
        <TextInput
          style={[styles.input, inputStyle]}
          placeholderTextColor={Colors.neutral}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          secureTextEntry={isPassword && !showPassword}
          {...props}
        />
        {isPassword && (
          <TouchableOpacity onPress={() => setShowPassword(!showPassword)} style={styles.eyeIcon}>
            {showPassword ? <EyeOff size={20} stroke={Colors.neutral} /> : <Eye size={20} stroke={Colors.neutral} />}
          </TouchableOpacity>
        )}
      </View>
      {error && <Text style={styles.errorText}>{error}</Text>}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: AppTheme.spacing.sm,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.textSecondary,
    marginBottom: 6,
    marginLeft: 4,
  },
  inputContainer: {
    height: 52,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.surface,
    borderRadius: AppTheme.borderRadius.lg,
    paddingHorizontal: 16,
    borderWidth: 1.5,
    borderColor: 'transparent',
  },
  inputFocused: {
    borderColor: Colors.primary,
    backgroundColor: Colors.white,
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  inputError: {
    borderColor: Colors.error,
  },
  icon: {
    marginRight: 12,
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: Colors.text,
    height: '100%',
  },
  errorText: {
    fontSize: 12,
    color: Colors.error,
    marginTop: 4,
    marginLeft: 4,
  },
  eyeIcon: {
    padding: 8,
  },
});

export default CustomInput;
