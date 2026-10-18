import 'package:test/test.dart';

import '../service/lms_system.dart';

void main() {
  // ── Task 1: Courses ──────────────────────────────────────────────────────────

  group('courses', () {
    test('adds a course', () {
      final lms = LmsSystem();

      lms.addCourse('C1', 'Mobile Development');
      lms.addCourse('C2', 'Databases');

      expect(lms.courses.map((c) => c.id), ['C1', 'C2']);
    });

    test('rejects a duplicate course ID', () {
      final lms = LmsSystem();
      lms.addCourse('C1', 'Mobile Development');

      expect(
        () => lms.addCourse('C1', 'Another Name'),
        throwsException,
      );
    });

    test('rejects removal of a nonexistent course', () {
      final lms = LmsSystem();

      expect(() => lms.removeCourse('C1'), throwsException);
    });

    test('removes an unused course', () {
      final lms = LmsSystem();
      lms.addCourse('C1', 'Mobile Development');

      lms.removeCourse('C1');

      expect(lms.courses, isEmpty);
    });

    test('does not remove a course with enrollments or results', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(() => lms.removeCourse('C1'), throwsException);
    });
  });

  // ── Task 2: Enrollment ───────────────────────────────────────────────────────

  group('students and enrollment', () {
    test('adds and removes a student', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');

      lms.removeStudent(studentId: 'S1');

      expect(lms.students, isEmpty);
    });

    test('enrolls an existing student in an existing course', () {
      final lms = _systemWithStudentAndCourse();

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(lms.courses.single.studentIds, contains('S1'));
    });

    test('rejects enrollment if the student does not exist', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.enrollStudent(studentId: 'S2', courseId: 'C1'),
        throwsException,
      );
    });

    test('rejects enrollment if the course does not exist', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C2'),
        throwsException,
      );
    });

    test('rejects duplicate enrollment', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
        throwsException,
      );
    });

    // ── Task 3: Remove from course ─────────────────────────────────────────────

    test('discards an enrollment and removes its results', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.courses.single.studentIds, isEmpty);
      expect(lms.results, isEmpty);
    });

    test('verifies student and course still exist after enrollment is removed', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.students, hasLength(1));
      expect(lms.courses, hasLength(1));
    });

    test('rejects discarding a nonexistent enrollment', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1'),
        throwsException,
      );
    });

    test('removes enrollments from multiple courses when student is removed', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addCourse('C1', 'Mobile Development');
      lms.addCourse('C2', 'Databases');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');

      lms.removeStudent(studentId: 'S1');

      expect(lms.courses[0].studentIds, isEmpty);
      expect(lms.courses[1].studentIds, isEmpty);
    });
  });

  // ── Task 4 & 5: Results ──────────────────────────────────────────────────────

  group('results', () {
    test('adds a valid result', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      expect(lms.results.single.score, 85);
    });

    test('rejects a result for a nonexistent student', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.addResult(studentId: 'S99', courseId: 'C1', score: 85),
        throwsException,
      );
    });

    test('rejects a result for a nonexistent course', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C99', score: 85),
        throwsException,
      );
    });

    test('rejects a result if the student is not enrolled', () {
      final lms = _systemWithStudentAndCourse();

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 85),
        throwsException,
      );
    });

    test('rejects an invalid score', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 101),
        throwsArgumentError,
      );
    });

    test('allows only one result per student and course', () {
      final lms = _systemWithStudentAndCourse();
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 90),
        throwsException,
      );
    });

    test('removes a result without affecting other data', () {
      final lms = _systemWithStudentAndCourse();
      lms.addStudent(studentId: 'S2', studentName: 'Mina');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      lms.addResult(studentId: 'S2', courseId: 'C1', score: 90);

      lms.removeResult(resultId: 'S1_C1');

      // S1's result is gone; S2's result, students, and enrollments are untouched
      expect(lms.students, hasLength(2));
      expect(lms.courses.single.studentIds, containsAll(['S1', 'S2']));
      expect(lms.results.single.studentId, 'S2');
    });

    test('rejects removal of a nonexistent result', () {
      final lms = LmsSystem();

      expect(() => lms.removeResult(resultId: 'missing'), throwsException);
    });
  });

  // ── FR5 full scenario ────────────────────────────────────────────────────────

  test('removing a student cleans all enrollments and results', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'Ronan');
    lms.addStudent(studentId: 'S2', studentName: 'Mina');
    lms.addCourse('C1', 'Mobile Development');
    lms.addCourse('C2', 'Databases');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S1', courseId: 'C2');
    lms.enrollStudent(studentId: 'S2', courseId: 'C1');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
    lms.addResult(studentId: 'S1', courseId: 'C2', score: 80);
    lms.addResult(studentId: 'S2', courseId: 'C1', score: 90);

    lms.removeStudent(studentId: 'S1');

    expect(lms.students.map((s) => s.id), ['S2']);      // removed from students
    expect(lms.courses[0].studentIds, ['S2']);           // removed from C1
    expect(lms.courses[1].studentIds, isEmpty);          // removed from C2
    expect(lms.results.single.studentId, 'S2');         // only S2's result remains
  });
}

// ── Test helper ──────────────────────────────────────────────────────────────

// Creates a fresh LmsSystem already seeded with one student and one course,
// so individual tests don't repeat the same setup boilerplate.
LmsSystem _systemWithStudentAndCourse() {
  final lms = LmsSystem();
  lms.addStudent(studentId: 'S1', studentName: 'Ronan');
  lms.addCourse('C1', 'Mobile Development');
  return lms;
}
