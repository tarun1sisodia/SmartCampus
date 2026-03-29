import React from 'react';
import { View, Text, StyleSheet, ScrollView, Dimensions, SafeAreaView } from 'react-native';
import { PieChart, BarChart } from 'react-native-chart-kit';
import { Colors } from '../../theme/theme';

const screenWidth = Dimensions.get('window').width - 40; // padding 20

const ReportsScreen = () => {
  const chartConfig = {
    backgroundGradientFrom: Colors.white,
    backgroundGradientTo: Colors.white,
    color: (opacity = 1) => `rgba(62, 105, 255, ${opacity})`,
    labelColor: (opacity = 1) => Colors.neutral,
    strokeWidth: 2,
    barPercentage: 0.5,
    useShadowColorFromDataset: false
  };

  const pieData = [
    { name: 'Present', population: 85, color: Colors.success, legendFontColor: Colors.text, legendFontSize: 13 },
    { name: 'Absent', population: 10, color: Colors.error, legendFontColor: Colors.text, legendFontSize: 13 },
    { name: 'Late', population: 5, color: Colors.warning, legendFontColor: Colors.text, legendFontSize: 13 },
  ];

  const barData = {
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    datasets: [{ data: [95, 90, 85, 92, 88] }]
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Analytics Hub</Text>
        <Text style={styles.subtitle}>Monthly Attendance Summary</Text>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContainer} showsVerticalScrollIndicator={false}>
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Global Attendance Ratio</Text>
          <PieChart
            data={pieData}
            width={screenWidth}
            height={220}
            chartConfig={chartConfig}
            accessor={"population"}
            backgroundColor={"transparent"}
            paddingLeft={"15"}
            center={[10, 0]}
            absolute
          />
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Weekly Distribution</Text>
          <BarChart
            data={barData}
            width={screenWidth}
            height={220}
            yAxisLabel=""
            yAxisSuffix="%"
            chartConfig={{...chartConfig, formatYLabel: (yValue: string) => Math.round(Number(yValue)).toString()}}
            verticalLabelRotation={0}
            style={styles.barChartStyle}
            withInnerLines={false}
          />
        </View>

      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.surface },
  header: { padding: 20, paddingBottom: 10, backgroundColor: Colors.white, borderBottomWidth: 1, borderBottomColor: Colors.divider },
  title: { fontSize: 24, fontWeight: '700', color: Colors.text },
  subtitle: { fontSize: 14, color: Colors.neutral, marginTop: 4 },
  scrollContainer: { padding: 20, gap: 20, paddingBottom: 100 },
  card: {
    backgroundColor: Colors.white,
    borderRadius: 16,
    padding: 20,
    shadowColor: Colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 4,
    borderWidth: 1,
    borderColor: Colors.divider,
  },
  cardTitle: { fontSize: 16, fontWeight: '600', color: Colors.text, marginBottom: 16 },
  barChartStyle: { borderRadius: 12, marginTop: 8 },
});

export default ReportsScreen;
