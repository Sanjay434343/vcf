import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'input_page.dart';

class DetailsPage extends StatefulWidget {
  final String email;
  final String password;

  const DetailsPage({super.key, required this.email, required this.password});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Query dbRef;
  Map<dynamic, dynamic>? userMap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Users').orderByChild('email').equalTo(widget.email);
    loadData();
  }

  void loadData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  UPIDetails getUPIDetails(String upiID, String userName, double dueAmount) {
    return UPIDetails(
      upiID: upiID,
      payeeName: userName,
      amount: dueAmount,
    );
  }

  void showImageBottomSheet(BuildContext context) {
    const String upiID = 'mk5383511@oksbi'; // Replace with your UPI ID
    final double dueAmount = parseToDouble(userMap!['dueAmount']); // Convert to double
    final String userName = userMap!['name'];

    final upiDetails = getUPIDetails(upiID, userName, dueAmount);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: screenWidth, // Set width to screen width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Due Amount Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Replaced Card with Text widgets
                Text(
                  'User Name: $userName',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Due Amount: $dueAmount',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Scan To Pay The Amount',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: screenWidth, // Set width to screen width
                  child: Center(
                    child: UPIPaymentQRCode(
                      upiDetails: upiDetails,
                      size: 200, // Specify the size of the QR code
                      embeddedImagePath: 'assets/icon.png', // Path to your embedded image
                      embeddedImageSize: const Size(50, 50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (await Permission.storage.request().isGranted) {
                      // Permission to access storage is granted
                      // Implement the logic to download the QR
                      // code image
                      // Example: saveImage();
                    } else {
                      // Permission to access storage is not granted
                      // Handle the situation
                      // Example: showSnackBar('Permission to access storage is required.');
                    }
                  },
                  child: const Text('Download QR Code'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double parseToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    } else {
      throw ArgumentError('Cannot convert $value to double');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VCF' , style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(245, 223, 214, 254),
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            if (userMap != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userData: userMap!)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User data is not loaded yet')),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const InputPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: Color.fromARGB(246, 29, 6, 110), // Set background color to 9381ff
              child: SizedBox(
                height: double.infinity,
                child: FirebaseAnimatedList(
                  query: dbRef,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                    userMap = snapshot.value as Map<dynamic, dynamic>?;

                    if (userMap != null && userMap!.isNotEmpty) {
                      if (userMap!['password'] == widget.password) {
                        userMap!['key'] = snapshot.key;
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              DetailCardGrid(userMap!),
                              const SizedBox(height: 20),
                              PaidDetails(email: widget.email, name: userMap!['name']),
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            const Text('Password mismatch.'),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to login page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InputPage()),
                                );
                              },
                              child: const Text('LOGIN'),
                            ),
                          ],
                        );
                      }
                    } else {
                      return const Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ),
    );
  }
}

class DetailCardGrid extends StatelessWidget {
  final Map<dynamic, dynamic> userMap;

  const DetailCardGrid(this.userMap, {super.key});

