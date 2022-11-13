import 'package:flutter_bloc/flutter_bloc.dart';

import '../globals.dart';
import '../utils.dart';

class WakesCubit extends Cubit<Wakes> {
  WakesCubit(Wakes initialState) : super(initialState) {
    _loadWakes();
  }

  void _loadWakes() async {
    var wakes = await loadStoredWakes();
    emit(wakes);
  }

  void addWake(value) => emit(finiteAddToList(state, value));
  void setWakes(values) => emit(values);
  void resetWake(int wakeIndex) {
    var updated = state.toList();
    updated.removeAt(wakeIndex);
    emit(updated);
  }

  void resetAll() => emit([]);

  @override
  void onChange(Change<Wakes> change) async {
    super.onChange(change);
    await setStoredWakes(change.nextState);
    print(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
