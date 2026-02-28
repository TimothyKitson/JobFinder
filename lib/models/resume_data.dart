class WorkExperience {
  String jobTitle;
  String company;
  String startDate;
  String endDate;
  String description;

  WorkExperience({
    this.jobTitle = '',
    this.company = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });
}

class Education {
  String degree;
  String school;
  String graduationYear;

  Education({
    this.degree = '',
    this.school = '',
    this.graduationYear = '',
  });
}

class ResumeData {
  String fullName;
  String email;
  String phone;
  String address;
  String summary;
  List<WorkExperience> workExperience;
  List<Education> education;
  List<String> skills;

  ResumeData({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.summary = '',
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
  })  : workExperience = workExperience ?? [WorkExperience()],
        education = education ?? [Education()],
        skills = skills ?? [];

  bool get isComplete =>
      fullName.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;
}