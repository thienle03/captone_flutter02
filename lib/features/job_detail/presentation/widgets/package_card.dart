import 'package:flutter/material.dart';

class JobPackageCard extends StatelessWidget {
  final Map<String, dynamic>? jobDetail;
  final bool hiring;
  final VoidCallback? onHire;

  const JobPackageCard({
    super.key,
    required this.jobDetail,
    required this.hiring,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    if (jobDetail == null) return const SizedBox();

    String fullDesc = jobDetail!['moTa'] ?? "";
    bool isLong = fullDesc.length > 120;
    String displayDesc = isLong ? "${fullDesc.substring(0, 120)}..." : fullDesc;

    String moTaNgan = jobDetail!['moTaNgan'] ?? "";
    List<String> packageLines =
        moTaNgan.split("\r\n").where((l) => l.trim().isNotEmpty).toList();

    String packageName = packageLines.isNotEmpty ? packageLines[0] : "Basic";
    String priceLine = packageLines.length > 1 ? packageLines[1] : "US\$0";
    List<String> features = packageLines.skip(2).toList();

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobDetail!['tenCongViec'] ?? "",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(displayDesc, style: const TextStyle(fontSize: 14)),
            if (isLong)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Mô tả chi tiết"),
                          content: SingleChildScrollView(child: Text(fullDesc)),
                        ),
                  );
                },
                child: const Text(
                  "See more",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              "Price: \$${jobDetail?['giaTien'] ?? 0}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                Flexible(
                  child: Text(
                    packageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "About: $priceLine",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  features.map((line) {
                    String textLine = line.trim();
                    Widget item;
                    if (textLine.toLowerCase().contains("day")) {
                      item = Text(
                        "Delivery Days: $textLine",
                        style: const TextStyle(fontSize: 14),
                      );
                    } else if (textLine.toLowerCase().contains("revision")) {
                      item = Text(
                        "Revisions: $textLine",
                        style: const TextStyle(fontSize: 14),
                      );
                    } else if (textLine.toLowerCase().contains("concept")) {
                      item = Text(
                        "Number of concepts included: $textLine",
                        style: const TextStyle(fontSize: 14),
                      );
                    } else {
                      item = Text(
                        textLine,
                        style: const TextStyle(fontSize: 14),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: item,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: hiring ? null : onHire,
              child:
                  hiring
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        "Continue (\$${jobDetail?['giaTien'] ?? 0})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
