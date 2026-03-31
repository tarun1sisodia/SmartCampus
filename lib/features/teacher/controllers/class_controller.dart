import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../common/utils/constants/text_strings.dart';
import '../../../models/class_model.dart';
import '../../../models/course_model.dart';
import '../../../models/subject_model.dart';
import '../../../services/class_service.dart';
import '../../../services/course_service.dart';
import '../../../services/subject_service.dart';
import '../../../services/realtime_service.dart';
import '../../../common/utils/helpers/snackbar_helper.dart';
import 'dart:async';

class ClassController extends GetxController {
  final classService = ClassService();
  final courseService = CourseService();
  final subjectService = SubjectService();
  
  // Get RealtimeService instance
  late final RealtimeService realtimeService;

  final isLoading = false.obs;
  final classes = <ClassModel>[].obs;
  final courses = <CourseModel>[].obs;
  final subjects = <SubjectModel>[].obs;

  // Real-time connection status
  final isRealtimeConnected = true.obs;
  final lastUpdated = DateTime.now().obs;

  // Form controllers
  final selectedSubjectId = ''.obs;
  final selectedCourseId = ''.obs;
  final semesterController = TextEditingController();
  final sectionController = TextEditingController();
  var selectedCourse = Rxn<CourseModel>();
  var selectedSubject = Rxn<dynamic>();

  // Multi-select properties
  final isSelectionMode = false.obs;
  final selectedClassIds = <String>{}.obs;
  final isAllSelected = false.obs;

  // Search functionality
  final searchQuery = ''.obs;
  final filteredClasses = <ClassModel>[].obs;
  final hasMoreClasses = true.obs;
  final isLoadingMore = false.obs;

  final List<StreamSubscription> _subscriptions = [];
  static const int _teacherClassFetchLimit = 20;
  int _classesOffset = 0;

  @override
  void onInit() {
    super.onInit();
    debugPrint('ClassController initialized');
    _initializeRealtimeService();
    loadClasses();
    loadCoursesAndSubjects();
  }

