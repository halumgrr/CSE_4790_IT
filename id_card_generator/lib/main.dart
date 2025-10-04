import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IDCardForm(),
    );
  }
}

// StatefulWidget - can change over time
class IDCardForm extends StatefulWidget {
  const IDCardForm({super.key});

  @override
  IDCardFormState createState() => IDCardFormState();
}

// State class - holds the changing data
class IDCardFormState extends State<IDCardForm> {
  // Controllers to get text from input fields
  TextEditingController studentIdController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  TextEditingController programController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  
  // Variable to track if we should show the card
  bool showCard = false;
  
  // Variable to store selected image file
  File? selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  
  // Variables for customization
  Color cardBackgroundColor = Colors.white;
  List<String> fontFamilies = ['Roboto', 'Arial', 'Times New Roman', 'Courier New', 'Georgia'];
  String currentFontFamily = 'Roboto';
  List<Color> backgroundColors = [Colors.white, Colors.blue[50]!, Colors.green[50]!, Colors.orange[50]!, Colors.purple[50]!, Colors.pink[50]!];
  int currentColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('IUT ID Card Generator'),
        backgroundColor: const Color(0xFF003433),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // If showCard is false, show the form
              // If showCard is true, show the card
              if (!showCard) ...[
                // INPUT FORM SECTION
                const Text(
                  'Enter Student Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003433),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Student ID input
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'e.g., 210041156',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key, color: Color(0xFF003433)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                
                // Student Name input
                TextField(
                  controller: studentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    hintText: 'e.g., TAHSINUL ISLAM RUPOM',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF003433)),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 15),
                
                // Program input
                TextField(
                  controller: programController,
                  decoration: const InputDecoration(
                    labelText: 'Program',
                    hintText: 'e.g., B.Sc. in CSE',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school, color: Color(0xFF003433)),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Department input
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    hintText: 'e.g., CSE',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance, color: Color(0xFF003433)),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 15),
                
                // Country input
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'e.g., Bangladesh',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on, color: Color(0xFF003433)),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Image selection area
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF003433), width: 2),
                    borderRadius: BorderRadius.circular(10),
                    color: selectedImageFile != null ? Colors.green[50] : Colors.grey[200],
                  ),
                  child: selectedImageFile != null
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              const Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Photo Selected!',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              selectedImageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImageFile!, 
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImageFile = null;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                ),
                                child: const Text('Remove Photo', style: TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 60,
                              color: Color(0xFF003433),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Add Student Photo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    selectedImageFile = File(image.path);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Photo selected successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003433),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              ),
                              child: const Text('Select Photo'),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 30),
                
                // Generate Card button
                ElevatedButton(
                  onPressed: () {
                    // Check if all fields are filled
                    if (studentIdController.text.isEmpty ||
                        studentNameController.text.isEmpty ||
                        programController.text.isEmpty ||
                        departmentController.text.isEmpty ||
                        countryController.text.isEmpty) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields!'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (selectedImageFile == null) {
                      // Show error for missing photo
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Please select a photo!'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      // Show the card
                      setState(() {
                        showCard = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003433),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Generate ID Card',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // ID CARD DISPLAY SECTION (Your original design)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 350,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
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
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Image(
                                    image: AssetImage('assets/images/iut_logo.png'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // University Name
                                Text(
                                  'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontFamily: currentFontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 85),
                              ],
                            ),
                          ),
                          
                          // 2. Middle WHITE section - Student Details (DYNAMIC DATA)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              top: 95,
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
                                
                                // Student ID - DYNAMIC
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
                                        fontFamily: currentFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
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
                                      Text(
                                        studentIdController.text,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: currentFontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 18),
                                
                                // Student Name - DYNAMIC
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
                                        fontFamily: currentFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  studentNameController.text,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF003433),
                                    fontFamily: currentFontFamily,
                                  ),
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Program - DYNAMIC
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.school, color:Color(0xFF003433), size: 22),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Program ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF003433),
                                              fontFamily: currentFontFamily,
                                            ),
                                          ),
                                          TextSpan(
                                            text: programController.text,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF003433),
                                              fontFamily: currentFontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Department - DYNAMIC
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.account_balance, color:Color(0xFF003433), size: 22),
                                    const SizedBox(width: 8),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Department ', 
                                            style: TextStyle(
                                              fontSize: 15,
                                              color:Color(0xFF003433),
                                              fontFamily: currentFontFamily,
                                            ),
                                          ),
                                          TextSpan(
                                            text: departmentController.text,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF003433),
                                              fontFamily: currentFontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Location - DYNAMIC
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF003433),
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      countryController.text,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF003433),
                                        fontFamily: currentFontFamily,
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
                            child: Text(
                              'A subsidiary organ of OIC',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                                fontFamily: currentFontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      
                      // OVERLAPPING PHOTO - DYNAMIC
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
                          child: selectedImageFile != null
                              ? Image.file(
                                  selectedImageFile!,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 170,
                                )
                              : Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[300],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                    
                    // Customization buttons on the right
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        // Background color button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentColorIndex = (currentColorIndex + 1) % backgroundColors.length;
                              cardBackgroundColor = backgroundColors[currentColorIndex];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003433),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.palette, size: 20),
                              SizedBox(height: 5),
                              Text('Change\nBG Color', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Font randomizer button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentFontFamily = fontFamilies[(fontFamilies.indexOf(currentFontFamily) + 1) % fontFamilies.length];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003433),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.font_download, size: 20),
                              SizedBox(height: 5),
                              Text('Change\nFont', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Edit button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showCard = false;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003433),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Reset button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showCard = false;
                          studentIdController.clear();
                          studentNameController.clear();
                          programController.clear();
                          departmentController.clear();
                          countryController.clear();
                          selectedImageFile = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Form reset successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    studentIdController.dispose();
    studentNameController.dispose();
    programController.dispose();
    departmentController.dispose();
    countryController.dispose();
    super.dispose();
  }
}