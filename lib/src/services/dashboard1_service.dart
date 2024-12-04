import 'dart:convert';
// import 'package:http/http.dart' as http;

class DashboardService1 {
  // Mock data
  final List<Map<String, dynamic>> mockData = [
    {
      "id": 1,
      "user_id": 101,
      "owner_id": 202,
      "store_id": 3030,
      "store_logo": "https://example.com/store-logo1.png",
      "store_name": "Store One",
      "video_id": 5001,
      "video_status": "pending",
      "video_amount": 100,
      "user_hire_status": 0,
      "payment_link": "https://example.com/payment-link1",
      "payment_status": "unpaid",
      "created_at": "2024-11-28T12:34:56",
      "updated_at": "2024-11-28T12:34:56"
    },
    {
      "id": 2,
      "user_id": 102,
      "owner_id": 203,
      "store_id": 3031,
      "store_logo": "https://example.com/store-logo2.png",
      "store_name": "Store Two",
      "video_id": 5002,
      "video_status": "approved",
      "video_amount": 150,
      "user_hire_status": 1,
      "payment_link": "https://example.com/payment-link2",
      "payment_status": "paid",
      "created_at": "2024-11-28T14:10:12",
      "updated_at": "2024-11-28T14:10:12"
    },
    {
      "id": 3,
      "user_id": 103,
      "owner_id": 204,
      "store_id": 3032,
      "store_logo": "https://example.com/store-logo3.png",
      "store_name": "Store Three",
      "video_id": 5003,
      "video_status": "rejected",
      "video_amount": 0,
      "user_hire_status": 0,
      "payment_link": null,
      "payment_status": "failed",
      "created_at": "2024-11-28T16:21:00",
      "updated_at": "2024-11-28T16:21:00"
    }
  ];

  // Function to fetch data (using mock data for now)
  Future<List<StoreData>> fetchDashboardData({int page = 1}) async {
    // Comment out the actual API request
    // final response = await http.get(Uri.parse(apiUrl));

    // Simulate delay for mock data
    await Future.delayed(Duration(seconds: 2));

    // Returning mock data instead of API response
    List jsonResponse = mockData;
    return jsonResponse.map((data) => StoreData.fromJson(data)).toList();
  }
}

class StoreData {
  final int id;
  final int userId;
  final int ownerId;
  final int storeId;
  final String storeLogo;
  final String storeName;
  final int videoId;
  final String videoStatus;
  final double videoAmount;
  final int userHireStatus;
  final String? paymentLink;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;

  StoreData({
    required this.id,
    required this.userId,
    required this.ownerId,
    required this.storeId,
    required this.storeLogo,
    required this.storeName,
    required this.videoId,
    required this.videoStatus,
    required this.videoAmount,
    required this.userHireStatus,
    required this.paymentLink,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      id: json['id'],
      userId: json['user_id'],
      ownerId: json['owner_id'],
      storeId: json['store_id'],
      storeLogo: json['store_logo'],
      storeName: json['store_name'],
      videoId: json['video_id'],
      videoStatus: json['video_status'],
      videoAmount: json['video_amount'].toDouble(),
      userHireStatus: json['user_hire_status'],
      paymentLink: json['payment_link'],
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
