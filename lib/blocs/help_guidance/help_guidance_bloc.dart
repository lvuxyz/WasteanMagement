import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'help_guidance_event.dart';
import 'help_guidance_state.dart';

class HelpGuidanceBloc extends Bloc<HelpGuidanceEvent, HelpGuidanceState> {
  HelpGuidanceBloc() : super(HelpGuidanceInitial()) {
    on<LoadHelpGuidanceData>(_onLoadHelpGuidanceData);
    on<SearchFaqs>(_onSearchFaqs);
  }

  void _onLoadHelpGuidanceData(
    LoadHelpGuidanceData event,
    Emitter<HelpGuidanceState> emit,
  ) {
    developer.log('Loading help and guidance data');
    
    // FAQ items data
    final List<Map<String, dynamic>> faqItems = [
      {
        'question': 'Làm thế nào để quét mã QR trên rác thải?',
        'answer': 'Để quét mã QR trên rác thải, hãy mở ứng dụng và nhấn vào biểu tượng camera ở giữa thanh điều hướng dưới cùng. Sau đó, hướng camera vào mã QR trên bao bì hoặc nhãn sản phẩm. Ứng dụng sẽ tự động nhận diện mã QR và cung cấp thông tin về phân loại rác thải cho sản phẩm đó.',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để đặt lịch thu gom rác?',
        'answer': 'Để đặt lịch thu gom rác, truy cập vào tab "Đặt lịch" từ menu chính, chọn loại rác cần thu gom, nhập khối lượng ước tính, và chọn thời gian thu gom phù hợp. Sau khi xác nhận, yêu cầu của bạn sẽ được ghi nhận và hiển thị trong phần "Lịch hẹn" của ứng dụng.',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để tích điểm thưởng từ việc tái chế?',
        'answer': 'Mỗi khi bạn tham gia vào các hoạt động tái chế thông qua ứng dụng (như gửi rác đến điểm thu gom, hoàn thành nhiệm vụ tái chế, chia sẻ thông tin về tái chế), bạn sẽ được tích điểm thưởng tự động. Bạn có thể theo dõi số điểm thưởng của mình trong phần "Tài khoản" > "Điểm thưởng".',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để tìm điểm thu gom gần nhất?',
        'answer': 'Để tìm điểm thu gom gần nhất, hãy mở tab "Địa điểm" từ thanh menu dưới cùng. Ứng dụng sẽ tự động hiển thị các điểm thu gom rác gần vị trí hiện tại của bạn. Bạn có thể lọc kết quả theo loại rác cần thu gom hoặc khoảng cách.',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để phân loại rác thải đúng cách?',
        'answer': 'Ứng dụng cung cấp hướng dẫn chi tiết về cách phân loại rác thải trong phần "Hướng dẫn phân loại". Bạn có thể tìm kiếm theo tên sản phẩm hoặc quét mã vạch/QR để nhận thông tin phân loại chính xác. Ngoài ra, thư viện phân loại rác cũng cung cấp thông tin về các loại rác thải phổ biến và cách xử lý chúng.',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để đổi điểm thưởng?',
        'answer': 'Để đổi điểm thưởng, hãy truy cập vào phần "Đổi điểm" từ trang chủ hoặc từ phần "Tài khoản" > "Điểm thưởng". Tại đây, bạn sẽ thấy danh sách các phần thưởng hoặc ưu đãi mà bạn có thể đổi lấy bằng điểm thưởng của mình. Chọn phần thưởng bạn muốn và làm theo hướng dẫn để hoàn tất quá trình đổi điểm.',
        'isExpanded': false,
      },
      {
        'question': 'Làm thế nào để kiểm tra thống kê tái chế của tôi?',
        'answer': 'Bạn có thể kiểm tra thống kê tái chế của mình bằng cách truy cập vào tab "Thống kê" từ thanh menu dưới cùng. Tại đây, bạn sẽ thấy các biểu đồ và số liệu chi tiết về lượng rác thải đã tái chế theo loại, thời gian, và tác động môi trường tích cực mà bạn đã tạo ra.',
        'isExpanded': false,
      },
    ];

    // Tutorial categories data
    final List<Map<String, dynamic>> tutorialCategories = [
      {
        'title': 'Bắt đầu sử dụng',
        'icon': 'play_circle_outline',
        'color': 'blue',
      },
      {
        'title': 'Phân loại rác',
        'icon': 'delete_outline',
        'color': 'orange',
      },
      {
        'title': 'Đặt lịch thu gom',
        'icon': 'calendar_today',
        'color': 'purple',
      },
      {
        'title': 'Tìm điểm thu gom',
        'icon': 'location_on_outlined',
        'color': 'red',
      },
      {
        'title': 'Tích & đổi điểm',
        'icon': 'card_giftcard',
        'color': 'green',
      },
      {
        'title': 'Thống kê & báo cáo',
        'icon': 'bar_chart',
        'color': 'teal',
      },
    ];

    emit(HelpGuidanceLoaded(
      faqItems: faqItems,
      filteredFaqs: faqItems,
      tutorialCategories: tutorialCategories,
    ));
  }

  void _onSearchFaqs(
    SearchFaqs event,
    Emitter<HelpGuidanceState> emit,
  ) {
    developer.log('Searching FAQs with query: ${event.query}');
    
    final currentState = state;
    if (currentState is HelpGuidanceLoaded) {
      final query = event.query.toLowerCase();
      
      List<Map<String, dynamic>> filteredFaqs;
      if (query.isEmpty) {
        filteredFaqs = currentState.faqItems;
      } else {
        filteredFaqs = currentState.faqItems
            .where((faq) =>
                faq['question'].toLowerCase().contains(query) ||
                faq['answer'].toLowerCase().contains(query))
            .toList();
      }
      
      emit(currentState.copyWith(filteredFaqs: filteredFaqs));
    }
  }
} 