  @override
  void onClose() {
    debugPrint('ClassController disposed');
    semesterController.dispose();
    sectionController.dispose();
    
    // Clean up subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  // Initialize the realtime service
  void _initializeRealtimeService() {
    try {
      realtimeService = Get.find<RealtimeService>();
      debugPrint('Found existing RealtimeService instance in ClassController');
    } catch (e) {
      debugPrint('RealtimeService not found, creating new instance in ClassController');
      realtimeService = Get.put(RealtimeService());
    }
    
    _setupRealtimeSubscriptions();
  }

  // Set up real-time subscriptions for UI updates
  void _setupRealtimeSubscriptions() {
    // Subscribe to classes stream for real-time updates
    final classesSubscription = realtimeService.classesStream.listen(
      (data) {
        debugPrint('Real-time classes update in ClassController: ${data.length} classes');
        _handleClassesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in classes stream (ClassController): $error');
        isRealtimeConnected.value = false;
      },
    );

    // Subscribe to subjects stream for dropdown updates
    final subjectsSubscription = realtimeService.subjectsStream.listen(
      (data) {
        debugPrint('Real-time subjects update in ClassController: ${data.length} subjects');
        _handleSubjectsUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in subjects stream (ClassController): $error');
      },
    );

    // Subscribe to courses stream for dropdown updates
    final coursesSubscription = realtimeService.coursesStream.listen(
      (data) {
        debugPrint('Real-time courses update in ClassController: ${data.length} courses');
        _handleCoursesUpdate(data);
        lastUpdated.value = DateTime.now();
      },
      onError: (error) {
        debugPrint('Error in courses stream (ClassController): $error');
      },
    );

    // Monitor RealtimeService connection status
    final connectionSubscription = realtimeService.isConnected.listen(
      (isConnected) {
        isRealtimeConnected.value = isConnected;
        if (isConnected) {
          debugPrint('Real-time connection restored in ClassController');
          // Refresh data when connection is restored
          loadClasses();
          loadCoursesAndSubjects();
        } else {
          debugPrint('Real-time connection lost in ClassController');
        }
      },
    );

    _subscriptions.addAll([
      classesSubscription,
      subjectsSubscription,
      coursesSubscription,
      connectionSubscription,
    ]);

    isRealtimeConnected.value = realtimeService.isConnected.value;
  }

  // Handle real-time classes updates to update UI
  void _handleClassesUpdate(List<Map<String, dynamic>> data) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      final teacherClassData = data
          .where((classData) => classData['teacher_id'] == currentUser.id)
          .toList();
      if (teacherClassData.isEmpty) {
        classes.clear();
        filteredClasses.clear();
        return;
      }

      final subjectIds = teacherClassData
          .map((classData) => classData['subject_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final courseIds = teacherClassData
          .map((classData) => classData['course_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final subjectRows = subjectIds.isEmpty
          ? <dynamic>[]
          : await Supabase.instance.client
              .from('subjects')
              .select('id, name')
              .inFilter('id', subjectIds);
      final courseRows = courseIds.isEmpty
          ? <dynamic>[]
          : await Supabase.instance.client
              .from('courses')
              .select('id, name')
              .inFilter('id', courseIds);

      final subjectNames = {
        for (final row in subjectRows) row['id'] as String: row['name'] as String?,
      };
      final courseNames = {
        for (final row in courseRows) row['id'] as String: row['name'] as String?,
      };

      final teacherClasses = teacherClassData.map((classData) {
        return ClassModel(
          id: classData['id'],
          teacherId: classData['teacher_id'],
          subjectId: classData['subject_id'],
          courseId: classData['course_id'],
          semester: classData['semester'],
          section: classData['section'],
          subjectName: subjectNames[classData['subject_id']],
          courseName: courseNames[classData['course_id']],
          createdAt: classData['created_at'] != null
              ? DateTime.parse(classData['created_at'])
              : null,
          updatedAt: classData['updated_at'] != null
              ? DateTime.parse(classData['updated_at'])
              : null,
        );
      }).toList()
        ..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

      // Update classes list - this will automatically update the UI
      classes.assignAll(teacherClasses);
      _classesOffset = classes.length;
      hasMoreClasses.value = teacherClasses.length >= _teacherClassFetchLimit;
      
      // Update filtered classes based on current search
      if (searchQuery.value.isNotEmpty) {
        _filterClasses(searchQuery.value);
      } else {
        filteredClasses.assignAll(teacherClasses);
      }

      debugPrint('ClassController classes updated via real-time: ${teacherClasses.length} classes');
      
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling classes update in ClassController: $e');
    }
  }

  // Handle real-time subjects updates to update dropdown UI
  void _handleSubjectsUpdate(List<Map<String, dynamic>> data) {
    try {
      final subjectsList = data.map((json) => SubjectModel.fromJson(json)).toList();
      subjects.assignAll(subjectsList); // This will update the UI automatically
      
      // Update selected subject if it still exists
      if (selectedSubject.value != null) {
        final currentSubjectId = selectedSubject.value.id;
        final updatedSubject = subjectsList.firstWhereOrNull(
          (subject) => subject.id == currentSubjectId,
        );
        if (updatedSubject != null) {
          selectedSubject.value = updatedSubject;
        }
      }

      debugPrint('ClassController subjects updated via real-time: ${subjectsList.length} subjects');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling subjects update in ClassController: $e');
    }
  }

  // Handle real-time courses updates to update dropdown UI
  void _handleCoursesUpdate(List<Map<String, dynamic>> data) {
    try {
      final coursesList = data.map((json) => CourseModel.fromJson(json)).toList();
      courses.assignAll(coursesList); // This will update the UI automatically
      
      // Update selected course if it still exists
      if (selectedCourse.value != null) {
        final currentCourseId = selectedCourse.value!.id;
        final updatedCourse = coursesList.firstWhereOrNull(
          (course) => course.id == currentCourseId,
        );
        if (updatedCourse != null) {
          selectedCourse.value = updatedCourse;
        }
      }

      debugPrint('ClassController courses updated via real-time: ${coursesList.length} courses');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error handling courses update in ClassController: $e');
    }
  }

  // Filter classes based on search query
  void _filterClasses(String query) {
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      filteredClasses.assignAll(classes);
    } else {
      filteredClasses.assignAll(
        classes.where((classModel) {
          final matchesSubject =
              classModel.subjectName?.toLowerCase().contains(query) ?? false;
          final matchesCourse =
              classModel.courseName?.toLowerCase().contains(query) ?? false;
          final matchesSection =
              classModel.section?.toLowerCase().contains(query) ?? false;

          return matchesSubject || matchesCourse || matchesSection;
        }).toList(),
      );
    }
  }

  // Search classes method
  void searchClasses(String query) {
    _filterClasses(query);
  }

  // Load all classes for the current teacher (initial load)
  Future<void> loadClasses() async {
    await loadClassesPage(reset: true);
  }

  Future<void> loadClassesPage({bool reset = false}) async {
    try {
      debugPrint('Loading classes...');
      if (reset) {
        isLoading.value = true;
        _classesOffset = 0;
        hasMoreClasses.value = true;
      } else {
        if (isLoading.value || isLoadingMore.value || !hasMoreClasses.value) {
          return;
        }
        isLoadingMore.value = true;
      }

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user logged in');
        TSnackBar.showError(message: 'You must be logged in to view classes');
        return;
      }

      final teacherClasses = await classService.getTeacherClasses(
        currentUser.id,
        limit: _teacherClassFetchLimit,
        offset: _classesOffset,
      );

      debugPrint('Classes loaded: ${teacherClasses.length}');
      if (reset) {
        classes.assignAll(teacherClasses);
      } else {
        classes.addAll(teacherClasses);
      }
      _classesOffset = classes.length;
      hasMoreClasses.value = teacherClasses.length == _teacherClassFetchLimit;
      _filterClasses(searchQuery.value);
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading classes: $e');
      TSnackBar.showError(message: 'Failed to load classes: ${e.toString()}');
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMoreClasses() async {
    await loadClassesPage();
  }

  // Load courses and subjects for dropdowns (initial load)
  Future<void> loadCoursesAndSubjects() async {
    try {
      debugPrint('Loading courses and subjects...');
      
      final allCourses = await courseService.getAllCourses();
      final allSubjects = await subjectService.getAllSubjects();

      debugPrint('Courses loaded: ${allCourses.length}');
      debugPrint('Subjects loaded: ${allSubjects.length}');

      courses.assignAll(allCourses);
      subjects.assignAll(allSubjects);

      // Set default selections if available
      if (courses.isNotEmpty && selectedCourse.value == null) {
        selectedCourseId.value = courses[0].id;
        selectedCourse.value = courses[0];
        debugPrint('Default course selected: ${courses[0].name}');
      }

      if (subjects.isNotEmpty && selectedSubject.value == null) {
        selectedSubjectId.value = subjects[0].id;
        selectedSubject.value = subjects[0];
        debugPrint('Default subject selected: ${subjects[0].name}');
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error loading courses and subjects: $e');
      TSnackBar.showError(
        message: 'Failed to load courses and subjects: ${e.toString()}',
      );
    }
  }

  // Create a new class
  Future<void> createClass() async {
    try {
      debugPrint('Creating class...');
      if (selectedSubject.value == null ||
          selectedCourse.value == null ||
          semesterController.text.trim().isEmpty) {
        debugPrint('Validation Failed');
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }
      debugPrint('Validation Passed');
      isLoading.value = true;

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('User not logged in');
        TSnackBar.showError(message: 'You must be logged in to create a class');
        return;
      }

      // Check for existing class with same parameters
      final semester = int.parse(semesterController.text.trim());
      final section = sectionController.text.trim().isNotEmpty
          ? sectionController.text.trim()
          : null;

      // Check if a similar class already exists
      bool duplicateExists = false;
      for (var existingClass in classes) {
        if (existingClass.courseId == selectedCourse.value!.id &&
            existingClass.subjectId == selectedSubject.value.id &&
            existingClass.semester == semester &&
            (section == null && existingClass.section == null ||
                section != null &&
                    existingClass.section != null &&
                    existingClass.section!.toLowerCase() ==
                        section.toLowerCase())) {
          duplicateExists = true;
          break;
        }
      }

      if (duplicateExists) {
        TSnackBar.showError(
          message:
              'A class with these details already exists. Please check the section name.',
          title: 'Duplicate Class',
        );
        isLoading.value = false;
        return;
      }

      debugPrint('Creating Class ...');

      final newClass = await classService.createClass(
        teacherId: currentUser.id,
        subjectId: selectedSubject.value.id,
        courseId: selectedCourse.value!.id,
        semester: semester,
        section: section,
      );
      
      debugPrint('Class created: ${newClass.subjectName}');
      
      // Note: The real-time subscription will automatically update the UI
      // No need to manually add to the list here - the stream will handle it
      
      // Reset form
      semesterController.clear();
      sectionController.clear();

      TSnackBar.showSuccess(message: 'Class created successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to create class: $e');
      TSnackBar.showError(message: 'Failed to create class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing class
  Future<void> updateClass(String classId) async {
    try {
           debugPrint('Updating class with ID: $classId');
      if (selectedSubjectId.value.isEmpty ||
          selectedCourseId.value.isEmpty ||
          semesterController.text.trim().isEmpty) {
        debugPrint('Validation Failed');
        TSnackBar.showError(message: 'Please fill in all required fields');
        return;
      }

      isLoading.value = true;

      final updatedClass = await classService.updateClass(
        classId: classId,
        subjectId: selectedSubjectId.value,
        courseId: selectedCourseId.value,
        semester: int.parse(semesterController.text.trim()),
        section: sectionController.text.trim().isNotEmpty
            ? sectionController.text.trim()
            : null,
      );

      debugPrint('Class updated: ${updatedClass.subjectName}');
      
      // Note: The real-time subscription will automatically update the UI
      // No need to manually update the list here - the stream will handle it

      TSnackBar.showSuccess(message: 'Class updated successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to update class: $e');
      TSnackBar.showError(message: 'Failed to update class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      debugPrint('Deleting class with ID: $classId');
      isLoading.value = true;

      await classService.deleteClass(classId);

      debugPrint('Class deleted successfully');
      
      // Note: The real-time subscription will automatically update the UI
      // No need to manually remove from the list here - the stream will handle it
      
      TSnackBar.showSuccess(message: 'Class deleted successfully');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to delete class: $e');
      TSnackBar.showError(message: 'Failed to delete class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete selected classes
  Future<void> deleteSelectedClasses() async {
    try {
      isLoading.value = true;

      // Create a copy to avoid modification during iteration
      final classesToDelete = Set<String>.from(selectedClassIds);

      for (var classId in classesToDelete) {
        await classService.deleteClass(classId);
      }

      // Exit selection mode
      isSelectionMode.value = false;
      clearSelections();

      // Show success message
      final count = classesToDelete.length;
      TSnackBar.showSuccess(
        message:
            '$count ${count == 1 ? 'class' : 'classes'} deleted successfully',
        title: 'Success',
      );
      
      // Note: The real-time subscription will automatically update the UI
      // No need to manually remove from the list here - the stream will handle it
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Error deleting selected classes: $e');
      TSnackBar.showError(message: 'Failed to delete classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to validate the class form
  bool validateClassForm() {
    debugPrint('Validating class form...');
    if (selectedSubjectId.value.isEmpty ||
        selectedCourseId.value.isEmpty ||
        semesterController.text.isEmpty) {
      debugPrint('Validation Failed');
      Get.snackbar(TTexts.error, TTexts.fillCorrect);
      return false;
    }
    debugPrint('Validation Passed');
    return true;
  }

  // Load a class for editing
  void loadClassForEditing(ClassModel classModel) {
    debugPrint('Loading class for editing: ${classModel.subjectName}');
    selectedSubjectId.value = classModel.subjectId;
    selectedCourseId.value = classModel.courseId;
    semesterController.text = classModel.semester.toString();
    sectionController.text = classModel.section ?? '';
    
    // Set selected objects
    selectedSubject.value = subjects.firstWhereOrNull(
      (subject) => subject.id == classModel.subjectId,
    );
    selectedCourse.value = courses.firstWhereOrNull(
      (course) => course.id == classModel.courseId,
    );
  }

  // Multi-select functionality methods
  void toggleSelectionMode(String? initialClassId) {
    isSelectionMode.value = !isSelectionMode.value;

    if (!isSelectionMode.value) {
      // Clear selections when exiting selection mode
      clearSelections();
    } else if (initialClassId != null) {
      // If entering selection mode with an initial selection
      selectedClassIds.add(initialClassId);
    }
  }

  void toggleClassSelection(String classId) {
    if (selectedClassIds.contains(classId)) {
      selectedClassIds.remove(classId);
      // If no classes are selected, exit selection mode
      if (selectedClassIds.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      selectedClassIds.add(classId);
    }

    // Update "all selected" state
    isAllSelected.value = selectedClassIds.length == classes.length;
  }

  void toggleSelectAll() {
    if (isAllSelected.value) {
      // Deselect all
      selectedClassIds.clear();
      isSelectionMode.value = false;
    } else {
      // Select all
      selectedClassIds.clear();
      for (var classItem in classes) {
        selectedClassIds.add(classItem.id);
      }
    }
    isAllSelected.value = !isAllSelected.value;
  }

  void clearSelections() {
    selectedClassIds.clear();
    isAllSelected.value = false;
  }

  // Get connection status string for UI display
  String getConnectionStatus() {
    if (!isRealtimeConnected.value) {
      return 'Disconnected';
    }
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated.value);
    
    if (difference.inSeconds < 30) {
      return 'Live';
    } else if (difference.inSeconds < 60) {
      return 'Updated ${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else {
      return 'Updated ${difference.inHours}h ago';
    }
  }

  // Reconnect to real-time service
  Future<void> reconnectRealtime() async {
    try {
      debugPrint('Attempting to reconnect to real-time service from ClassController...');
      await realtimeService.forceReconnect();
      debugPrint('Successfully reconnected to real-time service');
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
      debugPrint('Failed to reconnect to real-time service: $e');
    }
  }
}
