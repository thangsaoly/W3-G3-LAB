import '../model/student.dart';
import '../model/course.dart';
import '../model/course_result.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];

  //Task 1: Courses 

  // FR1: Create a course
  void addCourse(String courseId, String courseName) {
    if (_findCourseOrNull(courseId) != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(courseId, courseName));
  }

  // FR1: Remove a course
  void removeCourse(String courseId) {
    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.isNotEmpty ||
        results.any((r) => r.courseId == courseId)) {
      throw Exception(
        'Course $courseId cannot be removed: students are enrolled or results exist',
      );
    }
    courses.remove(course);
  }

  //Task 2: Add a student 

  void addStudent({required String studentId, required String studentName}) {
    if (_findStudentOrNull(studentId) != null) {
      throw Exception('Student $studentId already exists');
    }
    students.add(Student(id: studentId, name: studentName));
  }

  // FR5: Remove a student from the LMS
  void removeStudent({required String studentId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    students.removeWhere((s) => s.id == studentId);
    for (final course in courses) {
      course.studentIds.remove(studentId);
    }
    results.removeWhere((r) => r.studentId == studentId);
  }

  //Task 2: Enrollment

  // FR2: Enroll a student in a course

  void enrollStudent({
    required String studentId,
    required String courseId,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is already enrolled in $courseId');
    }
    course.studentIds.add(studentId);
  }

  //Task 3: Remove from course 

  // Remove a student from a specific course.

  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.remove(studentId)) {
      throw Exception(
        'Student $studentId is not enrolled in course $courseId',
      );
    }
    results.removeWhere(
      (r) => r.studentId == studentId && r.courseId == courseId,
    );
  }

  //Task 4: Results 

  // FR4: Record a score for a student in a course.

  void addResult({
    required String studentId,
    required String courseId,
    required int score,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }
    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }
    if (score < 0 || score > 100) {
      throw ArgumentError.value(score, 'score', 'must be between 0 and 100');
    }
    if (results.any((r) => r.studentId == studentId && r.courseId == courseId)) {
      throw Exception(
        'A result already exists for student $studentId in course $courseId',
      );
    }
    results.add(
      CourseResult(
        id: '${studentId}_$courseId',
        studentId: studentId,
        courseId: courseId,
        score: score,
      ),
    );
  }

  //Task 5: Remove a result 

  void removeResult({required String resultId}) {
    if (!results.any((r) => r.id == resultId)) {
      throw Exception('Result $resultId not found');
    }
    results.removeWhere((r) => r.id == resultId);
  }

  //Private helpers 

  Student? _findStudentOrNull(String studentId) {
    for (final s in students) {
      if (s.id == studentId) return s;
    }
    return null;
  }

  Course? _findCourseOrNull(String courseId) {
    for (final c in courses) {
      if (c.id == courseId) return c;
    }
    return null;
  }
}
