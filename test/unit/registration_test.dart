import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/features/registration/data/csv_parser.dart';
import 'package:ptacollect_mobile/features/registration/data/registration_models.dart';

void main() {
  group('CsvParser', () {
    test('parses basic rows into header-keyed maps', () {
      final rows = CsvParser.parse('name,code\nGreater Accra,GA\nAshanti,AH');
      expect(rows.length, 2);
      expect(rows[0]['name'], 'Greater Accra');
      expect(rows[0]['code'], 'GA');
      expect(rows[1]['name'], 'Ashanti');
      expect(rows[1]['code'], 'AH');
    });

    test('normalizes headers to lower-snake-case', () {
      final rows = CsvParser.parse('Admission Number,First Name\nADM1,Kofi');
      expect(rows.single['admission_number'], 'ADM1');
      expect(rows.single['first_name'], 'Kofi');
    });

    test('handles quoted fields containing commas', () {
      final rows = CsvParser.parse(
        'school,city\n"St. Mary\'s, Model School",Kumasi',
      );
      expect(rows.single['school'], "St. Mary's, Model School");
      expect(rows.single['city'], 'Kumasi');
    });

    test('handles escaped double quotes in quoted fields', () {
      final rows = CsvParser.parse('note\n"said ""hello"" today"');
      expect(rows.single['note'], 'said "hello" today');
    });

    test('drops empty rows and blank values', () {
      final rows = CsvParser.parse('name,code\n\nGreater Accra,\nKumasi,KAA\n');
      expect(rows.length, 2);
      expect(rows[0]['code'], isNull);
    });

    test('empty and header-only sources produce no data', () {
      expect(CsvParser.parse(''), isEmpty);
      expect(CsvParser.parse('name,code'), isEmpty);
    });
  });

  group('Region model', () {
    test('fromJson maps fields and defaults', () {
      final region = Region.fromJson({
        'id': 1,
        'name': 'Ashanti',
        'code': 'AH',
        'sort_order': 2,
      });
      expect(region.id, 1);
      expect(region.name, 'Ashanti');
      expect(region.code, 'AH');
      expect(region.sortOrder, 2);
    });

    test('fromJson tolerates missing optionals', () {
      final region = Region.fromJson({'id': 2, 'name': 'Greater Accra'});
      expect(region.code, isNull);
      expect(region.sortOrder, 0);
    });
  });

  group('StudentRecord model', () {
    test('fromJson maps all fields', () {
      final student = StudentRecord.fromJson({
        'id': 10,
        'full_name': 'Kwame Mensah',
        'admission_number': 'ADM001',
        'class_name': '1A',
        'guardian_name': 'Kojo Mensah',
        'status': 'active',
      });
      expect(student.id, 10);
      expect(student.fullName, 'Kwame Mensah');
      expect(student.admissionNumber, 'ADM001');
      expect(student.className, '1A');
      expect(student.guardianName, 'Kojo Mensah');
      expect(student.status, 'active');
    });
  });

  group('ImportResult model', () {
    test('fromJson maps imported count and errors', () {
      final result = ImportResult.fromJson({
        'imported': 3,
        'errors': [
          {'index': 3, 'message': 'Duplicate code'},
        ],
      });
      expect(result.imported, 3);
      expect(result.errors.length, 1);
      expect(result.errors.single.index, 3);
      expect(result.errors.single.message, 'Duplicate code');
    });

    test('fromJson defaults when slices missing', () {
      final result = ImportResult.fromJson({});
      expect(result.imported, 0);
      expect(result.errors, isEmpty);
    });
  });

  group('PaginatedRecords', () {
    test('fromJson parses data and meta, plain wraps a list', () {
      final paginated = PaginatedRecords.fromJson({
        'data': [
          {'id': 1, 'full_name': 'A', 'admission_number': 'A1'},
          {'id': 2, 'full_name': 'B', 'admission_number': 'B1'},
        ],
        'meta': {'current_page': 2, 'total': 10, 'last_page': 3},
      }, StudentRecord.fromJson);
      expect(paginated.data.length, 2);
      expect(paginated.currentPage, 2);
      expect(paginated.total, 10);
      expect(paginated.lastPage, 3);

      final plain = PaginatedRecords.plain(paginated.data);
      expect(plain.currentPage, 1);
      expect(plain.total, 2);
      expect(plain.lastPage, 1);
    });
  });
}
