import 'package:flutter/material.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Frequently Asked Questions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text("What is source file?"),
            trailing: Icon(Icons.add),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("What is vector file?"),
            trailing: Icon(Icons.add),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("What is social media kit?"),
            trailing: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
