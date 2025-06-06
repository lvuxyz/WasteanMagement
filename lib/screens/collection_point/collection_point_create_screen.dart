import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/collection_point/collection_point_bloc.dart';
import '../../blocs/collection_point/collection_point_event.dart';
import '../../blocs/collection_point/collection_point_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_view.dart';
import '../collection_point/location_picker_screen.dart';

class CollectionPointCreateScreen extends StatefulWidget {
  const CollectionPointCreateScreen({Key? key}) : super(key: key);

  @override
  State<CollectionPointCreateScreen> createState() => _CollectionPointCreateScreenState();
}

class _CollectionPointCreateScreenState extends State<CollectionPointCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _operatingHoursController = TextEditingController(text: '08:00 - 17:00');
  final TextEditingController _capacityController = TextEditingController(text: '1000');
  final ValueNotifier<String> _statusNotifier = ValueNotifier<String>('active');
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _latitudeFocus = FocusNode();
  final FocusNode _longitudeFocus = FocusNode();
  final FocusNode _operatingHoursFocus = FocusNode();
  final FocusNode _capacityFocus = FocusNode();

  final List<String> _statusOptions = ['active', 'inactive', 'maintenance'];

  String? _errorMessage;
  bool _isNavigating = false;
  bool _isDisposed = false;
  bool _locationPickedFromMap = false;
  
  bool get canUseFocus => !_isDisposed && !_isNavigating && mounted;

  @override
  void dispose() {
    _isDisposed = true;
    
    // Cancel any pending focus operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This executes after the current frame, canceling any pending focus operations
    });
    
    // Dispose controllers
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _operatingHoursController.dispose();
    _capacityController.dispose();
    _statusNotifier.dispose();
    
    // Dispose FocusNodes
    _nameFocus.dispose();
    _addressFocus.dispose();
    _latitudeFocus.dispose();
    _longitudeFocus.dispose();
    _operatingHoursFocus.dispose();
    _capacityFocus.dispose();
    
    super.dispose();
  }

  // Safely unfocus without causing FocusNode errors
  void _safeUnfocus() {
    if (canUseFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() == true) {
      _createCollectionPoint();
    }
  }

  void _createCollectionPoint() {
    // Ensure unfocus from input fields
    _safeUnfocus();
    
    final CollectionPointBloc collectionPointBloc = context.read<CollectionPointBloc>();
    
    try {
      collectionPointBloc.add(
        CreateCollectionPoint(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latitudeController.text.trim()),
          longitude: double.parse(_longitudeController.text.trim()),
          operatingHours: _operatingHoursController.text.trim(),
          capacity: int.parse(_capacityController.text.trim()),
          status: _statusNotifier.value,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tạo điểm thu gom: $e';
      });
    }
  }
  
  Future<void> _openLocationPicker() async {
    // Parse current values if they exist
    double? currentLatitude;
    double? currentLongitude;
    
    try {
      if (_latitudeController.text.isNotEmpty) {
        currentLatitude = double.parse(_latitudeController.text);
      }
      if (_longitudeController.text.isNotEmpty) {
        currentLongitude = double.parse(_longitudeController.text);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    final LocationData? result = await Navigator.pushNamed(
      context,
      '/location-picker',
      arguments: {
        'initialLatitude': currentLatitude,
        'initialLongitude': currentLongitude,
      },
    ) as LocationData?;
    
    if (result != null) {
      setState(() {
        _latitudeController.text = result.latitude.toString();
        _longitudeController.text = result.longitude.toString();
        
        // Also update the address field if an address was returned
        if (result.address != null && result.address!.isNotEmpty) {
          _addressController.text = result.address!;
        }
        
        _locationPickedFromMap = true;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chọn vị trí từ bản đồ'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Mark as navigating before pop to avoid focus issues
        _isNavigating = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          title: const Text(
            'Tạo điểm thu gom mới',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_isNavigating) return;
              
              // Mark as navigating to prevent focus operations during pop
              _isNavigating = true;
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocConsumer<CollectionPointBloc, CollectionPointState>(
          listener: (context, state) {
            if (state is CollectionPointCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Separate navigation from the callback to avoid FocusNode issues
              if (!_isNavigating) {
                _isNavigating = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            } else if (state is CollectionPointError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CollectionPointLoading && state.isCreating) {
              return const LoadingView(message: 'Đang tạo điểm thu gom...');
            }
            
            return _buildForm();
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return GestureDetector(
      // Use safe unfocus method
      onTap: _safeUnfocus,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Khu vực thông tin cơ bản
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              
              // Tên điểm thu gom
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên điểm thu gom',
                hintText: 'Nhập tên điểm thu gom',
                prefixIcon: Icons.place,
                validator: (value) => Validators.validateNotEmpty(value, 'Vui lòng nhập tên điểm thu gom'),
              ),
              const SizedBox(height: 16),
              
              // Địa chỉ
              CustomTextField(
                controller: _addressController,
                labelText: 'Địa chỉ',
                hintText: 'Nhập địa chỉ chi tiết',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) => Validators.validateNotEmpty(value, 'Vui lòng nhập địa chỉ'),
              ),
              const SizedBox(height: 24),
              
              // Khu vực tọa độ
              Row(
                children: [
                  Expanded(child: _buildSectionTitle('Tọa độ vị trí')),
                  ElevatedButton.icon(
                    onPressed: _openLocationPicker,
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Chọn trên bản đồ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_locationPickedFromMap)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vị trí đã được chọn từ bản đồ',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_locationPickedFromMap) const SizedBox(height: 16),
              
              // Vĩ độ (Latitude)
              CustomTextField(
                controller: _latitudeController,
                labelText: 'Vĩ độ (Latitude)',
                hintText: 'Vd: 10.7736',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => Validators.validateCoordinate(value, 'vĩ độ'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                ],
              ),
              const SizedBox(height: 16),
              
              // Kinh độ (Longitude)
              CustomTextField(
                controller: _longitudeController,
                labelText: 'Kinh độ (Longitude)',
                hintText: 'Vd: 106.7034',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => Validators.validateCoordinate(value, 'kinh độ'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                ],
              ),
              const SizedBox(height: 24),
              
              // Khu vực thông tin hoạt động
              _buildSectionTitle('Thông tin hoạt động'),
              const SizedBox(height: 16),
              
              // Giờ hoạt động
              CustomTextField(
                controller: _operatingHoursController,
                labelText: 'Giờ hoạt động',
                hintText: 'Vd: 08:00 - 17:00',
                prefixIcon: Icons.access_time,
                validator: (value) => Validators.validateNotEmpty(value, 'Vui lòng nhập giờ hoạt động'),
              ),
              const SizedBox(height: 16),
              
              // Sức chứa
              CustomTextField(
                controller: _capacityController,
                labelText: 'Sức chứa (kg)',
                hintText: 'Vd: 1000',
                prefixIcon: Icons.inventory_2,
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateNumber(value, 'sức chứa'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              
              // Trạng thái
              ValueListenableBuilder<String>(
                valueListenable: _statusNotifier,
                builder: (context, status, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: status,
                            items: _statusOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(_formatStatusText(option)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _statusNotifier.value = value;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Nút tạo điểm thu gom
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'TẠO ĐIỂM THU GOM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 24),
            ],
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
  
  String _formatStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Hoạt động';
      case 'inactive':
        return 'Không hoạt động';
      case 'maintenance':
        return 'Bảo trì';
      default:
        return status;
    }
  }
} 