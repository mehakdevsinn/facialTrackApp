import 'package:flutter/material.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop: false, // Yeh back button ko fully disable kar deta hai
    onPopInvokedWithResult: (didPop, result) {
      // Agar back button dabaya jaye toh yahan kuch na likhen
      // Isse screen pop nahi hogi aur na hi koi dialog aayega
      if (didPop) return;
    },
      child: Scaffold(
        // This ensures the light blue color is the base for the whole screen
        // backgroundColor: Colors.blue.shade50, 
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              // Content below the profile card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildOverviewCard(),
                    const SizedBox(height: 20),
                    _buildSubjectsCard(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 40), // Extra space at bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 1. Dark Blue Background (Top Section)
        Container(
          height: 220, // Reduced height to fix the "distance"
          width: double.infinity,
          color: const Color.fromARGB(255, 35, 4, 170),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 12,left: 15),
                    child: Text("Teacher Profile", 
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),

        // 2. The White Card with Profile Details
        // We use Padding to push it down so it overlaps the blue
        Container(
          margin: const EdgeInsets.only(top: 160), // Adjust this to control the overlap
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 70), // Space for the floating image
              const Text("Dr. Anya Sharma", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("ID: TCH-2025-014", 
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 3. Profile Image (Floating)
        Positioned(
          top: 100, // Positioned exactly between blue and white sections
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
              ]
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFE0E0FF), // Placeholder light purple
              backgroundImage: AssetImage('assets/profile.png'), 
            ),
          ),
        ),
      ],
    );
  }

  // --- Keep your existing _buildOverviewCard, _buildSubjectsCard, etc. below ---
  
  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _rowInfo(Icons.group, "Subjects assigned", "4", Colors.green),
          const Divider(height: 30),
          _rowInfo(Icons.access_time, "Total classes handled", "312", Colors.green),
        ],
      ),
    );
  }

  Widget _buildSubjectsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Subjects Assigned", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _subjectTile(Icons.book, "Computer Science", "BSCS - Semester 5", Colors.blue),
          const Divider(),
          _subjectTile(Icons.menu_book, "Data Structures", "BSCS - Semester 5", Colors.green),
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade400),
        const SizedBox(width: 15),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _subjectTile(IconData icon, String title, String subtitle, Color iconColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, color: Colors.white,),
      label: const Text("Logout"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF7043),
        foregroundColor: Colors.white,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
    );
  }
}
// import 'package:flutter/material.dart';

// class TeacherProfileScreen extends StatelessWidget {
//   const TeacherProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // This ensures the light blue color is the base for the whole screen
//       backgroundColor: Colors.blue.shade50, 
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildHeader(context),
//             // Content below the profile card
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   _buildOverviewCard(),
//                   const SizedBox(height: 20),
//                   _buildSubjectsCard(),
//                   const SizedBox(height: 30),
//                   _buildLogoutButton(),
//                   const SizedBox(height: 40), // Extra space at bottom
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Stack(
//       alignment: Alignment.topCenter,
//       children: [
//         // 1. Dark Blue Background (Top Section)
//         Container(
//           height: 220, // Reduced height to fix the "distance"
//           width: double.infinity,
//           color: const Color(0xFF1A4789),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
//                   const Padding(
//                     padding: EdgeInsets.only(top: 12),
//                     child: Text("Teacher Profile", 
//                       style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   IconButton(icon: const Icon(Icons.settings, color: Colors.white), onPressed: () {}),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // 2. The White Card with Profile Details
//         // We use Padding to push it down so it overlaps the blue
//         Container(
//           margin: const EdgeInsets.only(top: 160), // Adjust this to control the overlap
//           width: double.infinity,
//           decoration:  BoxDecoration(
//             color: Colors.blue[50],
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(40),
//               topRight: Radius.circular(40),
//             ),
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 70), // Space for the floating image
//               const Text("Dr. Anya Sharma", 
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               Text("ID: TCH-2025-014", 
//                 style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),

//         // 3. Profile Image (Floating)
//         Positioned(
//           top: 100, // Positioned exactly between blue and white sections
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 4),
//               boxShadow: [
//                 BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
//               ]
//             ),
//             child: const CircleAvatar(
//               radius: 60,
//               backgroundColor: Color(0xFFE0E0FF), // Placeholder light purple
//               // backgroundImage: AssetImage('assets/profile.png'), 
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // --- Keep your existing _buildOverviewCard, _buildSubjectsCard, etc. below ---
  
//   Widget _buildOverviewCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           _rowInfo(Icons.group, "Subjects assigned", "4", Colors.green),
//           const Divider(height: 30),
//           _rowInfo(Icons.access_time, "Total classes handled", "312", Colors.green),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectsCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Subjects Assigned", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 15),
//           _subjectTile(Icons.book, "Computer Science", "BSCS - Semester 5", Colors.blue),
//           const Divider(),
//           _subjectTile(Icons.menu_book, "Data Structures", "BSCS - Semester 5", Colors.green),
//         ],
//       ),
//     );
//   }

//   Widget _rowInfo(IconData icon, String title, String value, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.green.shade400),
//         const SizedBox(width: 15),
//         Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
//         const Spacer(),
//         Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _subjectTile(IconData icon, String title, String subtitle, Color iconColor) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//         child: Icon(icon, color: iconColor),
//       ),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//       subtitle: Text(subtitle),
//       trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//     );
//   }

//   Widget _buildLogoutButton() {
//     return ElevatedButton.icon(
//       onPressed: () {},
//       icon: const Icon(Icons.logout),
//       label: const Text("Logout"),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.orange.shade700,
//         foregroundColor: Colors.white,
//         minimumSize: const Size(200, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//     );
//   }

//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
//     );
//   }
// }