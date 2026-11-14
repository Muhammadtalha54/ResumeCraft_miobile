/// Centralized localization-ready text dictionary.
/// No user-facing strings should be hardcoded in widgets or logic.
class Lang {
  Lang._();

  // App Identity
  static const String appName = 'Resume Craft';
  static const String appTagline = 'Smart ATS Optimization & Job Match';

  // Navigation & Shell
  static const String tabHome = 'Home';
  static const String tabCreateResume = 'Build';
  static const String tabSearchJobs = 'Jobs';
  static const String tabProfile = 'Profile';

  // Drawer
  static const String drawerTitle = 'ResumeCraft Platform';
  static const String drawerResumeHistory = 'Resume History';
  static const String drawerSupport = 'Support & Help';
  static const String drawerPrivacy = 'Privacy Policy';
  static const String drawerTerms = 'Terms of Service';
  static const String drawerLogout = 'Sign Out';

  // Splash & Onboarding
  static const String splashLoading = 'Initializing ResumeCraft AI...';
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Continue';
  static const String onboardingGetStarted = 'Get Started';

  static const String obTitle1 = 'AI-Powered ATS Resume Scoring';
  static const String obDesc1 = 'Upload your current resume and uncover recruiter keywords, ATS compatibility, and formatting issues instantly.';

  static const String obTitle2 = 'Tailor For Big Tech & Global Roles';
  static const String obDesc2 = 'Generate FAANG, European CV, and Gulf Executive resumes tailored to any job description using Gemini AI.';

  static const String obTitle3 = 'Live Aggregated Job Opportunities';
  static const String obDesc3 = 'Discover verified, active vacancies across top platforms and track your applications in real time.';

  // Auth: Login
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to access your resumes and ATS insights';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'e.g. candidate@domain.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPasswordLink = 'Forgot Password?';
  static const String loginButton = 'Sign In';
  static const String noAccountPrompt = "Don't have an account? ";
  static const String signUpLink = 'Create Account';

  // Auth: Registration
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Join ResumeCraft AI to build job-winning resumes';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'e.g. John Doe';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String registerButton = 'Create Account';
  static const String hasAccountPrompt = 'Already have an account? ';
  static const String signInLink = 'Sign In';
  static const String termsAcceptNotice = 'By creating an account, you agree to our Terms of Service & Privacy Policy.';

  // Auth: Forgot Password
  static const String forgotPasswordTitle = 'Reset Password';
  static const String forgotPasswordSubtitle = 'Enter your email to receive recovery instructions';
  static const String sendResetButton = 'Send Reset Instructions';
  static const String backToLogin = 'Back to Sign In';
  static const String resetSuccessMessage = 'If an account exists with this email, password reset instructions have been dispatched.';

  // Home: Resume Upload & Analysis
  static const String homeGreetingMorning = 'Good morning,';
  static const String homeGreetingAfternoon = 'Good afternoon,';
  static const String homeGreetingEvening = 'Good evening,';
  static const String uploadCardTitle = 'Upload Resume for ATS Audit';
  static const String uploadCardSubtitle = 'PDF or DOCX (Max 10 MB). Our AI analyzes keyword match, structure, and readability.';
  static const String selectFileButton = 'Choose Document';
  static const String fileSelected = 'File Selected:';
  static const String removeFile = 'Remove';
  static const String targetJobTitleLabel = 'Target Job Title (Optional)';
  static const String targetJobTitleHint = 'e.g. Senior Frontend Engineer';
  static const String targetJobDescLabel = 'Target Job Description (Optional)';
  static const String targetJobDescHint = 'Paste the target job description for 1:1 ATS keyword alignment & match score...';
  static const String analyzeResumeButton = 'Analyze ATS Compatibility';
  static const String analyzingProgress = 'Extracting resume text & running Gemini ATS analysis...';
  static const String recentAnalysesTitle = 'Recent Resumes';
  static const String noResumesYet = 'No resumes analyzed yet. Upload your first document to see how applicant tracking systems score your profile.';

  // ATS Results Screen
  static const String atsResultTitle = 'ATS Audit Results';
  static const String overallScore = 'Overall Compatibility';
  static const String scoreFormat = 'Formatting & Layout';
  static const String scoreContent = 'Content & Metrics';
  static const String scoreSkills = 'Skills Alignment';
  static const String scoreImpact = 'Action Verb Impact';
  static const String keyStrengthsTitle = 'Key Strengths';
  static const String improvementRecommendationsTitle = 'Actionable Improvements';
  static const String tailorNowButton = 'Tailor with AI';

  // Resume Builder & Tailor
  static const String builderTitle = 'AI Resume Studio';
  static const String modeUploadTailor = 'Tailor Existing';
  static const String modeBuildScratch = 'Build from Scratch';
  static const String selectTemplateTitle = '1. Select Professional Layout';
  static const String targetStrategyTitle = '2. Target Strategy';
  static const String pasteJobDescTitle = '3. Paste Job Description (Optional)';
  static const String pasteJobDescHint = 'Paste the requirements and responsibilities to optimize keyword density...';
  static const String tailorAction = 'Generate Resume';
  static const String exportPdfButton = 'Download PDF';

