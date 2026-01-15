import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on track. Stay ON MAT.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterYourEmail;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailValidation;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterYourPassword;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidation;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or Sign In With'**
  String get orSignInWith;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your account'**
  String get signUp;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'first name is required'**
  String get firstNameRequired;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'last name is required'**
  String get lastNameRequired;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pleaseSelectUsername.
  ///
  /// In en, this message translates to:
  /// **'Please select your username'**
  String get pleaseSelectUsername;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I Agree To'**
  String get iAgreeTo;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySub.
  ///
  /// In en, this message translates to:
  /// **'Review how we handle your data'**
  String get privacyPolicySub;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or Sign Up With'**
  String get orSignUpWith;

  /// No description provided for @instructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructor;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email address!'**
  String get confirmEmail;

  /// No description provided for @confirmEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! Your Account Awaits: Verify Your Email to begin your martial arts journey. Whether you\'re an instructor sharing your expertise or a student sharpening your skills, this is your path to progress, discipline, and achievement.'**
  String get confirmEmailSubtitle;

  /// No description provided for @tContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get tContinue;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @yourAccountCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account successfully created!'**
  String get yourAccountCreatedTitle;

  /// No description provided for @yourAccountCreatedSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Martial Arts Hub is Ready! Dive in to connect with instructors, join training sessions, and elevate your skills — the dojo awaits!'**
  String get yourAccountCreatedSubTitle;

  /// No description provided for @signUpFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Failed'**
  String get signUpFailedTitle;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already associated with an existing account.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password.'**
  String get weakPassword;

  /// No description provided for @signUpFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during sign up. Please try again.'**
  String get signUpFailedMessage;

  /// No description provided for @emailNotVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerifiedTitle;

  /// No description provided for @emailNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and verify your email.'**
  String get emailNotVerifiedMessage;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification Email Sent'**
  String get verificationEmailSent;

  /// No description provided for @verificationEmailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox.'**
  String get verificationEmailSentMessage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorMessage;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invalid login credentials. Please double-check your email and password.'**
  String get userNotFound;

  /// No description provided for @userDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user has been disabled.'**
  String get userDisabled;

  /// No description provided for @signInFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get signInFailedTitle;

  /// No description provided for @signInFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login. Please try again.'**
  String get signInFailedMessage;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please enter your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @dateOfBirthValidation.
  ///
  /// In en, this message translates to:
  /// **'Format: DD/MM/YYYY'**
  String get dateOfBirthValidation;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @selectWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get selectWeight;

  /// No description provided for @weightValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get weightValidation;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @selectHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get selectHeight;

  /// No description provided for @heightValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height'**
  String get heightValidation;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameTaken;

  /// No description provided for @googleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google Cancelled'**
  String get googleCancelled;

  /// No description provided for @googleUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found. Please sign up using your Google account'**
  String get googleUserNotFound;

  /// No description provided for @googleUserFound.
  ///
  /// In en, this message translates to:
  /// **'Account found. Please sign in using your Google account'**
  String get googleUserFound;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password Reset Email Sent'**
  String get passwordResetEmailSent;

  /// No description provided for @passwordResetEmailSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Account Security is Our Priority! We\'ve Sent You a Secure Link to Safely Change Your Password and Keep Your Account Protected.'**
  String get passwordResetEmailSentSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// No description provided for @myWalletSub.
  ///
  /// In en, this message translates to:
  /// **'Outstanding:'**
  String get myWalletSub;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @appPreferencesSub.
  ///
  /// In en, this message translates to:
  /// **'Language and Notifications'**
  String get appPreferencesSub;

  /// No description provided for @accountAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountAndSecurity;

  /// No description provided for @accountAndSecuritySub.
  ///
  /// In en, this message translates to:
  /// **'Manage password and account access'**
  String get accountAndSecuritySub;

  /// No description provided for @supportAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get supportAndLegal;

  /// No description provided for @supportAndLegalSub.
  ///
  /// In en, this message translates to:
  /// **'Help, terms, and privacy'**
  String get supportAndLegalSub;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutText;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @languageSub.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSub;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts and reminders'**
  String get notificationsSub;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Update your account password securely'**
  String get changePasswordSub;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and all data'**
  String get deleteAccountSub;

  /// No description provided for @deleteAccountText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountText;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get deleteUserNotFound;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in again before deleting your account.'**
  String get requiresRecentLogin;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @websiteSub.
  ///
  /// In en, this message translates to:
  /// **'Visit our official website for more information'**
  String get websiteSub;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpSub.
  ///
  /// In en, this message translates to:
  /// **'Get assistance and FAQs'**
  String get helpSub;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdated;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @findYourClasses.
  ///
  /// In en, this message translates to:
  /// **'Find your classes'**
  String get findYourClasses;

  /// No description provided for @addClass.
  ///
  /// In en, this message translates to:
  /// **'Add Class'**
  String get addClass;

  /// No description provided for @className.
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get className;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @classType.
  ///
  /// In en, this message translates to:
  /// **'Class Type'**
  String get classType;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'City, Street, Building…'**
  String get locationHint;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @classCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Class Created'**
  String get classCreatedMessage;

  /// No description provided for @searchClasses.
  ///
  /// In en, this message translates to:
  /// **'Search classes...'**
  String get searchClasses;

  /// No description provided for @noClassesFound.
  ///
  /// In en, this message translates to:
  /// **'No Classes Found'**
  String get noClassesFound;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time (e.g., 2:00 PM)'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration (e.g., 2h)'**
  String get duration;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms'**
  String get acceptTerms;

  /// No description provided for @classNotFound.
  ///
  /// In en, this message translates to:
  /// **'Class Not Found'**
  String get classNotFound;

  /// No description provided for @classInfo.
  ///
  /// In en, this message translates to:
  /// **'Class Information'**
  String get classInfo;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @editClass.
  ///
  /// In en, this message translates to:
  /// **'Edit Class'**
  String get editClass;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @assignAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assign Assistant'**
  String get assignAssistant;

  /// No description provided for @searchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students...'**
  String get searchStudents;

  /// No description provided for @classQrCode.
  ///
  /// In en, this message translates to:
  /// **'Class QR Code'**
  String get classQrCode;

  /// No description provided for @classUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Class Updated'**
  String get classUpdatedMessage;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @assistantIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Assistant Identifier'**
  String get assistantIdentifier;

  /// No description provided for @assistantHint.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get assistantHint;

  /// No description provided for @assistantAdded.
  ///
  /// In en, this message translates to:
  /// **'Assistant Added'**
  String get assistantAdded;

  /// No description provided for @assistantNotFound.
  ///
  /// In en, this message translates to:
  /// **'Assistant not found by email or username'**
  String get assistantNotFound;

  /// No description provided for @assistants.
  ///
  /// In en, this message translates to:
  /// **'Assistants'**
  String get assistants;

  /// No description provided for @headCoach.
  ///
  /// In en, this message translates to:
  /// **'Head Coach'**
  String get headCoach;

  /// No description provided for @assistantCoach.
  ///
  /// In en, this message translates to:
  /// **'Assistant Coach'**
  String get assistantCoach;

  /// No description provided for @chooseRoleToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to continue'**
  String get chooseRoleToContinue;

  /// No description provided for @joinAsInstructor.
  ///
  /// In en, this message translates to:
  /// **'Join as Instructor'**
  String get joinAsInstructor;

  /// No description provided for @joinAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Join as Student'**
  String get joinAsStudent;

  /// No description provided for @requestToJoinClass.
  ///
  /// In en, this message translates to:
  /// **'Join request sent successfully'**
  String get requestToJoinClass;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQr;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @deleteClass.
  ///
  /// In en, this message translates to:
  /// **'Delete Class'**
  String get deleteClass;

  /// No description provided for @deleteClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteClassTitle;

  /// No description provided for @deleteClassWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All students, assistants, and progress will be permanently removed.'**
  String get deleteClassWarning;

  /// No description provided for @classDeleted.
  ///
  /// In en, this message translates to:
  /// **'Class Deleted Successfully'**
  String get classDeleted;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @graduationSystem.
  ///
  /// In en, this message translates to:
  /// **'Graduation System'**
  String get graduationSystem;

  /// No description provided for @noClassScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'No class scheduled today.'**
  String get noClassScheduledToday;

  /// No description provided for @addExtraSession.
  ///
  /// In en, this message translates to:
  /// **'Add Extra Session'**
  String get addExtraSession;

  /// No description provided for @jiujitsu.
  ///
  /// In en, this message translates to:
  /// **'Jiu‑Jitsu'**
  String get jiujitsu;

  /// No description provided for @addBelt.
  ///
  /// In en, this message translates to:
  /// **'Add Belt / Level'**
  String get addBelt;

  /// No description provided for @addBeltPerOrder.
  ///
  /// In en, this message translates to:
  /// **'Add Belt / Level Per Order'**
  String get addBeltPerOrder;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age Range'**
  String get ageRange;

  /// No description provided for @classesPerBeltOrStripe.
  ///
  /// In en, this message translates to:
  /// **'Classes per Belt/Stripe'**
  String get classesPerBeltOrStripe;

  /// No description provided for @beltColor.
  ///
  /// In en, this message translates to:
  /// **'Belt Color: '**
  String get beltColor;

  /// No description provided for @beltColor2.
  ///
  /// In en, this message translates to:
  /// **'Belt Color 2 (optional): '**
  String get beltColor2;

  /// No description provided for @pickBeltColor.
  ///
  /// In en, this message translates to:
  /// **'Pick Belt Color'**
  String get pickBeltColor;

  /// No description provided for @stripeColor.
  ///
  /// In en, this message translates to:
  /// **'Stripe Color (optional): '**
  String get stripeColor;

  /// No description provided for @pickStripeColor.
  ///
  /// In en, this message translates to:
  /// **'Pick Stripe Color'**
  String get pickStripeColor;

  /// No description provided for @ageRangeOverlaps.
  ///
  /// In en, this message translates to:
  /// **'Age range overlaps with another belt.'**
  String get ageRangeOverlaps;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get years;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noBeltsFound.
  ///
  /// In en, this message translates to:
  /// **'No Belts Found'**
  String get noBeltsFound;

  /// No description provided for @editBelt.
  ///
  /// In en, this message translates to:
  /// **'Edit Belt / Level'**
  String get editBelt;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @attendedToday.
  ///
  /// In en, this message translates to:
  /// **'Attended Today'**
  String get attendedToday;

  /// No description provided for @upcomingBelt.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Belt'**
  String get upcomingBelt;

  /// No description provided for @remainingClasses.
  ///
  /// In en, this message translates to:
  /// **'Remaining Classes'**
  String get remainingClasses;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @currentBelt.
  ///
  /// In en, this message translates to:
  /// **'Current Belt'**
  String get currentBelt;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @progressBar.
  ///
  /// In en, this message translates to:
  /// **'Progress Bar'**
  String get progressBar;

  /// No description provided for @classesAttended.
  ///
  /// In en, this message translates to:
  /// **'Classes Attended'**
  String get classesAttended;

  /// No description provided for @classesLeft.
  ///
  /// In en, this message translates to:
  /// **'classes left'**
  String get classesLeft;

  /// No description provided for @extraClasses.
  ///
  /// In en, this message translates to:
  /// **'extra classes since requirement'**
  String get extraClasses;

  /// No description provided for @stripes.
  ///
  /// In en, this message translates to:
  /// **'Stripes'**
  String get stripes;

  /// No description provided for @removeFromClass.
  ///
  /// In en, this message translates to:
  /// **'Remove from This Class'**
  String get removeFromClass;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Confirmation dialog text when removing a student
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {studentName}? This action cannot be undone.'**
  String removeFromClassText(String studentName);

  /// No description provided for @maxStripes.
  ///
  /// In en, this message translates to:
  /// **'Stripes Needed'**
  String get maxStripes;

  /// No description provided for @addAchievemnt.
  ///
  /// In en, this message translates to:
  /// **'Add Achievement'**
  String get addAchievemnt;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get pleaseSelectGender;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @globalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global Search'**
  String get globalSearch;

  /// No description provided for @findStudents.
  ///
  /// In en, this message translates to:
  /// **'Find students across all classes'**
  String get findStudents;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get searchByNameOrEmail;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @st.
  ///
  /// In en, this message translates to:
  /// **'student(s)'**
  String get st;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @cl.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get cl;

  /// No description provided for @primaryBelt.
  ///
  /// In en, this message translates to:
  /// **'Primary Belt'**
  String get primaryBelt;

  /// No description provided for @secondaryBelt.
  ///
  /// In en, this message translates to:
  /// **'Secondary Belt'**
  String get secondaryBelt;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @selectBeltColor.
  ///
  /// In en, this message translates to:
  /// **'Select Belt Color'**
  String get selectBeltColor;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
