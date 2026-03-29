import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Image, Animated } from 'react-native';
import { Colors } from '../../theme/theme';
import { useNavigation } from '@react-navigation/native';
import { useSelector } from 'react-redux';
import { RootState } from '../../store/store';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SplashScreen = () => {
  const navigation = useNavigation<any>();
  const { user } = useSelector((state: RootState) => state.auth);
  const fadeAnim = new Animated.Value(0);

  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 1500,
      useNativeDriver: true,
    }).start();

    const checkOnboarding = async () => {
      const hasSeenOnboarding = await AsyncStorage.getItem('has_seen_onboarding');
      if (user) {
        navigation.replace('HomeTabs');
      } else if (hasSeenOnboarding) {
        navigation.replace('Login');
      } else {
        navigation.replace('Onboarding');
      }
    };

    const timer = setTimeout(() => {
      checkOnboarding();
    }, 2500);

    return () => clearTimeout(timer);
  }, [user]);

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.logoContainer, { opacity: fadeAnim }]}>
        <Image 
          source={require('../../../assets/logos/applogo.png')} 
          style={styles.logo} 
          resizeMode="contain"
        />
        <Text style={styles.title}>SmartCampus</Text>
        <Text style={styles.subtitle}>Attendance Management System</Text>
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.white,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoContainer: {
    alignItems: 'center',
  },
  logo: {
    width: 150,
    height: 150,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: Colors.primary,
    marginTop: 20,
  },
  subtitle: {
    fontSize: 16,
    color: Colors.neutral,
    marginTop: 8,
  },
});

export default SplashScreen;
