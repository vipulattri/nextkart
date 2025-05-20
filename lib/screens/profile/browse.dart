import 'package:flutter/material.dart';

class Browse extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How can I reset my password?',
      'answer':
          'Go to settings > Account > Reset Password and follow the steps.',
    },
    {
      'question': 'How do I track my orders?',
      'answer':
          'Visit My Orders from the bottom navigation to track your recent orders.',
    },
    {
      'question': 'Can I return a product?',
      'answer': 'Yes, within 7 days of delivery if it meets our return policy.',
    },
    {
      'question': 'Is my payment information secure?',
      'answer':
          'Absolutely! We use industry-standard encryption to keep your data safe.',
    },
    {
      'question': 'Is Your Company Legal In India?',
      'answer':
          'Absolutely! Safe Its a Ecommerce Indian comapany U dont Worry About it.',
    },
  ];

  Browse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Browse FAQs",
          style: TextStyle(fontFamily: 'Poppins-SemiBold', color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
      body: ListView.builder(
        itemCount: faqs.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return FAQBox(question: faq['question']!, answer: faq['answer']!);
        },
      ),
    );
  }
}

class FAQBox extends StatefulWidget {
  final String question;
  final String answer;

  const FAQBox({super.key, required this.question, required this.answer});

  @override
  // ignore: library_private_types_in_public_api
  _FAQBoxState createState() => _FAQBoxState();
}

class _FAQBoxState extends State<FAQBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF4A00E0),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.black,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.answer, style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
