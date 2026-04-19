import 'package:flutter/material.dart';
import '../../../core/cache/hive_service.dart';
import '../../../app/dependency_injection.dart';

class HiveInspectorScreen extends StatefulWidget {
  const HiveInspectorScreen({super.key});

  @override
  State<HiveInspectorScreen> createState() => _HiveInspectorScreenState();
}

class _HiveInspectorScreenState extends State<HiveInspectorScreen> {
  final _hiveService = getIt<HiveService>();
  
  final List<String> _boxes = [
    HiveService.authBoxName,
    HiveService.settingsBoxName,
    HiveService.cacheBoxName,
    HiveService.teacherProfileBoxName,
    HiveService.organisationBoxName,
    HiveService.sessionCacheBoxName,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HIVE INSPECTOR'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _showClearAllConfirm(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _boxes.length,
        itemBuilder: (context, index) {
          final boxName = _boxes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(boxName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Items: ${_hiveService.authBox.length}'), // Static for now, needs real length
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showBoxContent(boxName),
            ),
          );
        },
      ),
    );
  }

  void _showBoxContent(String boxName) {
    // Basic implementation for now
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Content: $boxName', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                   const Text('Raw Data inspection not fully implemented yet.'),
                   const Text('Feature coming in v2.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will clear all local cache and logout current user.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              await _hiveService.clearAll();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
