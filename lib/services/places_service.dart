import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/job_listing.dart';

class PlacesService {
  static const String _apiKey = 'YOUR API KEY HERE';
  static const String _base = 'https://maps.googleapis.com/maps/api';

  static const Map<String, List<String>> jobTypeToPlaceTypes = {
    'Restaurant / Food': ['restaurant', 'cafe', 'bakery', 'bar', 'meal_takeaway'],
    'Retail / Store': ['store', 'supermarket', 'clothing_store', 'convenience_store'],
    'Healthcare': ['hospital', 'doctor', 'dentist', 'pharmacy', 'veterinary_care'],
    'Hospitality': ['hotel', 'lodging'],
    'Education': ['school', 'university', 'library'],
    'Fitness / Wellness': ['gym', 'beauty_salon', 'spa'],
    'Auto': ['car_repair', 'car_dealer', 'car_wash'],
    'Office / Professional': ['accounting', 'lawyer', 'real_estate_agency', 'insurance_agency'],
    'Any nearby business': ['establishment'],
  };

static Future<Map<String, double>?> geocodeAddress(String address) async {
  final url = Uri.parse(
      '$_base/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey');
  try {
    print('DEBUG: Calling URL: $url');
    final res = await http.get(url);
    print('DEBUG: Status code: ${res.statusCode}');
    print('DEBUG: Response body: ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK') {
        final loc = data['results'][0]['geometry']['location'];
        return {
          'lat': (loc['lat'] as num).toDouble(),
          'lng': (loc['lng'] as num).toDouble()
        };
      }
    }
  } catch (e) {
    print('DEBUG: Error: $e');
  }
  return null;
}

  static Future<List<JobListing>> searchNearbyBusinesses({
    required double lat,
    required double lng,
    required double radiusMiles,
    required List<String> selectedJobTypes,
  }) async {
    final radiusMeters = (radiusMiles * 1609.34).round().clamp(1, 50000);
    final seen = <String>{};
    final results = <JobListing>[];

    final placeTypes = <String>{};
    for (final label in selectedJobTypes) {
      placeTypes.addAll(jobTypeToPlaceTypes[label] ?? ['establishment']);
    }
    if (placeTypes.isEmpty) placeTypes.add('establishment');

    for (final type in placeTypes) {
      final url = Uri.parse(
          '$_base/place/nearbysearch/json'
          '?location=$lat,$lng'
          '&radius=$radiusMeters'
          '&type=$type'
          '&key=$_apiKey');
      try {
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
            for (final place in (data['results'] as List)) {
              final id = place['place_id'] as String;
              if (seen.add(id)) {
                final plLoc = place['geometry']['location'];
                final dist = _haversine(
                    lat, lng,
                    (plLoc['lat'] as num).toDouble(),
                    (plLoc['lng'] as num).toDouble());
                results.add(JobListing.fromPlacesApi(place, dist));
              }
            }
          }
        }
      } catch (_) {}
    }

    results.sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  static Future<Map<String, String?>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
        '$_base/place/details/json'
        '?place_id=$placeId'
        '&fields=formatted_phone_number,website'
        '&key=$_apiKey');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK') {
          final r = data['result'] as Map<String, dynamic>;
          return {
            'phone': r['formatted_phone_number'] as String?,
            'website': r['website'] as String?,
          };
        }
      }
    } catch (_) {}
    return {'phone': null, 'website': null};
  }

  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const R = 3958.8;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}