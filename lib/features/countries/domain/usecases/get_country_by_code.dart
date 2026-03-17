import '../entities/country.dart';
import '../repositories/countries_repository.dart';

/// Retrieves a single country by its stable code.
class GetCountryByCode {
  /// Creates the use case.
  const GetCountryByCode(this._repository);

  final CountriesRepository _repository;

  /// Executes the use case.
  Future<Country?> call(String code) {
    return _repository.getCountryByCode(code);
  }
}
