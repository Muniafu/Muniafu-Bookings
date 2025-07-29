import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ReceiptPdfGenerator {
  static Future<void> generateReceipt({
    required String bookingId,
    required String userId,
    required String roomId,
    required String status,
    required DateTime createdAt,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Hotel Booking Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Booking ID: $bookingId'),
              pw.Text('User ID: $userId'),
              pw.Text('Room ID: $roomId'),
              pw.Text('Status: $status'),
              pw.Text('Date: ${createdAt.toLocal()}'),
            ],
          ),
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/$bookingId.pdf");
    await file.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}