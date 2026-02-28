import 'package:flutter/foundation.dart';
import 'job_listing.dart';
import 'resume_data.dart';

class AppState extends ChangeNotifier {
  String location = '';
  double searchRadius = 5.0;
  double? lat;
  double? lng;

  List<String> selectedJobTypes = [];
  String experienceLevel = 'No experience';
  String skills = '';

  List<JobListing> searchResults = [];
  Set<String> selectedJobIds = {};
  bool isSearching = false;
  String? searchError;

  ResumeData resumeData = ResumeData();
  String? uploadedResumePath;
  bool resumeUploaded = false;

  List<JobListing> get selectedJobs =>
      searchResults.where((j) => selectedJobIds.contains(j.id)).toList();

  bool isJobSelected(String id) => selectedJobIds.contains(id);

  void setLocation(String loc, double radius) {
    location = loc;
    searchRadius = radius;
    notifyListeners();
  }

  void setCoordinates(double latitude, double longitude) {
    lat = latitude;
    lng = longitude;
    notifyListeners();
  }

  void setExperience(List<String> types, String level, String skillsText) {
    selectedJobTypes = types;
    experienceLevel = level;
    skills = skillsText;
    notifyListeners();
  }

  void setSearching(bool value) {
    isSearching = value;
    searchError = null;
    notifyListeners();
  }

  void setSearchResults(List<JobListing> results) {
    searchResults = results;
    selectedJobIds = {};
    isSearching = false;
    notifyListeners();
  }

  void setSearchError(String error) {
    searchError = error;
    isSearching = false;
    notifyListeners();
  }

  void toggleJobSelection(String id) {
    if (selectedJobIds.contains(id)) {
      selectedJobIds.remove(id);
    } else {
      selectedJobIds.add(id);
    }
    notifyListeners();
  }

  void updateJobDetails(String id, String? phone, String? website) {
    final idx = searchResults.indexWhere((j) => j.id == id);
    if (idx != -1) {
      searchResults[idx] =
          searchResults[idx].copyWith(phoneNumber: phone, website: website);
      notifyListeners();
    }
  }

  void setResumeData(ResumeData data) {
    resumeData = data;
    resumeUploaded = false;
    notifyListeners();
  }

  void setUploadedResume(String path) {
    uploadedResumePath = path;
    resumeUploaded = true;
    notifyListeners();
  }
}