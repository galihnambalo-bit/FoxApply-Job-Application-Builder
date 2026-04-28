// lib/data/models/user_profile.dart
import 'dart:convert';

class UserProfile {
  String fullName;
  String email;
  String phone;
  String address;
  String city;
  String postalCode;
  String? photoPath;
  List<Education> education;
  List<Experience> experience;
  List<Skill> skills;

  UserProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.postalCode = '',
    this.photoPath,
    List<Education>? education,
    List<Experience>? experience,
    List<Skill>? skills,
  })  : education = education ?? [],
        experience = experience ?? [],
        skills = skills ?? [];

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'photoPath': photoPath,
        'education': education.map((e) => e.toJson()).toList(),
        'experience': experience.map((e) => e.toJson()).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        postalCode: json['postalCode'] ?? '',
        photoPath: json['photoPath'],
        education: (json['education'] as List<dynamic>? ?? [])
            .map((e) => Education.fromJson(e))
            .toList(),
        experience: (json['experience'] as List<dynamic>? ?? [])
            .map((e) => Experience.fromJson(e))
            .toList(),
        skills: (json['skills'] as List<dynamic>? ?? [])
            .map((e) => Skill.fromJson(e))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());
  factory UserProfile.fromJsonString(String s) =>
      UserProfile.fromJson(jsonDecode(s));

  bool get isComplete =>
      fullName.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;
}

class Education {
  String id;
  String institution;
  String degree;
  String major;
  String graduationYear;
  String gpa;

  Education({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.major = '',
    this.graduationYear = '',
    this.gpa = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'major': major,
        'graduationYear': graduationYear,
        'gpa': gpa,
      };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        id: json['id'] ?? '',
        institution: json['institution'] ?? '',
        degree: json['degree'] ?? '',
        major: json['major'] ?? '',
        graduationYear: json['graduationYear'] ?? '',
        gpa: json['gpa'] ?? '',
      );
}

class Experience {
  String id;
  String company;
  String position;
  String startDate;
  String endDate;
  bool currentlyWorking;
  String description;

  Experience({
    required this.id,
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.currentlyWorking = false,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'position': position,
        'startDate': startDate,
        'endDate': endDate,
        'currentlyWorking': currentlyWorking,
        'description': description,
      };

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        id: json['id'] ?? '',
        company: json['company'] ?? '',
        position: json['position'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        currentlyWorking: json['currentlyWorking'] ?? false,
        description: json['description'] ?? '',
      );
}

class Skill {
  String id;
  String name;
  SkillLevel level;

  Skill({
    required this.id,
    this.name = '',
    this.level = SkillLevel.intermediate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level.index,
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        level: SkillLevel.values[json['level'] ?? 1],
      );
}

enum SkillLevel { beginner, intermediate, advanced, expert }

class JobApplication {
  String targetPosition;
  String targetCompany;
  String targetDepartment;
  String applicationDate;
  String customLetterContent;

  JobApplication({
    this.targetPosition = '',
    this.targetCompany = '',
    this.targetDepartment = '',
    String? applicationDate,
    this.customLetterContent = '',
  }) : applicationDate = applicationDate ??
            DateTime.now().toString().split(' ')[0];

  Map<String, dynamic> toJson() => {
        'targetPosition': targetPosition,
        'targetCompany': targetCompany,
        'targetDepartment': targetDepartment,
        'applicationDate': applicationDate,
        'customLetterContent': customLetterContent,
      };

  factory JobApplication.fromJson(Map<String, dynamic> json) => JobApplication(
        targetPosition: json['targetPosition'] ?? '',
        targetCompany: json['targetCompany'] ?? '',
        targetDepartment: json['targetDepartment'] ?? '',
        applicationDate: json['applicationDate'],
        customLetterContent: json['customLetterContent'] ?? '',
      );

  bool get isComplete =>
      targetPosition.isNotEmpty && targetCompany.isNotEmpty;
}

class ScannedDocument {
  String id;
  String imagePath;
  String name;
  DocumentFilter filter;
  int order;

  ScannedDocument({
    required this.id,
    required this.imagePath,
    this.name = '',
    this.filter = DocumentFilter.original,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'filter': filter.index,
        'order': order,
      };

  factory ScannedDocument.fromJson(Map<String, dynamic> json) =>
      ScannedDocument(
        id: json['id'] ?? '',
        imagePath: json['imagePath'] ?? '',
        name: json['name'] ?? '',
        filter: DocumentFilter.values[json['filter'] ?? 0],
        order: json['order'] ?? 0,
      );
}

enum DocumentFilter { original, blackAndWhite, enhanced }