  @override
  Widget build(BuildContext context) {
    final details = [
      {'label': 'Name', 'value': userMap['name']},
      {'label': 'Due Amount', 'value': userMap['dueAmount']},
      {'label': 'Paid Amount', 'value': userMap['paidAmount']},
      {'label': 'Balance Amount', 'value': userMap['balanceAmount']},
      {'label': 'Total Amount', 'value': userMap['totalAmount']},
      {'label': 'Collection Type', 'value': userMap['ctype']},      
    ];

    return Padding(
  padding: const EdgeInsets.only(top: 20.0 , right: 2.0 , left: 2.0), // Add 20px space at the top
  child: GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 1.0, // 5px gap between cards
      mainAxisSpacing: 4.0,  // 5px gap between cards
      childAspectRatio: 1.2, // Adjust the aspect ratio to make cards wider
    ),
    itemCount: details.length,
    itemBuilder: (context, index) {
      final detail = details[index];
      return DetailCard(
        label: detail['label']!,
        value: detail['value']!,
        isDueAmount: detail['label'] == 'Due Amount',
        onPressed: () {
          if (detail['label'] == 'Due Amount') {
            showImageBottomSheet(context);
          }
        },
      );
    },
  ),
);}


  void showImageBottomSheet(BuildContext context) {
    final upiID = 'mk5383511@oksbi'; // Replace with your UPI ID
    final dueAmount = double.parse(userMap['dueAmount'].toString()); // Convert to double
    final userName = userMap['name'];

    final upiDetails = UPIDetails(
      upiID: upiID,
      payeeName: userName,
      amount: dueAmount,
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: screenWidth, // Set width to screen width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Due Details',
                  style: TextStyle(fontSize: 24,),
                ),
                const SizedBox(height: 30),
                // Replaced Card with Text widgets
                Text(
                  'User Name: $userName',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Due Amount: $dueAmount',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Scan To Pay The Amount',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: screenWidth, // Set width to screen width
                  child: Center(
                    child: UPIPaymentQRCode(
                      upiDetails: upiDetails,
                      size: 200, // Specify the size of the QR code
                      embeddedImagePath: 'assets/icon.png', // Path to your embedded image
                      embeddedImageSize: const Size(50, 50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (await Permission.storage.request().isGranted) {
                      // Permission to access storage is granted
                      // Implement the logic to download the QR
                      // code image
                      // Example: saveImage();
                    } else {
                      // Permission to access storage is not granted
                      // Handle the situation
                      // Example: showSnackBar('Permission to access storage is required.');
                    }
                  },
                  child: const Text('Download QR Code'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class DetailCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isDueAmount;
  final VoidCallback onPressed;

  const DetailCard({
    Key? key,
    required this.label,
    required this.value,
    required this.isDueAmount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.attach_money; // Default icon (can be changed based on label)

    // Assign icon based on label
    switch (label) {
      case 'Due Amount':
        iconData = Icons.pending_actions;
        break;
      case 'Paid Amount':
        iconData = Icons.payment;
        break;
      case 'Balance Amount':
        iconData = Icons.money_off;
        break;
      case 'Total Amount':
        iconData = Icons.attach_money;
        break;
      case 'Collection Type':
        iconData = Icons.abc;
        break;
      case 'Name':
        iconData = Icons.perm_identity;
        break;
      default:
        iconData = Icons.info; // Default icon
        break;
    }

    return Card(
      color: Color.fromARGB(255, 230, 227, 255),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(5.0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(iconData, size: 30, color: Colors.deepPurple), // Added icon here
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Color.fromARGB(251, 44, 34, 124)),
                ),
              ],
            ),
            if (isDueAmount)
              Positioned(
                bottom: 5,
                right: 5,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: const Text(
                    'Pay',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(134, 34, 0, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



class PaidDetails extends StatelessWidget {
  final String email;
  final String name;

  const PaidDetails({super.key, required this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    final Query paidRef = FirebaseDatabase.instance
        .ref()
        .child('Paids')
        .orderByChild('email')
        .equalTo(email);

    return FirebaseAnimatedList(
      query: paidRef,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
        final paidData = snapshot.value as Map<dynamic, dynamic>;
        if (paidData['name'] == name) {
          return PaidDetailCard(paidData: paidData);
        } else {
          return Container();
        }
      },
    );
  }
}

class PaidDetailCard extends StatelessWidget {
  final Map<dynamic, dynamic> paidData;

  const PaidDetailCard({super.key, required this.paidData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paid Amount: ${paidData['amount']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Paid Date: ${paidData['date']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Description: ${paidData['description']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
class ProfilePage extends StatelessWidget {
  final Map<dynamic, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
         backgroundColor: Color.fromARGB(245, 223, 214, 254),
      ),
      backgroundColor: Color.fromARGB(246, 29, 6, 110), // Set your desired background color here
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildProfileDetailCard('Name', userData['name'], Icons.person),
            _buildProfileDetailCard('Email', userData['email'], Icons.email),
            _buildProfileDetailCard('Nominee Name', userData['nomineeName'], Icons.person_outline),
            _buildProfileDetailCard('Chit Name', userData['chitName'], Icons.account_balance),
            _buildProfileDetailCard('Chit Type', userData['chitType'], Icons.category),
            _buildProfileDetailCard('Your Mobile Number', userData['yourMobileNumber'], Icons.phone),
            _buildProfileDetailCard('Nominee Mobile Number', userData['nomineeMobileNumber'], Icons.phone_android),
            _buildProfileDetailCard('Account Number', userData['accountNumber'], Icons.account_balance_wallet),
            _buildProfileDetailCard('IFSC Code', userData['ifscCode'], Icons.code),
            _buildProfileDetailCard('Your Address', userData['yourAddress'], Icons.home),
            _buildProfileDetailCard('Nominee Address', userData['nomineeAddress'], Icons.location_on),
            _buildProfileDetailCard('Your Aadhar Proof', userData['yourAadharProof'], Icons.credit_card),
            _buildProfileDetailCard('Nominee Aadhar Proof', userData['nomineeAadharProof'], Icons.credit_card_outlined),
            _buildProfileDetailCard('Your Pan Card', userData['yourPanCard'], Icons.credit_card),
            _buildProfileDetailCard('Nominee Pan Card', userData['nomineePanCard'], Icons.credit_card_outlined),
            _buildProfileDetailCard('Total Amount', userData['totalAmount'], Icons.attach_money),
            _buildProfileDetailCard('Balance Amount', userData['balanceAmount'], Icons.money_off),
            _buildProfileDetailCard('Paid Amount', userData['paidAmount'], Icons.payment),
            _buildProfileDetailCard('Due Amount', userData['dueAmount'], Icons.pending_actions),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Text(
              _getRandomEmoji(),
              style: TextStyle(fontSize: 40),
            ),
            backgroundColor: Color.fromARGB(255, 250, 250, 250),
          ),
          const SizedBox(height: 10),
          Text(
            userData['name'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 5),
          Text(
            userData['email'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailCard(String label, dynamic value, IconData icon) {
    return Card(
      color: Color.fromARGB(255, 230, 227, 255), // Set your desired card background color here
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueAccent),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: _buildValueWidget(value),
      ),
    );
  }

  Widget _buildValueWidget(dynamic value) {
    if (value is List || value is Map) {
      return Text(value.toString());
    } else {
      return Text(
        value.toString(),
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  String _getRandomEmoji() {
    List<String> emojis = [
      '😊', '😁', '😃', '😄', '😆', '😇', '🙂', '😉', '😌', '😍', '😘', '😗', '😙', '😚', '😋', '😜', '😝', '😛'
    ];
    final random = Random();
    int index = random.nextInt(emojis.length);
    return emojis[index];
  }
}