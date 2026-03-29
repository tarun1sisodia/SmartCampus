import React, { useEffect, useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  TouchableOpacity, 
  SafeAreaView, 
  StatusBar,
  RefreshControl
} from 'react-native';
import { Colors, AppTheme } from '../../theme/theme';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store/store';
import { Users, BookOpen, BarChart3, Search, Settings, MessageSquare, LogOut } from 'lucide-react-native';
import CustomInput from '../../components/common/CustomInput';
import { logout } from '../../store/slices/authSlice';

const StatCard = ({ title, value, icon: Icon, color }: any) => (
  <View style={[styles.statCard]}>
    <View style={[styles.iconContainer, { backgroundColor: color + '20' }]}>
      <Icon size={24} stroke={color} />
    </View>
    <View style={styles.statInfo}>
      <Text style={styles.statValue}>{value}</Text>
      <Text style={styles.statTitle}>{title}</Text>
    </View>
  </View>
);

const DashboardScreen = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const dispatch = useDispatch();
  const [refreshing, setRefreshing] = useState(false);
  const [search, setSearch] = useState('');

  const onRefresh = () => {
    setRefreshing(true);
    // Add logic to refresh data from Supabase/WatermelonDB
    setTimeout(() => setRefreshing(false), 1500);
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>{getGreeting()},</Text>
            <Text style={styles.userName}>{user?.fullName || 'Teacher'}</Text>
          </View>
          <TouchableOpacity style={styles.headerIcon} onPress={() => dispatch(logout())}>
            <LogOut size={24} stroke={Colors.neutral} />
          </TouchableOpacity>
        </View>

        {/* Search */}
        <CustomInput 
          placeholder="Search for classes..."
          value={search}
          onChangeText={setSearch}
          leftIcon={Search}
          containerStyle={styles.searchContainer}
        />

        {/* Stats Grid */}
        <View style={styles.statsGrid}>
          <StatCard 
            title="Total Classes" 
            value="8" 
            icon={BookOpen} 
            color={Colors.primary} 
          />
          <StatCard 
            title="Total Students" 
            value="342" 
            icon={Users} 
            color={Colors.accent} 
          />
          <StatCard 
            title="Avg. Attendance" 
            value="84%" 
            icon={BarChart3} 
            color={Colors.success} 
          />
        </View>

        {/* Classes Section */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>My Classes</Text>
          <TouchableOpacity>
            <Text style={styles.viewAll}>View All</Text>
          </TouchableOpacity>
        </View>

        {/* Simplified Class List (to be replaced with actual card component) */}
        {[1, 2, 3].map((item) => (
          <TouchableOpacity key={item} style={styles.classItem}>
            <View style={styles.classInfo}>
              <Text style={styles.className}>Operating Systems</Text>
              <Text style={styles.classDetails}>BCA - Section A - Semester 1</Text>
            </View>
            <View style={styles.attendanceBadge}>
              <Text style={styles.attendanceText}>85%</Text>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* Quick Menu / Bottom Navigation placeholders could go here */}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.white,
  },
  scrollContent: {
    padding: 24,
    paddingTop: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  greeting: {
    fontSize: 16,
    color: Colors.neutral,
  },
  userName: {
    fontSize: 24,
    fontWeight: '700',
    color: Colors.text,
  },
  headerIcon: {
    padding: 8,
    borderRadius: 12,
    backgroundColor: Colors.surface,
  },
  searchContainer: {
    marginBottom: 24,
  },
  statsGrid: {
    flexDirection: 'column',
    gap: 12,
    marginBottom: 32,
  },
  statCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.surface,
    padding: 16,
    borderRadius: AppTheme.borderRadius.lg,
  },
  iconContainer: {
    width: 48,
    height: 48,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  statInfo: {
    flex: 1,
  },
  statValue: {
    fontSize: 20,
    fontWeight: '700',
    color: Colors.text,
  },
  statTitle: {
    fontSize: 14,
    color: Colors.neutral,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: Colors.text,
  },
  viewAll: {
    fontSize: 14,
    color: Colors.primary,
    fontWeight: '600',
  },
  classItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: Colors.white,
    padding: 16,
    borderRadius: AppTheme.borderRadius.lg,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.divider,
    shadowColor: Colors.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  classInfo: {
    flex: 1,
  },
  className: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.text,
  },
  classDetails: {
    fontSize: 14,
    color: Colors.neutral,
    marginTop: 2,
  },
  attendanceBadge: {
    backgroundColor: Colors.primaryLight,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  attendanceText: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.primary,
  },
});

export default DashboardScreen;
