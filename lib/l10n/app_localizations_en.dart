// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FoxApply';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get createPackage => 'Create Application Package';

  @override
  String get generateNow => 'Generate Package';

  @override
  String get preview => 'Preview';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get personalData => 'Personal Data';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get photo => 'Photo';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseGallery => 'Choose from Gallery';

  @override
  String get education => 'Education';

  @override
  String get addEducation => 'Add Education';

  @override
  String get institution => 'Institution';

  @override
  String get degree => 'Degree';

  @override
  String get major => 'Major';

  @override
  String get graduationYear => 'Graduation Year';

  @override
  String get gpa => 'GPA';

  @override
  String get experience => 'Work Experience';

  @override
  String get addExperience => 'Add Experience';

  @override
  String get company => 'Company';

  @override
  String get position => 'Position';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get currentlyWorking => 'Currently working here';

  @override
  String get jobDescription => 'Job Description';

  @override
  String get skills => 'Skills';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get skillName => 'Skill Name';

  @override
  String get skillLevel => 'Skill Level';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get expert => 'Expert';

  @override
  String get cvBuilder => 'CV Builder';

  @override
  String get cvPreview => 'CV Preview';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get template1 => 'Modern';

  @override
  String get template2 => 'Professional';

  @override
  String get template3 => 'Creative';

  @override
  String get coverLetter => 'Cover Letter';

  @override
  String get coverLetterBuilder => 'Cover Letter Builder';

  @override
  String get targetPosition => 'Target Position';

  @override
  String get targetCompany => 'Target Company';

  @override
  String get letterDate => 'Letter Date';

  @override
  String get letterContent => 'Letter Content';

  @override
  String get generateLetter => 'Generate Letter';

  @override
  String get scanner => 'Document Scanner';

  @override
  String get scanDocument => 'Scan Document';

  @override
  String get scanNew => 'Scan New Document';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Use This Photo';

  @override
  String get cropAdjust => 'Adjust Crop';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterBW => 'Black & White';

  @override
  String get filterEnhanced => 'Enhanced';

  @override
  String get scannedDocs => 'Scanned Documents';

  @override
  String get addDocument => 'Add Document';

  @override
  String get reorderDocs => 'Reorder Documents';

  @override
  String get pdfManager => 'PDF Manager';

  @override
  String get mergedPDF => 'Merged PDF';

  @override
  String pageCount(int count) {
    return '$count pages';
  }

  @override
  String get finalPackage => 'Final Package';

  @override
  String get packageReady => 'Your package is ready!';

  @override
  String get generating => 'Generating your package...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorEmail => 'Please enter a valid email';

  @override
  String get errorPhone => 'Please enter a valid phone number';

  @override
  String get errorNoPhoto => 'Please upload a photo first';

  @override
  String get errorNoDocs => 'Please scan at least one document';

  @override
  String get successGenerated => 'Package generated successfully!';

  @override
  String get successSaved => 'Saved successfully!';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get profileSection => 'Profile';

  @override
  String get jobSection => 'Job Details';

  @override
  String get docsSection => 'Documents';

  @override
  String get outputSection => 'Output';

  @override
  String step(int current, int total) {
    return 'Step $current of $total';
  }
}
