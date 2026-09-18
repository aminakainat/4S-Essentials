import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  static Future<void> generateAndShareInvoice({
    required String orderId,
    required String userName,
    required List<dynamic> items,
    required String totalPrice,
    required String paymentMethod,
    String? address,
    double discount = 0.0,
    double packagingFee = 0.0,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '4S ESSENTIALS',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#B9937E'),
                          ),
                        ),
                        pw.Text('Premium Jewelry Store', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Order ID: #$orderId', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Customer details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text(userName),
                        if (address != null) pw.Container(width: 200, child: pw.Text(address, style: const pw.TextStyle(fontSize: 9))),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Payment Info:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text('Method: $paymentMethod'),
                        pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  color: PdfColor.fromHex('#B9937E'),
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Item Description', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Container(width: 80, child: pw.Text('Qty', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Container(width: 80, child: pw.Text('Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),

                // Table Items
                pw.ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map<String, dynamic>;
                    final name = item['name'] ?? '';
                    final qty = item['qty'] ?? 1;
                    final price = item['price'] ?? '';

                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(child: pw.Text(name)),
                          pw.Container(width: 80, child: pw.Text('$qty', textAlign: pw.TextAlign.right)),
                          pw.Container(width: 80, child: pw.Text(price, textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    );
                  },
                ),
                pw.SizedBox(height: 30),

                // Summary
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal', totalPrice),
                        if (discount > 0) _summaryRow('Discount', '-\$${discount.toStringAsFixed(2)}'),
                        if (packagingFee > 0) _summaryRow('Gift Packaging', '+\$${packagingFee.toStringAsFixed(2)}'),
                        pw.Divider(color: PdfColors.grey400),
                        _summaryRow('Total Paid', totalPrice, isBold: true),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),
                // Footer
                pw.Center(
                  child: pw.Text('Thank you for shopping with 4S Essentials!', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save and Share the PDF
    final Uint8List bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'invoice_$orderId.pdf');
  }

  static pw.Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}
