import React from 'react';
import { Provider } from 'react-redux';
import { store } from './src/store/store';
import AppNavigator from './src/navigation/AppNavigator';
import { PaperProvider } from 'react-native-paper';
import { SafeAreaProvider } from 'react-native-safe-area-context';

export default function App() {
  return (
    <Provider store={store}>
      <SafeAreaProvider>
        <PaperProvider>
          <AppNavigator />
        </PaperProvider>
      </SafeAreaProvider>
    </Provider>
  );
}
