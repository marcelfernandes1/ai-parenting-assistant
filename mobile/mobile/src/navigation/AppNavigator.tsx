/**
 * AppNavigator - Main navigation component for the app
 * Handles authentication flow and protected routes
 *
 * Navigation Structure:
 * - AuthStack: Login, Register screens (unauthenticated users)
 * - OnboardingStack: Multi-step onboarding flow (new users)
 * - MainStack: Main app screens (authenticated users who completed onboarding)
 */

import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { NavigationContainer } from '@react-navigation/native';
import { useAuth } from '../context/AuthContext';

// Auth Screens
import LoginScreen from '../screens/LoginScreen';
import RegisterScreen from '../screens/RegisterScreen';

// Onboarding Screens
import WelcomeScreen from '../screens/onboarding/WelcomeScreen';
import CurrentStageScreen from '../screens/onboarding/CurrentStageScreen';
import TimelineInputScreen from '../screens/onboarding/TimelineInputScreen';
import BabyInfoScreen from '../screens/onboarding/BabyInfoScreen';
import ParentingPhilosophyScreen from '../screens/onboarding/ParentingPhilosophyScreen';
import ReligiousBackgroundScreen from '../screens/onboarding/ReligiousBackgroundScreen';
import CulturalBackgroundScreen from '../screens/onboarding/CulturalBackgroundScreen';
import ConcernsScreen from '../screens/onboarding/ConcernsScreen';
import NotificationPreferencesScreen from '../screens/onboarding/NotificationPreferencesScreen';
import UsageLimitsExplanationScreen from '../screens/onboarding/UsageLimitsExplanationScreen';

// Placeholder for main app screen (will be replaced with actual home screen)
import { View, Text, Button, StyleSheet } from 'react-native';

/**
 * Type definitions for navigation parameters
 * Each screen in the stack can receive these parameters
 */
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
};

export type OnboardingStackParamList = {
  Welcome: undefined;
  CurrentStage: undefined;
  TimelineInput: undefined;
  BabyInfo: undefined;
  ParentingPhilosophy: undefined;
  ReligiousBackground: undefined;
  CulturalBackground: undefined;
  Concerns: undefined;
  NotificationPreferences: undefined;
  UsageLimitsExplanation: undefined;
};

export type MainStackParamList = {
  Home: undefined;
  // Add more main app screens here as they're built
};

// Create stack navigators for each flow
const AuthStack = createStackNavigator<AuthStackParamList>();
const OnboardingStack = createStackNavigator<OnboardingStackParamList>();
const MainStack = createStackNavigator<MainStackParamList>();

/**
 * Temporary home screen placeholder
 * This will be replaced with actual main app screens (chat, voice, photos, etc.)
 */
function HomeScreen() {
  const { logout, user } = useAuth();

  return (
    <View style={styles.homeContainer}>
      <Text style={styles.homeTitle}>🎉 Welcome to AI Parenting Assistant!</Text>
      <Text style={styles.homeSubtitle}>You're logged in as:</Text>
      <Text style={styles.homeEmail}>{user?.email}</Text>
      <Text style={styles.homeMessage}>
        Main app screens (Chat, Voice, Photos, Milestones) will go here.
      </Text>
      <Button title="Logout" onPress={logout} />
    </View>
  );
}

/**
 * AuthNavigator - Handles unauthenticated user flow
 * Shows Login and Register screens with navigation between them
 */
function AuthNavigator() {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false, // Hide headers for auth screens for cleaner look
      }}
    >
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
    </AuthStack.Navigator>
  );
}

/**
 * OnboardingNavigator - Handles multi-step onboarding flow
 * New users go through these screens to set up their profile
 */
function OnboardingNavigator() {
  return (
    <OnboardingStack.Navigator
      screenOptions={{
        headerShown: false, // Hide headers for smooth onboarding experience
      }}
    >
      <OnboardingStack.Screen name="Welcome" component={WelcomeScreen} />
      <OnboardingStack.Screen name="CurrentStage" component={CurrentStageScreen} />
      <OnboardingStack.Screen name="TimelineInput" component={TimelineInputScreen} />
      <OnboardingStack.Screen name="BabyInfo" component={BabyInfoScreen} />
      <OnboardingStack.Screen name="ParentingPhilosophy" component={ParentingPhilosophyScreen} />
      <OnboardingStack.Screen name="ReligiousBackground" component={ReligiousBackgroundScreen} />
      <OnboardingStack.Screen name="CulturalBackground" component={CulturalBackgroundScreen} />
      <OnboardingStack.Screen name="Concerns" component={ConcernsScreen} />
      <OnboardingStack.Screen name="NotificationPreferences" component={NotificationPreferencesScreen} />
      <OnboardingStack.Screen name="UsageLimitsExplanation" component={UsageLimitsExplanationScreen} />
    </OnboardingStack.Navigator>
  );
}

/**
 * MainNavigator - Handles authenticated user's main app screens
 * This is where users spend most of their time (chat, voice, photos, etc.)
 */
function MainNavigator() {
  return (
    <MainStack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#6B46C1', // Purple brand color
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      <MainStack.Screen
        name="Home"
        component={HomeScreen}
        options={{ title: 'AI Parenting Assistant' }}
      />
    </MainStack.Navigator>
  );
}

/**
 * AppNavigator - Root navigator that determines which flow to show
 *
 * Logic:
 * 1. If not authenticated -> Show AuthNavigator (Login/Register)
 * 2. If authenticated but no profile -> Show OnboardingNavigator
 * 3. If authenticated with profile -> Show MainNavigator
 *
 * TODO: Add logic to check if user has completed onboarding
 * For now, we'll show onboarding after login (can be skipped for testing)
 */
export default function AppNavigator() {
  const { user, loading } = useAuth();

  // Show nothing while checking authentication status
  // This prevents flash of wrong screen during initial load
  if (loading) {
    return null;
  }

  return (
    <NavigationContainer>
      {!user ? (
        // User not logged in -> Show auth screens
        <AuthNavigator />
      ) : (
        // User logged in -> Show onboarding or main app
        // TODO: Check if user has completed onboarding profile
        // For now, we'll go straight to main app after login
        // You can uncomment OnboardingNavigator to test onboarding flow
        <MainNavigator />
        // <OnboardingNavigator />
      )}
    </NavigationContainer>
  );
}

/**
 * Styles for the temporary home screen
 */
const styles = StyleSheet.create({
  homeContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#F9FAFB',
  },
  homeTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
    color: '#1F2937',
  },
  homeSubtitle: {
    fontSize: 16,
    color: '#6B7280',
    marginBottom: 8,
  },
  homeEmail: {
    fontSize: 18,
    fontWeight: '600',
    color: '#6B46C1',
    marginBottom: 24,
  },
  homeMessage: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
    marginBottom: 32,
    paddingHorizontal: 20,
  },
});
