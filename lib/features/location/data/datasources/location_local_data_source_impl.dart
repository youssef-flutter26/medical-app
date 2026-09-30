import 'package:medical_app/features/location/data/datasources/location_local_data_source.dart';
import 'package:medical_app/features/location/data/models/medical_place_model.dart';
import 'package:medical_app/features/location/domain/entities/medical_place.dart';

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  @override
  Future<List<MedicalPlaceModel>> getMedicalPlaces() async {
    return const [
      MedicalPlaceModel(
        id: '1',
        name: 'Sunrise Health Clinic',
        address: '123 Oak Street, Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
        rating: 5.0,
        reviewsCount: 58,
        distance: 0,
        type: MedicalPlaceType.hospital,
        imageUrl: 'assets/images/hospital_1.jpg',
      ),
      MedicalPlaceModel(
        id: '2',
        name: 'Golden Cardiology Center',
        address: '555 Bridge Street, Cairo',
        latitude: 30.0626,
        longitude: 31.2497,
        rating: 4.9,
        reviewsCount: 43,
        distance: 0,
        type: MedicalPlaceType.hospital,
        imageUrl: 'assets/images/Image.png',
      ),
      MedicalPlaceModel(
        id: '3',
        name: 'Dr. Ahmed Hassan',
        address: 'Maadi Medical Center',
        latitude: 29.9602,
        longitude: 31.2569,
        rating: 4.8,
        reviewsCount: 31,
        distance: 0,
        type: MedicalPlaceType.doctor,
        specialty: 'Cardiologist',
        imageUrl: 'assets/images/Image.png',
      ),
      MedicalPlaceModel(
        id: '4',
        name: 'Dr. Sara Mohamed',
        address: 'New Cairo Medical Center',
        latitude: 30.0308,
        longitude: 31.4687,
        rating: 4.9,
        reviewsCount: 67,
        distance: 0,
        type: MedicalPlaceType.doctor,
        specialty: 'Dermatologist',
        imageUrl: 'assets/images/Image.png',
      ),
      MedicalPlaceModel(
        id: '5',
        name: 'Cairo Medical Hospital',
        address: 'Nasr City, Cairo',
        latitude: 30.0511,
        longitude: 31.3656,
        rating: 4.7,
        reviewsCount: 91,
        distance: 0,
        type: MedicalPlaceType.hospital,
        imageUrl: 'assets/images/Image.png',
      ),
    ];
  }
}
