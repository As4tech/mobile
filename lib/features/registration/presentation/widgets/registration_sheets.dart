import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../super_admin/data/super_admin_models.dart';
import '../../data/csv_parser.dart';
import '../../data/registration_models.dart';
import '../../data/registration_repository.dart';

enum BulkKind { region, school, student }

/// Shared scaffold for a registration modal (bottom sheet): drag handle,
/// title, scrollable form body and a full-width submit button.
class RegistrationSheet extends StatefulWidget {
  const RegistrationSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final IconData icon;
  final List<Widget> fields;
  final String submitLabel;
  final Future<String?> Function() onSubmit;

  @override
  State<RegistrationSheet> createState() => _RegistrationSheetState();
}

class _RegistrationSheetState extends State<RegistrationSheet> {
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final error = await widget.onSubmit();
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 22, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.headingText(context)
                          .copyWith(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.fields,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: _submitting
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.surfaceLight,
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surfaceLight,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(widget.submitLabel),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'] as String;
    }
    return error.message ?? 'Request failed.';
  }
  return error.toString();
}

String? _nullable(String? value) {
  final t = value?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

String? Function(String?) _required(String label) =>
    (String? v) =>
        (v == null || v.trim().isEmpty) ? '$label is required' : null;

String? _optionalEmail(String? value) {
  final v = _nullable(value);
  if (v == null) return null;
  return v.contains('@') ? null : 'Enter a valid email';
}

(String, String) _splitName(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.last);
}

const _fieldGap = SizedBox(height: AppSpacing.md);

Widget _formField(
  BuildContext context,
  TextEditingController controller,
  String label, {
  String? hint,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: AppTypography.bodyText(context)
          .copyWith(color: AppColors.textMuted, fontSize: 13),
    ),
  );
}

Future<bool> _openSheet(BuildContext context, RegistrationSheet sheet) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: sheet,
      ),
    ),
  );
  return result ?? false;
}

