import 'package:flutter/material.dart';
import 'dart:io';

class UserController extends ChangeNotifier {
  // Personal Info
  String name = "John Doe";
  String phone = "+91 9876543210";
  File? profilePic;
  String? profileImageUrl; // remote URL stored after upload
  String aadhaarNumber = "";
  File? aadhaarPic;
  String panNumber = "";
  File? panPic;

  // Vehicle Info
  String vehicleNumber = "";
  File? vehiclePic;
  File? rcPic;
  File? platePic;
  
  // Driving Info
  String licenseNumber = "";
  File? licensePic;

  // Payout / Bank Details
  String bankAccountNumber = "";
  String withdrawalFrequency = "Weekly";
  String emergencyWithdrawalPeriod = "3 Days";
  double currentBalance = 0.0;

  void updateUserData({
    String? newName,
    String? newPhone,
    File? newProfilePic,
    String? newProfileImageUrl,
    String? newAadhaar,
    File? newAadhaarPic,
    String? newPan,
    File? newPanPic,
    String? newVehicleNumber,
    File? newVehiclePic,
    File? newRcPic,
    File? newPlatePic,
    String? newLicense,
    File? newLicensePic,
    String? newBankAcc,
    String? newFreq,
    String? newEmergency,
  }) {
    if (newName != null) name = newName;
    if (newPhone != null) phone = newPhone;
    if (newProfilePic != null) profilePic = newProfilePic;
    if (newProfileImageUrl != null) profileImageUrl = newProfileImageUrl;
    if (newAadhaar != null) aadhaarNumber = newAadhaar;
    if (newAadhaarPic != null) aadhaarPic = newAadhaarPic;
    if (newPan != null) panNumber = newPan;
    if (newPanPic != null) panPic = newPanPic;
    if (newVehicleNumber != null) vehicleNumber = newVehicleNumber;
    if (newVehiclePic != null) vehiclePic = newVehiclePic;
    if (newRcPic != null) rcPic = newRcPic;
    if (newPlatePic != null) platePic = newPlatePic;
    if (newLicense != null) licenseNumber = newLicense;
    if (newLicensePic != null) licensePic = newLicensePic;
    if (newBankAcc != null) bankAccountNumber = newBankAcc;
    if (newFreq != null) withdrawalFrequency = newFreq;
    if (newEmergency != null) emergencyWithdrawalPeriod = newEmergency;
    
    notifyListeners();
  }

  void addEarnings(double amount) {
    currentBalance += amount;
    notifyListeners();
  }
}

final userController = UserController();
