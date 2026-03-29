import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Home, BarChart2, Settings } from 'lucide-react-native';
import { View, Text } from 'react-native';
import { Colors } from '../theme/theme';

import DashboardScreen from '../screens/teacher/DashboardScreen';
import ReportsScreen from '../screens/teacher/ReportsScreen';

// Temporary Settings Placeholder
const SettingsScreen = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: Colors.white }}>
    <Text style={{ fontSize: 18, color: Colors.neutral }}>Settings Screen Coming Soon</Text>
  </View>
);

const Tab = createBottomTabNavigator();

const HomeTabs = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: Colors.primary,
        tabBarInactiveTintColor: Colors.neutral,
        tabBarStyle: {
          backgroundColor: Colors.white,
          borderTopWidth: 1,
          borderTopColor: Colors.divider,
          elevation: 10,
          shadowColor: Colors.black,
          shadowOffset: { width: 0, height: -2 },
          shadowOpacity: 0.05,
          shadowRadius: 10,
          height: 60,
          paddingBottom: 8,
          paddingTop: 8,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '600',
        },
      }}
    >
      <Tab.Screen 
        name="DashboardTab" 
        component={DashboardScreen} 
        options={{
          tabBarLabel: 'Home',
          tabBarIcon: ({ color, size }: { color: string, size: number }) => <Home color={color} size={size} />,
        }}
      />
      <Tab.Screen 
        name="ReportsTab" 
        component={ReportsScreen} 
        options={{
          tabBarLabel: 'Reports',
          tabBarIcon: ({ color, size }: { color: string, size: number }) => <BarChart2 color={color} size={size} />,
        }}
      />
      <Tab.Screen 
        name="SettingsTab" 
        component={SettingsScreen} 
        options={{
          tabBarLabel: 'Settings',
          tabBarIcon: ({ color, size }: { color: string, size: number }) => <Settings color={color} size={size} />,
        }}
      />
    </Tab.Navigator>
  );
};

export default HomeTabs;
