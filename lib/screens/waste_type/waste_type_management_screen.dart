import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_list_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_details_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_edit_screen.dart';
import 'package:wasteanmagement/screens/waste_type/waste_type_collection_points_screen.dart';

class WasteTypeManagementScreen extends StatelessWidget {
  const WasteTypeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WasteTypeBloc(
        repository: context.read<WasteTypeRepository>(),
      ),
      child: Navigator(
        initialRoute: '/list',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/list':
              return MaterialPageRoute(builder: (_) => const WasteTypeListScreen());
            case '/details':
              final wasteTypeId = settings.arguments as int;
              return MaterialPageRoute(builder: (_) => WasteTypeDetailsScreen(wasteTypeId: wasteTypeId));
            case '/edit':
              final wasteTypeId = settings.arguments as int?;
              return MaterialPageRoute(builder: (_) => WasteTypeEditScreen(wasteTypeId: wasteTypeId));
            case '/collection-points':
              final wasteTypeId = settings.arguments as int;
              return MaterialPageRoute(builder: (_) => WasteTypeCollectionPointsScreen(wasteTypeId: wasteTypeId));
            default:
              return MaterialPageRoute(builder: (_) => const WasteTypeListScreen());
          }
        },
      ),
    );
  }
}