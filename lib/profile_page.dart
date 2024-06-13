import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final String password;
  final String nomineeName;
  final String chitName;
  final String yourMobileNumber;
  final String nomineeMobileNumber;
  final String accountNumber;
  final String ifscCode;
  final String yourAddress;
  final String nomineeAddress;
  final String yourAadharProof;
  final String nomineeAadharProof;
  final String yourPanCard;
  final String nomineePanCard;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.nomineeName,
    required this.chitName,
    required this.yourMobileNumber,
    required this.nomineeMobileNumber,
    required this.accountNumber,
    required this.ifscCode,
    required this.yourAddress,
    required this.nomineeAddress,
    required this.yourAadharProof,
    required this.nomineeAadharProof,
    required this.yourPanCard,
    required this.nomineePanCard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Name:'),
              subtitle: Text(name),
            ),
            ListTile(
              title: const Text('Email:'),
              subtitle: Text(email),
            ),
            ListTile(
              title: const Text('Password:'),
              subtitle: Text(password),
            ),
            ListTile(
              title: const Text('Nominee Name:'),
              subtitle: Text(nomineeName),
            ),
            ListTile(
              title: const Text('Chit Name:'),
              subtitle: Text(chitName),
            ),
            ListTile(
              title: const Text('Your Mobile Number:'),
              subtitle: Text(yourMobileNumber),
            ),
            ListTile(
              title: const Text('Nominee Mobile Number:'),
              subtitle: Text(nomineeMobileNumber),
            ),
            ListTile(
              title: const Text('Account Number:'),
              subtitle: Text(accountNumber),
            ),
            ListTile(
              title: const Text('IFSC Code:'),
              subtitle: Text(ifscCode),
            ),
            ListTile(
              title: const Text('Your Address:'),
              subtitle: Text(yourAddress),
            ),
            ListTile(
              title: const Text('Nominee Address:'),
              subtitle: Text(nomineeAddress),
            ),
            ListTile(
              title: const Text('Your Aadhar Proof:'),
              subtitle: Text(yourAadharProof),
            ),
            ListTile(
              title: const Text('Nominee Aadhar Proof:'),
              subtitle: Text(nomineeAadharProof),
            ),
            ListTile(
              title: const Text('Your Pan Card:'),
              subtitle: Text(yourPanCard),
            ),
            ListTile(
              title: const Text('Nominee Pan Card:'),
              subtitle: Text(nomineePanCard),
            ),
          ],
        ),
      ),
    );
  }
}
