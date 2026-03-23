import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.82.159.214';

  // Helper to get token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper for headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ================= AUTH =================

  Future<http.Response> registerRider(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  Future<http.Response> loginRider(String phone, String name) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'name': name}),
    );
  }

  Future<http.Response> getProfile() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/profile'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> updateProfile(Map<String, dynamic> data) async {
    return await http.put(
      Uri.parse('$baseUrl/rider/profile'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
  }

  // ================= STATUS =================

  Future<http.Response> toggleOnlineStatus(bool isOnline) async {
    return await http.put(
      Uri.parse('$baseUrl/rider/online-status'),
      headers: await _getHeaders(),
      body: jsonEncode({'isOnline': isOnline}),
    );
  }

  Future<http.Response> updateLocation(double lat, double lng) async {
    return await http.put(
      Uri.parse('$baseUrl/rider/location'),
      headers: await _getHeaders(),
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );
  }

  // ================= ORDERS =================

  Future<http.Response> getAvailableOrders() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/orders/available'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getNearbyOrders() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/orders/nearby'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getMyDeliveries() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/orders'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getOrderDetails(String orderId) async {
    return await http.get(
      Uri.parse('$baseUrl/rider/orders/$orderId'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> acceptOrder(String orderId) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/orders/$orderId/accept'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> updateOrderStatus(String orderId, String status) async {
    return await http.put(
      Uri.parse('$baseUrl/rider/orders/$orderId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
  }

  Future<http.Response> markPickedUp(String orderId) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/orders/$orderId/picked-up'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> markDelivered(String orderId) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/orders/$orderId/delivered'),
      headers: await _getHeaders(),
    );
  }

  // ================= EARNINGS =================

  Future<http.Response> getEarnings() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/earnings'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getDailyEarnings() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/earnings/daily'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getWeeklyEarnings() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/earnings/weekly'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getMonthlyEarnings() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/earnings/monthly'),
      headers: await _getHeaders(),
    );
  }

  // ================= WALLET =================

  Future<http.Response> getWallet() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/wallet'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> getWithdrawalHistory() async {
    return await http.get(
      Uri.parse('$baseUrl/rider/withdrawals'),
      headers: await _getHeaders(),
    );
  }

  Future<http.Response> requestWithdrawal(double amount) async {
    return await http.post(
      Uri.parse('$baseUrl/rider/withdrawals'),
      headers: await _getHeaders(),
      body: jsonEncode({'amount': amount}),
    );
  }
}
