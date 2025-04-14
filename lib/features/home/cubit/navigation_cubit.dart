import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0); // default to Home

  void updateIndex(int index) => emit(index);
  void setTab(int index) {
    emit(index); // updates the current tab
  }
}
