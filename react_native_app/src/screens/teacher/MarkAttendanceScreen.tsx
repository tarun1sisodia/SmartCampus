import React, { useRef, useState } from 'react';
import { 
  View, Text, StyleSheet, SafeAreaView, TouchableOpacity, FlatList, Animated, PanResponder, Dimensions 
} from 'react-native';
import { Colors, AppTheme } from '../../theme/theme';
import { ChevronLeft, Check, X, Camera } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';

const { width } = Dimensions.get('window');
const SWIPE_THRESHOLD = width * 0.25;

type StudentData = { id: string; name: string; roll: string; status: string | null };

// Mock Data
const MOCK_STUDENTS: StudentData[] = [
  { id: '1', name: 'Alice Cooper', roll: '001', status: null },
  { id: '2', name: 'Bob Singer', roll: '002', status: null },
  { id: '3', name: 'Charlie Day', roll: '003', status: null },
  { id: '4', name: 'Diana Prince', roll: '004', status: null },
  { id: '5', name: 'Evan Peters', roll: '005', status: null },
  { id: '6', name: 'Fiona Gallagher', roll: '006', status: null },
  { id: '7', name: 'George Costanza', roll: '007', status: null },
];

const SwipeableStudentRow = ({ student, onMark }: any) => {
  const pan = useRef(new Animated.ValueXY()).current;
  const [markedStatus, setMarkedStatus] = useState<string | null>(student.status);

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_, gestureState) => {
        return Math.abs(gestureState.dx) > 10;
      },
      onPanResponderMove: Animated.event([null, { dx: pan.x }], {
        useNativeDriver: false,
      }),
      onPanResponderRelease: (_, gestureState) => {
        if (gestureState.dx > SWIPE_THRESHOLD) {
          // Swipe Right (Present)
          Animated.spring(pan, {
            toValue: { x: width, y: 0 },
            useNativeDriver: false,
          }).start(() => {
            setMarkedStatus('present');
            onMark(student.id, 'present');
            pan.setValue({ x: 0, y: 0 }); // reset to snap back
          });
        } else if (gestureState.dx < -SWIPE_THRESHOLD) {
          // Swipe Left (Absent)
          Animated.spring(pan, {
            toValue: { x: -width, y: 0 },
            useNativeDriver: false,
          }).start(() => {
            setMarkedStatus('absent');
            onMark(student.id, 'absent');
            pan.setValue({ x: 0, y: 0 }); // reset to snap back
          });
        } else {
          // Reset
          Animated.spring(pan, {
            toValue: { x: 0, y: 0 },
            useNativeDriver: false,
            friction: 5,
          }).start();
        }
      },
    })
  ).current;

  // Background color interpolation requires clamped interpolation
  // so it doesn't output values outside of color strings.
  const bgOpacity = pan.x.interpolate({
    inputRange: [-SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD],
    outputRange: [1, 0, 1],
    extrapolate: 'clamp',
  });

  const bgColor = pan.x.interpolate({
    inputRange: [-SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD],
    outputRange: [Colors.error, Colors.white, Colors.success],
    extrapolate: 'clamp',
  });

  return (
    <View style={styles.rowContainer}>
      {/* Background showing Present/Absent actions */}
      <Animated.View style={[styles.backgroundRow, { backgroundColor: bgColor, opacity: bgOpacity }]}>
        <View style={styles.actionLeft}>
          <Check size={24} color={Colors.white} />
          <Text style={styles.actionText}>Present</Text>
        </View>
        <View style={styles.actionRight}>
          <Text style={styles.actionText}>Absent</Text>
          <X size={24} color={Colors.white} />
        </View>
      </Animated.View>

      {/* Swipeable Foreground Card */}
      <Animated.View
        style={[
          styles.studentCard,
          { transform: pan.getTranslateTransform() },
          markedStatus === 'present' && { borderLeftColor: Colors.success, borderLeftWidth: 4 },
          markedStatus === 'absent' && { borderLeftColor: Colors.error, borderLeftWidth: 4 },
        ]}
        {...panResponder.panHandlers}
      >
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>{student.name.charAt(0)}</Text>
        </View>
        <View style={styles.studentInfo}>
          <Text style={styles.studentName}>{student.name}</Text>
          <Text style={styles.studentRoll}>Roll Number: {student.roll}</Text>
        </View>
        <View style={styles.statusIndicator}>
          {markedStatus === 'present' && <Check size={20} color={Colors.success} />}
          {markedStatus === 'absent' && <X size={20} color={Colors.error} />}
        </View>
      </Animated.View>
    </View>
  );
};

