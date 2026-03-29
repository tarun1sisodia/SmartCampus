import React, { useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  KeyboardAvoidingView, 
  Platform, 
  ScrollView, 
  Image, 
  TouchableOpacity 
} from 'react-native';
import { Colors, AppTheme } from '../../theme/theme';
import CustomInput from '../../components/common/CustomInput';
import CustomButton from '../../components/common/CustomButton';
import { Mail, Lock, CheckCircle2, Fingerprint } from 'lucide-react-native';
import { useDispatch, useSelector } from 'react-redux';
import { signIn, loginWithBiometrics, setRememberMe } from '../../store/slices/authSlice';
import { AppDispatch, RootState } from '../../store/store';

const LoginScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const dispatch = useDispatch<AppDispatch>();
  const { isLoading, error, rememberMe } = useSelector((state: RootState) => state.auth);

  const handleLogin = () => {
    dispatch(signIn({ email, password }));
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container} 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <Image 
            source={require('../../../assets/logos/applogo.png')} 
            style={styles.logo} 
            resizeMode="contain"
          />
          <Text style={styles.title}>Welcome Back</Text>
          <Text style={styles.subtitle}>Sign in to continue managing attendance</Text>
        </View>

        <View style={styles.form}>
          <CustomInput
            label="Email Address"
            placeholder="Enter your email"
            value={email}
            onChangeText={setEmail}
            leftIcon={Mail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          <CustomInput
            label="Password"
            placeholder="Enter your password"
            value={password}
            onChangeText={setPassword}
            leftIcon={Lock}
            isPassword
          />

          <View style={styles.row}>
            <TouchableOpacity 
              style={styles.rememberRow} 
              onPress={() => dispatch(setRememberMe(!rememberMe))}
            >
              <CheckCircle2 
                size={20} 
                stroke={rememberMe ? Colors.primary : Colors.neutral} 
              />
              <Text style={[styles.rememberText, rememberMe && styles.rememberActive]}>
                Remember Me
              </Text>
            </TouchableOpacity>
            <TouchableOpacity>
              <Text style={styles.forgotText}>Forgot Password?</Text>
            </TouchableOpacity>
          </View>

          {error && <Text style={styles.errorText}>{error}</Text>}

          <CustomButton
            title="Sign In"
            onPress={handleLogin}
            isLoading={isLoading}
            style={styles.loginButton}
          />

          <TouchableOpacity style={styles.biometricButton} onPress={() => dispatch(loginWithBiometrics())}>
            <Fingerprint size={24} color={Colors.primary} />
            <Text style={styles.biometricText}>Login with Biometrics</Text>
          </TouchableOpacity>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Don't have an account? </Text>
            <TouchableOpacity>
              <Text style={styles.signUpText}>Sign Up</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.white,
  },
  scrollContent: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  logo: {
    width: 100,
    height: 100,
    marginBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: Colors.text,
  },
  subtitle: {
    fontSize: 16,
    color: Colors.neutral,
    marginTop: 8,
    textAlign: 'center',
  },
  form: {
    width: '100%',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 24,
  },
  rememberRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  rememberText: {
    fontSize: 14,
    color: Colors.neutral,
    marginLeft: 8,
  },
  rememberActive: {
    color: Colors.primary,
    fontWeight: '500',
  },
  forgotText: {
    fontSize: 14,
    color: Colors.primary,
    fontWeight: '600',
  },
  loginButton: {
    marginTop: 12,
  },
  errorText: {
    color: Colors.error,
    fontSize: 13,
    textAlign: 'center',
    marginBottom: 16,
  },
  biometricButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 24,
    padding: 12,
    borderRadius: 12,
    backgroundColor: Colors.surface,
  },
  biometricText: {
    marginLeft: 12,
    fontSize: 15,
    fontWeight: '600',
    color: Colors.primary,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 32,
  },
  footerText: {
    color: Colors.neutral,
    fontSize: 14,
  },
  signUpText: {
    color: Colors.primary,
    fontSize: 14,
    fontWeight: '700',
  },
});

export default LoginScreen;
