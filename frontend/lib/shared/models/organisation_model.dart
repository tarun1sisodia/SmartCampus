import 'package:equatable/equatable.dart';

class OrganisationModel extends Equatable {
  final String id;
  final String name;
  final String type; // 'school', 'college'
  final String? domain;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final String status; // 'active', 'suspended', 'trial'

  const OrganisationModel({
    required this.id,
    required this.name,
    required this.type,
    this.domain,
    this.address,
    this.contactEmail,
    this.contactPhone,
    required this.status,
  });

  factory OrganisationModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeJson(json);
    return OrganisationModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      type: normalized['type'] as String,
      domain: normalized['domain'] as String?,
      address: normalized['address'] as String?,
      contactEmail: normalized['contactEmail'] as String?,
      contactPhone: normalized['contactPhone'] as String?,
      status: normalized['status'] as String? ?? 'trial',
    );
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'id': (json['id'] ?? json['_id'] ?? '').toString(),
      'contactEmail': json['contactEmail'] ?? json['email'] ?? json['contact_email'],
      'contactPhone': json['contactPhone'] ?? json['phone'] ?? json['contact_phone'],
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'domain': domain,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, name, type, domain, address, contactEmail, contactPhone, status];
}
