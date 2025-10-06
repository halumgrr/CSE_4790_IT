import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              // Stack allows overlapping widgets
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Main card content (background)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Top GREEN section - Logo + University Name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF003433),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                // color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Image(
                                image: AssetImage('assets/images/iut_logo.png'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // University Name
                            const Text(
                              'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 85), // Space for top half of photo
                          ],
                        ),
                      ),
                      
                      // 2. Middle LIGHT section - Student Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 95, // Space for bottom half of photo
                          left: 25,
                          right: 25,
                          bottom: 25,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            
                            // Student ID
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.vpn_key,
                                  color: Color(0xFF003433),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Student ID',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 250,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003433),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2d9cdb),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    '210041156',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 18),
                            
                            // Student Name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFF003433),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Student Name',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text(
                                'TAHSINUL ISLAM RUPOM',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003433),
                                ),
                              ),
                            
                            const SizedBox(height: 15),
                            
                            // Program
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.school, color: Color(0xFF003433), size: 22),
                                  const SizedBox(width: 8),
                                  RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Program ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF003433),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'B.Sc. in CSE', // bold part
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003433),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            
                            const SizedBox(height: 12),
                            
                            // Department
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.account_balance, color: Color(0xFF003433), size: 22),
                                const SizedBox(width: 8),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Department ', 
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF003433),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'CSE',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF003433),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            
                            const SizedBox(height: 12),
                            
                            // Location
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFF003433),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Bangladesh',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF003433),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // 3. Bottom GREEN section - Footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xFF003433),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'A subsidiary organ of OIC',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  
                  // OVERLAPPING PHOTO - Positioned on top
                  Positioned(
                    top: 165,
                    child: Container(
                      width: 140,
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF003433),
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/cat_dp.webp',
                          fit: BoxFit.cover,
                          width: 140,
                          height: 170,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}