void _showImportResult(
  BuildContext context,
  ImportResult result,
  String label,
) {
  final visibleErrors = result.errors.take(6).toList();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        result.errors.isEmpty ? 'Import successful' : 'Import completed',
        style: AppTypography.titleText(dialogContext),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result.imported} $label imported.',
              style: AppTypography.bodyText(dialogContext),
            ),
            if (visibleErrors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${result.errors.length} row(s) skipped:',
                style: AppTypography.labelText(dialogContext)
                    .copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final err in visibleErrors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Row ${err.index + 1}: ${err.message}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelText(dialogContext)
                        .copyWith(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              if (result.errors.length > visibleErrors.length)
                Text(
                  '…and ${result.errors.length - visibleErrors.length} more.',
                  style: AppTypography.labelText(dialogContext)
                      .copyWith(color: AppColors.textMuted, fontSize: 12),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

DropdownButtonFormField<String> _stringDropdown({
  String? value,
  required String label,
  required List<(String, String)> options,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: options
        .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
        .toList(),
    onChanged: onChanged,
  );
}

// ---------------------------------------------------------------------------
// Region form
// ---------------------------------------------------------------------------

Future<bool> showRegionForm(
  BuildContext context,
  RegistrationRepository repo, {
  Region? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final code = TextEditingController(text: existing?.code ?? '');

  final saved = await _openSheet(
    context,
    RegistrationSheet(
      title: existing == null ? 'Register Region' : 'Edit Region',
      icon: Icons.map_outlined,
      submitLabel: existing == null ? 'Create Region' : 'Save Changes',
      fields: [
        _formField(
          context,
          name,
          'Region name *',
          hint: 'e.g. Greater Accra',
          validator: _required('Region name'),
        ),
        _fieldGap,
        _formField(context, code, 'Code', hint: 'e.g. GA'),
      ],
      onSubmit: () async {
        try {
          if (existing == null) {
            await repo.createRegion(
              name: name.text.trim(),
              code: _nullable(code.text),
            );
          } else {
            await repo.updateRegion(
              id: existing.id,
              name: name.text.trim(),
              code: _nullable(code.text),
            );
          }
          return null;
        } catch (e) {
          return _errorMessage(e);
        }
      },
    ),
  );

  return saved;
}

// ---------------------------------------------------------------------------
// School form
// ---------------------------------------------------------------------------

Future<bool> showSchoolForm(
  BuildContext context,
  RegistrationRepository repo, {
  required List<Region> regions,
}) async {
  final name = TextEditingController();
  final code = TextEditingController();
  final district = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  String? region;

  final saved = await _openSheet(
    context,
    RegistrationSheet(
      title: 'Register School',
      icon: Icons.school_outlined,
      submitLabel: 'Create School',
      fields: [
        _formField(
          context,
          name,
          'School name *',
          validator: _required('School name'),
        ),
        _fieldGap,
        _formField(
          context,
          code,
          'School code *',
          hint: 'e.g. BRIGHT',
          validator: _required('School code'),
        ),
        _fieldGap,
        _stringDropdown(
          value: region,
          label: 'Region',
          options: regions.map((r) => (r.name, r.name)).toList(),
          onChanged: (v) => region = v,
        ),
        _fieldGap,
        _formField(context, district, 'District'),
        _fieldGap,
        _formField(context, address, 'Address'),
        _fieldGap,
        _formField(
          context,
          email,
          'Contact email',
          keyboardType: TextInputType.emailAddress,
          validator: _optionalEmail,
        ),
        _fieldGap,
        _formField(context, phone, 'Contact phone'),
      ],
      onSubmit: () async {
        try {
          await repo.createSchool(
            name: name.text.trim(),
            code: code.text.trim(),
            region: region,
            district: _nullable(district.text),
            contactEmail: _nullable(email.text),
            contactPhone: _nullable(phone.text),
            address: _nullable(address.text),
          );
          return null;
        } catch (e) {
          return _errorMessage(e);
        }
      },
    ),
  );

  return saved;
}

// ---------------------------------------------------------------------------
// Student form
// ---------------------------------------------------------------------------

Future<bool> showStudentForm(
  BuildContext context,
  RegistrationRepository repo, {
  required bool pickSchool,
  List<SchoolListItem>? schools,
  StudentRecord? existing,
}) async {
  final admission = TextEditingController(
    text: existing?.admissionNumber ?? '',
  );
  final firstName = TextEditingController(
    text: _splitName(existing?.fullName ?? '').$1,
  );
  final lastName = TextEditingController(
    text: _splitName(existing?.fullName ?? '').$2,
  );
  final middleName = TextEditingController();
  final className = TextEditingController(text: existing?.className ?? '');
  final guardianName = TextEditingController(
    text: existing?.guardianName ?? '',
  );
  final guardianPhone = TextEditingController();
  int? schoolId;

  final saved = await _openSheet(
    context,
    RegistrationSheet(
      title: existing == null ? 'Register Student' : 'Edit Student',
      icon: Icons.person_add_alt,
      submitLabel: existing == null ? 'Create Student' : 'Save Changes',
      fields: [
        if (pickSchool && existing == null) ...[
          _schoolDropdown(
            value: schoolId,
            schools: schools,
            onChanged: (v) => schoolId = v,
          ),
          _fieldGap,
        ],
        _formField(
          context,
          admission,
          'Admission number *',
          validator: _required('Admission number'),
        ),
        _fieldGap,
        _formField(
          context,
          firstName,
          'First name *',
          validator: _required('First name'),
        ),
        _fieldGap,
        _formField(
          context,
          lastName,
          'Last name *',
          validator: _required('Last name'),
        ),
        _fieldGap,
        _formField(context, middleName, 'Middle name'),
        _fieldGap,
        _formField(context, className, 'Class'),
        _fieldGap,
        _formField(context, guardianName, 'Guardian name'),
        _fieldGap,
        _formField(
          context,
          guardianPhone,
          'Guardian phone',
          keyboardType: TextInputType.phone,
        ),
      ],
      onSubmit: () async {
        if (pickSchool && existing == null && schoolId == null) {
          return 'Please select a school.';
        }
        try {
          if (existing == null) {
            await repo.createStudent(
              schoolId: schoolId,
              admissionNumber: admission.text.trim(),
              firstName: _nullable(firstName.text),
              lastName: _nullable(lastName.text),
              middleName: _nullable(middleName.text),
              className: _nullable(className.text),
              guardianName: _nullable(guardianName.text),
              guardianPhone: _nullable(guardianPhone.text),
            );
          } else {
            await repo.updateStudent(
              id: existing.id,
              admissionNumber: admission.text.trim(),
              firstName: _nullable(firstName.text),
              lastName: _nullable(lastName.text),
              middleName: _nullable(middleName.text),
              className: _nullable(className.text),
              guardianName: _nullable(guardianName.text),
              guardianPhone: _nullable(guardianPhone.text),
            );
          }
          return null;
        } catch (e) {
          return _errorMessage(e);
        }
      },
    ),
  );

  return saved;
}

// ---------------------------------------------------------------------------
// School user form
// ---------------------------------------------------------------------------

Future<bool> showSchoolUserForm(
  BuildContext context,
  RegistrationRepository repo, {
  SchoolUserRecord? existing,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final email = TextEditingController(text: existing?.email ?? '');
  final phone = TextEditingController(text: existing?.phone ?? '');
  final password = TextEditingController();
  String? role = existing?.role ?? 'school_admin';

  final saved = await _openSheet(
    context,
    RegistrationSheet(
      title: existing == null ? 'Register User' : 'Edit User',
      icon: Icons.group_add_outlined,
      submitLabel: existing == null ? 'Create User' : 'Save Changes',
      fields: [
        _formField(
          context,
          name,
          'Full name *',
          validator: _required('Full name'),
        ),
        _fieldGap,
        _formField(
          context,
          email,
          'Email *',
          keyboardType: TextInputType.emailAddress,
          validator: _optionalEmail,
        ),
        _fieldGap,
        _stringDropdown(
          value: role,
          label: 'Role *',
          options: const [
            ('school_admin', 'PTA Chairman / Admin'),
            ('finance', 'Secretary / Finance'),
            ('staff', 'Staff'),
          ],
          onChanged: (v) => role = v,
        ),
        _fieldGap,
        _formField(context, phone, 'Phone'),
        _fieldGap,
        _formField(
          context,
          password,
          'Password',
          hint: existing == null
              ? 'Defaults to "password"'
              : 'Leave blank to keep current',
        ),
      ],
      onSubmit: () async {
        try {
          if (existing == null) {
            await repo.createSchoolUser(
              name: name.text.trim(),
              email: email.text.trim(),
              role: role ?? 'school_admin',
              phone: _nullable(phone.text),
              password: _nullable(password.text),
            );
          } else {
            await repo.updateSchoolUser(
              id: existing.id,
              name: name.text.trim(),
              email: email.text.trim(),
              phone: _nullable(phone.text),
              password: _nullable(password.text),
            );
          }
          return null;
        } catch (e) {
          return _errorMessage(e);
        }
      },
    ),
  );

  return saved;
}

// ---------------------------------------------------------------------------
// Bulk upload
// ---------------------------------------------------------------------------

String _pluralLabel(BulkKind kind) => switch (kind) {
  BulkKind.region => 'Regions',
  BulkKind.school => 'Schools',
  BulkKind.student => 'Students',
};

String _template(BulkKind kind) => switch (kind) {
  BulkKind.region => 'name,code\nGreater Accra,GA\nAshanti,AH',
  BulkKind.school => 'name,code,region,district,contact_email,contact_phone,address\nSt Mary\'s School,SMSM,Ashanti,Kumasi,info@stmarys.edu,0241000000,High Street',
  BulkKind.student => 'admission_number,first_name,last_name,middle_name,class_name,guardian_name,guardian_phone,parent_name,parent_phone,parent_email\nADM001,Kwame,Mensah,Kojo,1A,Kojo Mensah,0241111111,Kojo Mensah,0241111111,kojo@example.com',
};

List<String> _expectedHeaders(BulkKind kind) => switch (kind) {
  BulkKind.region => const ['name', 'code'],
  BulkKind.school => const [
    'name',
    'code',
    'region',
    'district',
    'contact_email',
    'contact_phone',
    'address',
  ],
  BulkKind.student => const [
    'admission_number',
    'first_name',
    'last_name',
    'class_name',
    'guardian_name',
    'guardian_phone',
    'parent_name',
    'parent_phone',
  ],
};

Future<bool> showBulkUploadSheet(
  BuildContext context,
  RegistrationRepository repo, {
  required BulkKind kind,
  required bool pickSchool,
  List<SchoolListItem>? schools,
}) async {
  final csv = TextEditingController(text: _template(kind));
  int? schoolId;

  final saved = await _openSheet(
    context,
    RegistrationSheet(
      title: 'Bulk Upload ${_pluralLabel(kind)}',
      icon: Icons.upload_file_outlined,
      submitLabel: 'Upload',
      fields: [
        if (pickSchool) ...[
          _schoolDropdown(
            value: schoolId,
            schools: schools,
            onChanged: (v) => schoolId = v,
          ),
          _fieldGap,
        ],
        Text(
          'Paste CSV rows below. The first row must be the column headers.',
          style: AppTypography.bodyText(context)
              .copyWith(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Expected columns: ${_expectedHeaders(kind).join(', ')}',
          style: AppTypography.labelText(context)
              .copyWith(color: AppColors.textSecondary, fontSize: 12),
        ),
        _fieldGap,
        TextField(
          controller: csv,
          maxLines: 12,
          minLines: 8,
          style: AppTypography.bodyText(context).copyWith(fontSize: 13),
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            hintText: 'Paste your CSV here...',
          ),
        ),
      ],
      onSubmit: () async {
        if (pickSchool && schoolId == null) {
          return 'Please select a school.';
        }
        try {
          final rows = CsvParser.parse(csv.text);
          if (rows.isEmpty) return 'No data rows found in the CSV.';

          final result = switch (kind) {
            BulkKind.region => await repo.importRegions(_regionRows(rows)),
            BulkKind.school => await repo.importSchools(_schoolRows(rows)),
            BulkKind.student => await repo.importStudents(
              schoolId: schoolId,
              rows: _studentRows(rows),
            ),
          };

          if (context.mounted) {
            _showImportResult(
              context,
              result,
              _pluralLabel(kind).toLowerCase(),
            );
          }
          return null;
        } catch (e) {
          return _errorMessage(e);
        }
      },
    ),
  );

  return saved;
}

Widget _schoolDropdown({
  required int? value,
  required List<SchoolListItem>? schools,
  required void Function(int?) onChanged,
}) {
  return DropdownButtonFormField<int>(
    initialValue: value,
    decoration: const InputDecoration(labelText: 'School *'),
    items: (schools ?? const <SchoolListItem>[])
        .map(
          (s) => DropdownMenuItem(
            value: s.id,
            child: Text('${s.name} (${s.code})'),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}

List<Map<String, dynamic>> _regionRows(List<Map<String, String>> rows) {
  return rows.map((r) {
    final name = _nullable(r['name']);
    final code = _nullable(r['code']);
    return {'name': ?name, 'code': ?code};
  }).toList();
}

List<Map<String, dynamic>> _schoolRows(List<Map<String, String>> rows) {
  return rows.map((r) {
    final region = _nullable(r['region']);
    final district = _nullable(r['district']);
    final email = _nullable(r['contact_email']);
    final phone = _nullable(r['contact_phone']);
    final address = _nullable(r['address']);
    return {
      'name': r['name'] ?? '',
      'code': r['code'] ?? '',
      'region': ?region,
      'district': ?district,
      'contact_email': ?email,
      'contact_phone': ?phone,
      'address': ?address,
    };
  }).toList();
}

List<Map<String, dynamic>> _studentRows(List<Map<String, String>> rows) {
  return rows.map((r) {
    String? str(String key) => _nullable(r[key]);

    final parentName = str('parent_name') ?? str('guardian_name');
    final parentPhone = str('parent_phone') ?? str('guardian_phone');
    final parentEmail = str('parent_email');
    final parentRelationship = str('parent_relationship');

    return {
      'admission_number': r['admission_number'] ?? '',
      'first_name': ?str('first_name'),
      'last_name': ?str('last_name'),
      'middle_name': ?str('middle_name'),
      'class_name': ?str('class_name'),
      if (parentName != null || parentPhone != null || parentEmail != null)
        'parent': {
          'name': ?parentName,
          'phone': ?parentPhone,
          'email': ?parentEmail,
          'relationship': ?parentRelationship,
        },
    };
  }).toList();
}