  // Scratch Resume Form Constants
  static const String scratchPersonalInfo = '1. Personal Information (Compulsory)';
  static const String scratchJobTarget = '2. Target Role & Job Description (Compulsory)';
  static const String scratchSkills = '3. Technical & Core Skills (Compulsory)';
  static const String scratchExperience = '4. Work Experience';
  static const String scratchEducation = '5. Education';
  static const String phoneLabel = 'Phone Number';
  static const String phoneHint = 'e.g. +1 (555) 019-2831';
  static const String locationLabel = 'Location / City';
  static const String scratchLocationHint = 'e.g. San Francisco, CA / Remote';
  static const String linkedinLabel = 'LinkedIn URL';
  static const String linkedinHint = 'e.g. linkedin.com/in/username';
  static const String portfolioLabel = 'Portfolio / GitHub URL';
  static const String portfolioHint = 'e.g. github.com/username';
  static const String skillsLabel = 'Skills (Comma-separated)';
  static const String skillsHint = 'e.g. Flutter, Dart, TypeScript, REST APIs, Git';
  static const String companyLabel = 'Company Name';
  static const String companyHint = 'e.g. TechCorp Inc.';
  static const String roleLabel = 'Role / Title';
  static const String roleHint = 'e.g. Mobile Developer';
  static const String periodLabel = 'Period';
  static const String periodHint = 'e.g. Jan 2022 - Present';
  static const String achievementsLabel = 'Key Responsibilities / Impact';
  static const String achievementsHint = 'Brief summary of what you did...';
  static const String degreeLabel = 'Degree / Major';
  static const String degreeHint = 'e.g. B.S. in Computer Science';
  static const String schoolLabel = 'University / Institution';
  static const String schoolHint = 'e.g. Stanford University';
  static const String graduationYearLabel = 'Graduation Year';
  static const String graduationYearHint = 'e.g. 2024';
  static const String addExperience = '+ Add Experience';
  static const String addEducation = '+ Add Education';
  static const String generateScratchAction = 'Generate ATS Resume with AI';
  static const String generatingScratch = 'Formulating ATS resume with Gemini AI...';

  // Mobile Live Resume Editor
  static const String editResumeContent = 'Edit Content';
  static const String resumeEditorTitle = 'Edit Tailored Resume';
  static const String summaryLabel = 'Professional Summary';
  static const String summaryHint = 'Edit your executive professional summary...';
  static const String editBulletPoints = 'Experience Bullet Points (one per line)';
  static const String saveChanges = 'Save Changes';
  static const String updatingContent = 'Saving updates...';
  static const String updateSuccess = 'Resume content updated successfully!';

  // Job Search
  static const String searchJobsTitle = 'Search Opportunities';
  static const String searchJobsHint = 'Job title, keywords, or company...';
  static const String locationHint = 'Location (e.g. Remote, Pakistan, US)';
  static const String filterJobType = 'Job Type';
  static const String applyNow = 'Apply Now';
  static const String saveApplication = 'Track Application';
  static const String noJobsFound = 'No vacancies match your query. Try broadening your keywords or location.';
  static const String searchingJobs = 'Scanning LinkedIn & tech job feeds...';

  // Profile & Credits
  static const String profileTitle = 'Candidate Profile';
  static const String planFree = 'Free Tier';
  static const String planPro = 'Pro Member';
  static const String resumeCredits = 'Resume Credits';
  static const String atsCredits = 'ATS Audit Credits';
  static const String accountSettings = 'Account Details';
  static const String helpCenter = 'Help & Support';

  // Customer Support
  static const String supportTitle = 'Customer Support';
  static const String openNewTicket = 'Submit Inquiry';
  static const String ticketSubject = 'Subject';
  static const String ticketMessage = 'Description of your issue or question';
  static const String submitTicket = 'Submit Ticket';
  static const String ticketSubmitted = 'Your support ticket has been received. Our team will review it shortly.';

  // Dialogs & Confirmations
  static const String logoutConfirmTitle = 'Sign Out?';
  static const String logoutConfirmMessage = 'Are you sure you want to log out of ResumeCraft AI?';
  static const String confirmYes = 'Sign Out';
  static const String confirmCancel = 'Cancel';
  static const String deleteConfirm = 'Delete';

  // Validation Messages
  static const String valRequired = 'This field cannot be empty.';
  static const String valEmailInvalid = 'Please enter a valid email address.';
  static const String valPasswordLength = 'Password must be at least 6 characters.';
  static const String valPasswordMismatch = 'Passwords do not match.';
  static const String valFileTooLarge = 'File size exceeds maximum 10 MB limit.';
  static const String valInvalidFileType = 'Only PDF and DOCX documents are supported.';

  // Generic Status
  static const String genericError = 'An unexpected error occurred. Please try again.';
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String sessionExpired = 'Your session has expired. Please sign in again.';
}
