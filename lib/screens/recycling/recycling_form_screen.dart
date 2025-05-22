import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/recycling/recycling_bloc.dart';
import '../../blocs/recycling/recycling_event.dart';
import '../../blocs/recycling/recycling_state.dart';
import '../../models/transaction.dart';
import '../../repositories/recycling_repository.dart';
import '../../services/recycling_service.dart';
import '../../core/network/network_info.dart';
import '../../utils/app_colors.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../repositories/waste_type_repository.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../repositories/transaction_repository.dart';
import '../../models/waste_type_model.dart';
import '../../core/api/api_client.dart';
import '../../utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class RecyclingFormScreen extends StatefulWidget {
  const RecyclingFormScreen({Key? key}) : super(key: key);

  @override
  State<RecyclingFormScreen> createState() => _RecyclingFormScreenState();
}

class _RecyclingFormScreenState extends State<RecyclingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedTransactionId;
  String? _selectedWasteTypeId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<dynamic> _transactions = [];
  List<WasteType> _wasteTypes = [];
  
  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      double? quantity;
      if (_quantityController.text.isNotEmpty) {
        quantity = double.tryParse(_quantityController.text);
      }
      
      Transaction? selectedTransaction;
      try {
        selectedTransaction = _transactions.firstWhere(
          (t) => t.transactionId.toString() == _selectedTransactionId,
        );
      } catch (e) {
        selectedTransaction = null;
      }
      
      if (selectedTransaction != null && _selectedWasteTypeId != null) {
        context.read<RecyclingBloc>().add(CreateRecyclingProcess(
          transactionId: _selectedTransactionId!,
          wasteTypeId: _selectedWasteTypeId!,
          quantity: quantity,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn giao dịch và loại rác'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(
      client: http.Client(),
      secureStorage: SecureStorage(),
    );
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecyclingBloc(
            repository: RecyclingRepository(
              recyclingService: RecyclingService(
                apiClient: apiClient,
              ),
              networkInfo: NetworkInfoImpl(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => WasteTypeBloc(
            repository: WasteTypeRepository(
              apiClient: apiClient,
            ),
          )..add(LoadWasteTypes()),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            transactionRepository: TransactionRepository(
              apiClient: apiClient,
            ),
          )..add(FetchTransactions()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tạo quy trình tái chế mới'),
              backgroundColor: AppColors.primaryGreen,
            ),
            body: MultiBlocListener(
              listeners: [
                BlocListener<RecyclingBloc, RecyclingState>(
                  listener: (context, state) {
                    if (state is RecyclingError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    
                    if (state is RecyclingProcessCreated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tạo quy trình tái chế thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
                BlocListener<WasteTypeBloc, WasteTypeState>(
                  listener: (context, state) {
                    if (state is WasteTypeLoaded) {
                      setState(() {
                        _wasteTypes = state.wasteTypes;
                      });
                    }
                  },
                ),
                BlocListener<TransactionBloc, TransactionState>(
                  listener: (context, state) {
                    if (state.status == TransactionStatus.success) {
                      setState(() {
                        _transactions = state.transactions;
                      });
                    }
                  },
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 24),
                      
                      BlocBuilder<RecyclingBloc, RecyclingState>(
                        builder: (context, state) {
                          return state is RecyclingLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () => _submitForm(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Tạo quy trình tái chế',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin quy trình',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Transaction Selection
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state.status == TransactionStatus.loading && _transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Giao dịch',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  value: _selectedTransactionId,
                  items: _transactions.map((transaction) {
                    return DropdownMenuItem<String>(
                      value: transaction.transactionId.toString(),
                      child: Text(
                        '${transaction.wasteTypeName} - ${transaction.quantity} ${transaction.unit}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTransactionId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn giao dịch';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Waste Type Selection
            BlocBuilder<WasteTypeBloc, WasteTypeState>(
              builder: (context, state) {
                if (state is WasteTypeLoading && _wasteTypes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Loại rác',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  value: _selectedWasteTypeId,
                  items: _wasteTypes.map((wasteType) {
                    return DropdownMenuItem<String>(
                      value: wasteType.id.toString(),
                      child: Text(
                        wasteType.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWasteTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn loại rác';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Quantity Field
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng (kg)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
} 