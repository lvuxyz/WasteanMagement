import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/recycling_progress/recycling_progress_bloc.dart';
import '../../blocs/recycling_progress/recycling_progress_event.dart';
import '../../models/waste_type_model.dart';
import 'package:intl/intl.dart';

class RecyclingProgressFilter extends StatefulWidget {
  final List<WasteType> wasteTypes;
  
  const RecyclingProgressFilter({
    Key? key,
    required this.wasteTypes,
  }) : super(key: key);

  @override
  State<RecyclingProgressFilter> createState() => _RecyclingProgressFilterState();
}

class _RecyclingProgressFilterState extends State<RecyclingProgressFilter> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedWasteTypeId = '';
  
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc dữ liệu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Date range filter
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateFormat.format(_startDate),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'đến',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateFormat.format(_endDate),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Waste type filter
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Loại rác',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            value: _selectedWasteTypeId.isEmpty ? null : _selectedWasteTypeId,
            hint: const Text('Tất cả loại rác'),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('Tất cả loại rác'),
              ),
              ...widget.wasteTypes.map((type) => DropdownMenuItem<String>(
                value: type.id.toString(),
                child: Text(type.name),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedWasteTypeId = value ?? '';
              });
              _applyWasteTypeFilter();
            },
          ),
          const SizedBox(height: 16),
          
          // Apply filter button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyDateFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Áp dụng bộ lọc'),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  void _applyDateFilter() {
    context.read<RecyclingProgressBloc>().add(
      FilterRecyclingProgressByTimeRange(
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }
  
  void _applyWasteTypeFilter() {
    context.read<RecyclingProgressBloc>().add(
      FilterRecyclingProgressByWasteType(
        wasteTypeId: _selectedWasteTypeId,
      ),
    );
  }
} 