import 'package:flutter/material.dart';

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Terms & Policies",
          style: TextStyle(fontFamily: 'Poppins-SemiBold', color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF4A00E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ExpandableSection(
            title: "Introduction",
            content:
                "Welcome to our app. By accessing or using this application, you agree to the terms and conditions outlined below.",
          ),
          _ExpandableSection(
            title: "User Responsibilities",
            content:
                "You agree to use the app in a lawful manner. Any abuse, misuse, or suspicious activity may lead to account suspension.",
          ),
          _ExpandableSection(
            title: "Privacy Policy",
            content:
                "We value your privacy. Your personal data is stored securely and never shared with third parties without consent.",
          ),
          _ExpandableSection(
            title: "Refund & Cancellation",
            content:
                "Orders once placed cannot be cancelled after dispatch. Refunds are issued only if product is defective or not delivered.",
          ),
          _ExpandableSection(
            title: "Updates to Policy",
            content:
                "Our terms may be updated anytime. Continued use of the app implies your acceptance of the updated terms.",
          ),
          SizedBox(height: 24),
          Text(
            "If you have questions, please contact support through the app.",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final String content;

  const _ExpandableSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF4A00E0),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
