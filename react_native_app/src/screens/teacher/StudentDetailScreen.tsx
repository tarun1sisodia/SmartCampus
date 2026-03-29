import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, ScrollView } from 'react-native';
import { ChevronLeft, Mail, Phone, Calendar } from 'lucide-react-native';
import { Colors } from '../../theme/theme';
import { useNavigation } from '@react-navigation/native';

const StudentDetailScreen = () => {
  const navigation = useNavigation();

  // Mock Student Params Payload
  const student = { name: 'Alice Cooper', roll: '001', attendanceRate: '92%', class: 'BCA Section A' };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <ChevronLeft size={24} color={Colors.text} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Student Profile</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.profileHeader}>
          <View style={styles.avatarLarge}>
            <Text style={styles.avatarText}>{student.name.charAt(0)}</Text>
          </View>
          <Text style={styles.studentName}>{student.name}</Text>
          <Text style={styles.subtitle}>{student.class} | Roll: {student.roll}</Text>
          
          <View style={styles.statPill}>
            <Text style={styles.statPillText}>{student.attendanceRate} Attendance</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Contact Info</Text>
          
          <View style={styles.infoRow}>
            <View style={styles.iconBox}><Mail size={20} color={Colors.primary} /></View>
            <Text style={styles.infoText}>alice.c@smartcampus.edu</Text>
          </View>
          
          <View style={styles.infoRow}>
            <View style={styles.iconBox}><Phone size={20} color={Colors.success} /></View>
            <Text style={styles.infoText}>+1 (555) 123-4567</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent History</Text>
          <View style={styles.historyCard}>
            <Calendar size={18} color={Colors.neutral} />
            <Text style={styles.historyText}>Present on Oct 12th, 2026</Text>
          </View>
          <View style={styles.historyCard}>
             <Calendar size={18} color={Colors.neutral} />
            <Text style={styles.historyText}>Absent on Oct 11th, 2026</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.surface },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: 16, backgroundColor: Colors.white },
  backButton: { padding: 8 },
  headerTitle: { fontSize: 18, fontWeight: '700', color: Colors.text },
  content: { padding: 20 },
  profileHeader: { alignItems: 'center', padding: 24, backgroundColor: Colors.white, borderRadius: 20, marginBottom: 20, elevation: 2, shadowColor: Colors.black, shadowOpacity: 0.05, shadowOffset: { width:0, height: 2 }, shadowRadius: 8 },
  avatarLarge: { width: 80, height: 80, borderRadius: 40, backgroundColor: Colors.primaryLight, justifyContent: 'center', alignItems: 'center', marginBottom: 16 },
  avatarText: { fontSize: 32, fontWeight: '700', color: Colors.primary },
  studentName: { fontSize: 24, fontWeight: '700', color: Colors.text, marginBottom: 4 },
  subtitle: { fontSize: 14, color: Colors.neutral, marginBottom: 16 },
  statPill: { backgroundColor: Colors.success + '20', paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20 },
  statPillText: { color: Colors.success, fontWeight: '700', fontSize: 14 },
  section: { marginBottom: 24 },
  sectionTitle: { fontSize: 18, fontWeight: '700', color: Colors.text, marginBottom: 12 },
  infoRow: { flexDirection: 'row', alignItems: 'center', backgroundColor: Colors.white, padding: 16, borderRadius: 12, marginBottom: 8 },
  iconBox: { width: 40, height: 40, borderRadius: 10, backgroundColor: Colors.surface, justifyContent: 'center', alignItems: 'center', marginRight: 16 },
  infoText: { fontSize: 16, color: Colors.text, fontWeight: '500' },
  historyCard: { flexDirection: 'row', alignItems: 'center', padding: 16, backgroundColor: Colors.white, borderRadius: 12, marginBottom: 8, borderWidth: 1, borderColor: Colors.divider },
  historyText: { marginLeft: 12, fontSize: 14, color: Colors.textSecondary },
});

export default StudentDetailScreen;
