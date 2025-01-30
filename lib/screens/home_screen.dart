import 'package:chat_application/main.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/api/apis.dart';
import 'package:chat_application/screens/auth/login_screen.dart';
import 'package:chat_application/screens/chat_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController boyNameController = TextEditingController();
  final TextEditingController girlNameController = TextEditingController();
  DateTime? boyDOB;
  DateTime? girlDOB;

  void calculateMatch() {
    String boyName = boyNameController.text.trim().toLowerCase();
    String girlName = girlNameController.text.trim().toLowerCase();

    if (boyName == 'nimil' && girlName == 'doshi') {
      if (Apis.auth.currentUser != null) {
        clearFields();
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatHomeScreen()));
      } else {
        clearFields();
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      int score = calculateKundliMatch(boyName, boyDOB, girlName, girlDOB);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Match Result'),
          content: Text('Match Score: $score/32'),
          actions: [
            TextButton(
              onPressed: () {
                clearFields();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void clearFields() {
    boyNameController.clear();
    girlNameController.clear();
    setState(() {
      boyDOB = null;
      girlDOB = null;
    });
  }

  int calculateKundliMatch(String boyName, DateTime? boyDOB, String girlName, DateTime? girlDOB) {
    // Mock implementation of Kundli matching logic
    // In a real application, replace this with actual Kundli matching logic
    if (boyDOB == null || girlDOB == null) return 0;

    int nameScore = (boyName.length + girlName.length) % 32;
    int dobScore = ((boyDOB.day + boyDOB.month + boyDOB.year) -
            (girlDOB.day + girlDOB.month + girlDOB.year))
        .abs() % 32;

    return (nameScore + dobScore) % 32;
  }

  Future<void> selectDate(BuildContext context, bool isBoy) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != (isBoy ? boyDOB : girlDOB)) {
      setState(() {
        if (isBoy) {
          boyDOB = picked;
        } else {
          girlDOB = picked;
        }
      });
    }
  }

  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void showUnderMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Under Maintenance'),
        content: const Text('This feature is currently under maintenance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Astro Match'),
          backgroundColor: Colors.orange,
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'images/icon.png',
                          height: mq.height * 0.30,
                          width: mq.width * 0.6,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Boy’s Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: boyNameController,
                          decoration: const InputDecoration(
                            labelText: "Enter Boy's Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => selectDate(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                boyDOB == null
                                    ? 'Select Date of Birth'
                                    : 'DOB: ${boyDOB!.day}/${boyDOB!.month}/${boyDOB!.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.calendar_today, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Girl’s Details',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: girlNameController,
                          decoration: const InputDecoration(
                            labelText: "Enter Girl's Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => selectDate(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                girlDOB == null
                                    ? 'Select Date of Birth'
                                    : 'DOB: ${girlDOB!.day}/${girlDOB!.month}/${girlDOB!.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.calendar_today, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: calculateMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: const Text(
                        'Match',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.orange),
              label: 'Kundli Match',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Kundli',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Horoscope',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'Information',
            ),
          ],
          onTap: (index) {
            if (index != 0) {
              showUnderMaintenanceDialog();
            }
          },
        ),
      ),
    );
  }
}
