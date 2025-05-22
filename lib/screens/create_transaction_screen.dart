import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_bloc.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_event.dart';
import 'package:wasteanmagement/blocs/transaction/transaction_state.dart';
import 'package:wasteanmagement/models/collection_point.dart';
import 'package:wasteanmagement/models/waste_type_model.dart';
import 'package:wasteanmagement/utils/app_colors.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({Key? key}) : super(key: key);

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  CollectionPoint? _selectedCollectionPoint;
  WasteType? _selectedWasteType;
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'kg';
  File? _imageFile;
  bool _isLoading = false;
  
  // Dropdown items
  List<CollectionPoint> _collectionPoints = [];
  List<WasteType> _wasteTypes = [];
  final List<String> _unitOptions = ['kg', 'g', 'liter', 'piece'];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  void _loadData() {
    // TODO: Implement fetch of real collection points and waste types
    // For now, we'll prepare empty lists until real data sources are ready
    
    // The following code would be used when your TransactionBloc is updated:
    // final transactionBloc = context.read<TransactionBloc>();
    // transactionBloc.add(LoadCollectionPoints());
    // transactionBloc.add(LoadWasteTypes());
    
    setState(() {
      _collectionPoints = [];
      _wasteTypes = [];
    });
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCollectionPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn điểm thu gom')),
      );
      return;
    }
    
    if (_selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn loại rác')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create the transaction
      context.read<TransactionBloc>().add(
        CreateTransaction(
          collectionPointId: _selectedCollectionPoint!.collectionPointId,
          wasteTypeId: _selectedWasteType!.id,
          quantity: double.parse(_quantityController.text),
          unit: _selectedUnit,
          proofImage: _imageFile,
        ),
      );
      
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch đã được tạo thành công')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print('Error creating transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo giao dịch mới'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Thông tin giao dịch'),
                      const SizedBox(height: 16),
                      _buildCollectionPointDropdown(),
                      const SizedBox(height: 16),
                      _buildWasteTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildQuantityField(),
                      const SizedBox(height: 16),
                      _buildUnitDropdown(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Hình ảnh minh chứng'),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCollectionPointDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm thu gom',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CollectionPoint>(
              isExpanded: true,
              value: _selectedCollectionPoint,
              hint: const Text('Chọn điểm thu gom'),
              items: _collectionPoints.map((point) {
                return DropdownMenuItem<CollectionPoint>(
                  value: point,
                  child: Text(
                    point.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCollectionPoint = value;
                });
              },
            ),
          ),
        ),
        if (_selectedCollectionPoint != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Địa chỉ: ${_selectedCollectionPoint!.address}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildWasteTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại rác',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<WasteType>(
              isExpanded: true,
              value: _selectedWasteType,
              hint: const Text('Chọn loại rác'),
              items: _wasteTypes.map((type) {
                return DropdownMenuItem<WasteType>(
                  value: type,
                  child: Text(
                    type.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWasteType = value;
                });
              },
            ),
          ),
        ),
        if (_selectedWasteType != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Mô tả: ${_selectedWasteType!.description}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số lượng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Nhập số lượng',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số lượng';
            }
            if (double.tryParse(value) == null) {
              return 'Vui lòng nhập số hợp lệ';
            }
            if (double.parse(value) <= 0) {
              return 'Số lượng phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đơn vị tính',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedUnit,
              items: _unitOptions.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Tạo giao dịch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 