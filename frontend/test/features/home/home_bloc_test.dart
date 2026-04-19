import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus/core/api/api_client.dart';
import 'package:smart_campus/core/cache/hive_service.dart';
import 'package:smart_campus/features/home/bloc/home_bloc.dart';
import 'package:smart_campus/features/home/repositories/home_repository.dart';
import 'package:smart_campus/features/home/models/session_model.dart';

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository() : super(ApiClient(), HiveService());

  List<SessionModel>? cache;
  List<SessionModel> remote = const <SessionModel>[];

  @override
  List<SessionModel>? getCachedTodaySessions() => cache;

  @override
  Future<List<SessionModel>> fetchTodaySessions() async => remote;
}

void main() {
  test('HomeBloc emits cached then remote sessions', () async {
    final repo = _FakeHomeRepository()
      ..cache = <SessionModel>[
        SessionModel(
          id: 's1',
          subjectName: 'Math',
          section: 'A',
          courseId: 'c1',
          startTime: DateTime(2026, 4, 13, 9),
          totalStudents: 30,
          status: 'scheduled',
        ),
      ]
      ..remote = <SessionModel>[
        SessionModel(
          id: 's2',
          subjectName: 'Physics',
          section: 'B',
          courseId: 'c2',
          startTime: DateTime(2026, 4, 13, 11),
          totalStudents: 28,
          status: 'scheduled',
        ),
      ];

    final bloc = HomeBloc(repo);
    final states = <HomeState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(const LoadTodaySessions());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(states.whereType<HomeLoaded>().length, 2);
    expect(states.whereType<HomeLoaded>().first.sessions.first.id, 's1');
    expect(states.whereType<HomeLoaded>().last.sessions.first.id, 's2');

    await sub.cancel();
    await bloc.close();
  });
}
