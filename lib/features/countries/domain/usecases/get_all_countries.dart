import '../entities/country.dart';
import '../repositories/countries_repository.dart';

/// Retrieves the complete countries catalog.
class GetAllCountries {
  /// Creates the use case.
  const GetAllCountries(this._repository);

  final CountriesRepository _repository;

  /// Executes the use case.
  Future<List<Country>> call() {
    return _repository.getAllCountries();
  }
}