const MarkAttendanceScreen = () => {
  const navigation = useNavigation();
  const [students, setStudents] = useState(MOCK_STUDENTS);

  const handleMark = (id: string, status: string) => {
    setStudents((prev) => prev.map((s) => (s.id === id ? { ...s, status } : s)));
  };

  const presentCount = students.filter(s => s.status === 'present').length;
  const absentCount = students.filter(s => s.status === 'absent').length;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <ChevronLeft size={24} color={Colors.text} />
        </TouchableOpacity>
        <View>
          <Text style={styles.headerTitle}>Mark Attendance</Text>
          <Text style={styles.headerSubtitle}>Operating Systems - BCA Sec A</Text>
        </View>
        <TouchableOpacity style={styles.iconButton}>
           <Camera size={24} color={Colors.primary} />
        </TouchableOpacity>
      </View>

      <View style={styles.statsContainer}>
        <View style={[styles.statBox, { backgroundColor: Colors.surface }]}>
          <Text style={styles.statLabel}>Total</Text>
          <Text style={[styles.statValue, { color: Colors.primary }]}>{students.length}</Text>
        </View>
        <View style={[styles.statBox, { backgroundColor: Colors.success + '20' }]}>
          <Text style={styles.statLabel}>Present</Text>
          <Text style={[styles.statValue, { color: Colors.success }]}>{presentCount}</Text>
        </View>
        <View style={[styles.statBox, { backgroundColor: Colors.error + '20' }]}>
          <Text style={styles.statLabel}>Absent</Text>
          <Text style={[styles.statValue, { color: Colors.error }]}>{absentCount}</Text>
        </View>
      </View>

      <View style={styles.helperTextContainer}>
        <Text style={styles.helperText}>Swipe Right for Present • Swipe Left for Absent</Text>
      </View>

      <FlatList
        data={students}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <SwipeableStudentRow student={item} onMark={handleMark} />}
        contentContainerStyle={styles.listContent}
      />

      <View style={styles.footer}>
        <TouchableOpacity style={styles.submitButton}>
          <Text style={styles.submitText}>Submit Attendance</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.white },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 20,
    justifyContent: 'space-between',
    borderBottomWidth: 1,
    borderBottomColor: Colors.divider,
  },
  backButton: { padding: 8, marginLeft: -8 },
  headerTitle: { fontSize: 20, fontWeight: '700', color: Colors.text, textAlign: 'center' },
  headerSubtitle: { fontSize: 13, color: Colors.neutral, textAlign: 'center', marginTop: 2 },
  iconButton: { padding: 8, backgroundColor: Colors.primaryLight, borderRadius: 12 },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 16,
    gap: 12,
  },
  statBox: {
    flex: 1,
    padding: 12,
    borderRadius: 12,
    alignItems: 'center',
  },
  statLabel: { fontSize: 12, color: Colors.textSecondary, marginBottom: 4, fontWeight: '600' },
  statValue: { fontSize: 20, fontWeight: '700' },
  helperTextContainer: { alignItems: 'center', marginBottom: 12 },
  helperText: { fontSize: 12, color: Colors.neutral, fontWeight: '500' },
  listContent: { paddingHorizontal: 20, paddingBottom: 100 },
  rowContainer: { position: 'relative', marginBottom: 12, marginHorizontal: 4 },
  backgroundRow: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    overflow: 'hidden',
  },
  actionLeft: { flexDirection: 'row', alignItems: 'center', paddingLeft: 20, width: '50%' },
  actionRight: { flexDirection: 'row', alignItems: 'center', paddingRight: 20, width: '50%', justifyContent: 'flex-end' },
  actionText: { color: Colors.white, fontWeight: '600', fontSize: 16, marginHorizontal: 8 },
  studentCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    padding: 16,
    borderRadius: 16,
    shadowColor: Colors.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
    borderWidth: 1,
    borderColor: Colors.divider,
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.surface,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  avatarText: { fontSize: 18, fontWeight: '700', color: Colors.primary },
  studentInfo: { flex: 1 },
  studentName: { fontSize: 16, fontWeight: '600', color: Colors.text },
  studentRoll: { fontSize: 13, color: Colors.neutral, marginTop: 4 },
  statusIndicator: { width: 32, alignItems: 'flex-end' },
  footer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    padding: 20,
    backgroundColor: Colors.white,
    borderTopWidth: 1,
    borderTopColor: Colors.divider,
  },
  submitButton: {
    backgroundColor: Colors.primary,
    padding: 16,
    borderRadius: 16,
    alignItems: 'center',
    shadowColor: Colors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  submitText: { color: Colors.white, fontSize: 16, fontWeight: '700' },
});

export default MarkAttendanceScreen;
