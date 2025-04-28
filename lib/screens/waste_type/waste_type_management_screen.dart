import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../repositories/waste_type_repository.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_list_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_details_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_edit_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_collection_points_screen.dart';
import '../../widgets/common/custom_app_bar.dart';

class WasteTypeManagementScreen extends StatelessWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteTypeBloc(
        repository: WasteTypeRepository(),
      )..add(LoadWasteTypes()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Quản lý loại rác',
        ),
        body: const WasteTypeListScreen(),
      ),
    );
  }
}