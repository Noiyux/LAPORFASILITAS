import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // ================= AMBIL POSISI =================
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location service tidak aktif';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ================= REVERSE GEOCODING =================
  static Future<String> getAddressFromLatLng(
      double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isEmpty) return '-';

    final place = placemarks.first;

    return '${place.street}, ${place.subLocality}, '
        '${place.locality}, ${place.administrativeArea}';
  }

  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return '$latitude, $longitude';

      final p = placemarks.first;
      final parts = [
        if (p.street != null && p.street!.isNotEmpty) p.street,
        if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
        if (p.locality != null && p.locality!.isNotEmpty) p.locality,
        if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) p.administrativeArea,
        if (p.country != null && p.country!.isNotEmpty) p.country,
      ];
      return parts.where((s) => s != null && s.isNotEmpty).join(', ');
    } catch (e) {
      // fallback: return coordinates if reverse geocoding fails
      return '$latitude, $longitude';
    }
  }
}
