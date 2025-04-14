import 'package:bloc/bloc.dart';
import 'package:fyp/features/search/domain/search_repo.dart';
import 'package:fyp/features/search/presentation/cubits/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;
  SearchCubit(this.searchRepo) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    try {
      emit(SearchLoading());
      final users = await searchRepo.searchUsers(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError("Error fetching users: $e"));
    }
  }
}
