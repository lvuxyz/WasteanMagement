import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/waste_type/waste_type_bloc.dart';
import '../../blocs/waste_type/waste_type_event.dart';
import '../../blocs/waste_type/waste_type_state.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../utils/snackbar_utils.dart';

class WasteTypeAddScreen extends StatefulWidget {
  const WasteTypeAddScreen({Key? key}) : super(key: key);
  
  @override
  State<WasteTypeAddScreen> createState() => _WasteTypeAddScreenState();
}

class _WasteTypeAddScreenState extends State<WasteTypeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _handlingInstructionsController = TextEditingController();
  final _unitPriceController = TextEditingController();
  bool _isRecyclable = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _handlingInstructionsController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final double unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
      
      context.read<WasteTypeBloc>().add(
        CreateWasteType(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          recyclable: _isRecyclable,
          handlingInstructions: _handlingInstructionsController.text.trim(),
          unitPrice: unitPrice,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm loại rác'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
      ),
      body: BlocListener<WasteTypeBloc, WasteTypeState>(
        listener: (context, state) {
          if (state is WasteTypeLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
            
            if (state is WasteTypeCreated) {
              SnackBarUtils.showSuccess(context, state.message);
              Navigator.of(context).pop();
            } else if (state is WasteTypeError) {
              SnackBarUtils.showError(context, state.message);
            }
          }
        },
        child: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên loại rác
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Tên loại rác',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên loại rác';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Mô tả
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Mô tả',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Có thể tái chế
                    SwitchListTile(
                      title: const Text('Có thể tái chế'),
                      subtitle: Text(_isRecyclable ? 'Có' : 'Không'),
                      value: _isRecyclable,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _isRecyclable = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Hướng dẫn xử lý
                    CustomTextField(
                      controller: _handlingInstructionsController,
                      labelText: 'Hướng dẫn xử lý',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập hướng dẫn xử lý';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Giá đơn vị
                    CustomTextField(
                      controller: _unitPriceController,
                      labelText: 'Giá đơn vị (VNĐ/kg)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giá đơn vị';
                        }
                        
                        if (double.tryParse(value) == null) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Nút gửi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Thêm loại rác',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
} 