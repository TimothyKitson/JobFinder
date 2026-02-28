class JobListing {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? website;
  final String? businessType;
  final double? rating;
  final double distance;

  JobListing({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
    this.businessType,
    this.rating,
    required this.distance,
  });

  factory JobListing.fromPlacesApi(
      Map<String, dynamic> json, double distanceMiles) {
    final types = (json['types'] as List?)?.cast<String>() ?? [];
    final friendlyType = _friendlyType(types);

    return JobListing(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      address: json['vicinity'] ?? '',
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      businessType: friendlyType,
      rating: (json['rating'] as num?)?.toDouble(),
      distance: distanceMiles,
    );
  }

  static String _friendlyType(List<String> types) {
    const map = {
      'restaurant': 'Restaurant',
      'food': 'Food & Beverage',
      'store': 'Retail',
      'cafe': 'Café',
      'bar': 'Bar',
      'hospital': 'Healthcare',
      'school': 'Education',
      'gym': 'Fitness',
      'hotel': 'Hospitality',
      'supermarket': 'Grocery',
      'pharmacy': 'Pharmacy',
      'car_repair': 'Auto Service',
      'beauty_salon': 'Salon',
      'real_estate_agency': 'Real Estate',
      'accounting': 'Accounting',
      'lawyer': 'Legal',
      'doctor': 'Medical',
      'dentist': 'Dental',
      'veterinary_care': 'Veterinary',
    };
    for (final t in types) {
      if (map.containsKey(t)) return map[t]!;
    }
    return types.isNotEmpty ? types.first.replaceAll('_', ' ') : 'Business';
  }

  JobListing copyWith({String? phoneNumber, String? website}) {
    return JobListing(
      id: id,
      name: name,
      address: address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      businessType: businessType,
      rating: rating,
      distance: distance,
    );
  }
}