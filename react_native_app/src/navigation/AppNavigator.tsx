import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useSelector } from 'react-redux';
import { RootState } from '../store/store';

// Placeholder Screens
import LoginScreen from '../screens/auth/LoginScreen';
import SplashScreen from '../screens/common/SplashScreen';
import DashboardScreen from '../screens/teacher/DashboardScreen';
import MarkAttendanceScreen from '../screens/teacher/MarkAttendanceScreen';
import HomeTabs from './HomeTabs';
import StudentDetailScreen from '../screens/teacher/StudentDetailScreen';

const Stack = createNativeStackNavigator();

const AppNavigator = () => {
  const { user, isLoading } = useSelector((state: RootState) => state.auth);

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {/* Always show splash if loading (optional, depends on logic) */}
        {!user ? (
          <>
            <Stack.Screen name="Splash" component={SplashScreen} />
            <Stack.Screen name="Onboarding" component={require('../screens/common/OnboardingScreen').default} />
            <Stack.Screen name="Login" component={LoginScreen} />
          </>
        ) : (
          <>
            <Stack.Screen name="HomeTabs" component={HomeTabs} />
            <Stack.Screen name="MarkAttendance" component={MarkAttendanceScreen} />
            <Stack.Screen name="StudentDetail" component={StudentDetailScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
