import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../repositories/waste_type_repository.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_list_screen.dart';
class WasteTypeManagementScreen extends StatelessWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteTypeBloc(
        repository: WasteTypeRepository(),
      )..add(LoadWasteTypes()),
      child: const WasteTypeListScreen(),
    );
  }
}