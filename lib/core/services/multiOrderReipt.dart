import 'dart:typed_data';
import 'package:apx_cars_repair/features/cases/data/models/OrderDetailModel.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// ==================== نماذج البيانات (إيصال متعدد الطلبات) ====================

/// كل صف في الجدول يمثل طلب واحد (سيارة واحدة) قام بها العميل.
class ReceiptOrderRow {
  final String vin;
  final String year;
  final String brand;
  final String model;

  // الخدمات المنجزة ضمن هذا الطلب
  final List<GlobalOrderDetailModel> qty;

  // المبلغ المدفوع لهذا الطلب
  final double amount;

  ReceiptOrderRow({
    required this.vin,
    required this.year,
    required this.brand,
    required this.model,
    required this.qty,
    required this.amount,
  });
}

class MultiOrderReceiptData {
  final String receiptNumber;

  // نطاق التاريخ: من أقدم طلب إلى أحدث طلب
  final String dateFrom;
  final String dateTo;

  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;

  final List<ReceiptOrderRow> orders;

  final String technicianNotes;

  final String footerNote;

  final double labor;
  final double parts;
  final double taxRate;

  MultiOrderReceiptData({
    required this.receiptNumber,
    required this.dateFrom,
    required this.dateTo,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    required this.orders,
    this.technicianNotes = '',
    this.footerNote =
        'Thank you for your payment. This receipt confirms that payment has been received in full for the services listed above. Parts carry a 12-month / 12,000-mile warranty; labor carries a 90-day warranty.',
    this.labor = 0,
    this.parts = 0,
    this.taxRate = 0,
  });

  double get subtotal =>
      orders.fold(0.0, (sum, o) => sum + o.amount) + labor + parts;

  double get tax => subtotal * taxRate;

  double get total => subtotal + tax;
}

// ==================== ألوان التصميم ====================

class _ReceiptColors {
  static const bg = PdfColor.fromInt(0xFFFFFFFF);
  static const lightHeader = PdfColor.fromInt(0xFFe8e6df);
  static const orange = PdfColor.fromInt(0xFFd97a3f);
  static const black = PdfColors.black;
  static const grayText = PdfColor.fromInt(0xFF9b9a94);
  static const border = PdfColor.fromInt(0xFF3a3a38);
  static const totalBg = PdfColor.fromInt(0xFFf0eee7);
}

// ==================== دالة توليد PDF ====================

Future<Uint8List> generateMultiOrderReceiptPdf(
  MultiOrderReceiptData data,
) async {
  final pdf = pw.Document();

  final imageData = await rootBundle.load('assets/appIcon/theGiest.jpeg');

  final logoImage = pw.MemoryImage(imageData.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: _ReceiptColors.bg,
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(data, logoImage),

              pw.SizedBox(height: 14),

              pw.Divider(color: _ReceiptColors.border, thickness: 1),

              pw.SizedBox(height: 14),

              _buildCustomerBox(data),

              pw.SizedBox(height: 16),

              _buildOrdersTable(data),

              pw.SizedBox(height: 16),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(flex: 3, child: _buildTechnicianNotes(data)),

                  pw.SizedBox(width: 14),

                  pw.Expanded(flex: 2, child: _buildTotalsBox(data)),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

// ==================== الأقسام ====================

pw.Widget _buildHeader(MultiOrderReceiptData data, pw.MemoryImage logoImage) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Row(
        children: [
          pw.Container(
            width: 46,
            height: 46,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _ReceiptColors.black, width: 1.2),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Image(
                logoImage,
                width: 32,
                height: 32,
                fit: pw.BoxFit.contain,
              ),
            ),
          ),

          pw.SizedBox(width: 12),

          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'The Geist LLC',
                style: pw.TextStyle(
                  color: _ReceiptColors.black,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 2),

              pw.Text(
                'AUTOMOTIVE ELECTRICAL SERVICES',
                style: pw.TextStyle(
                  color: _ReceiptColors.orange,
                  fontSize: 8,
                  letterSpacing: 1.2,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                'Phone (317) 516-9700 · saifaldinsami@gmail.com',
                style: pw.TextStyle(
                  color: _ReceiptColors.grayText,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),

      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'Payment Receipt',
            style: pw.TextStyle(
              color: _ReceiptColors.black,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            'RECEIPT NO. ${data.receiptNumber}',
            style: pw.TextStyle(color: _ReceiptColors.grayText, fontSize: 9),
          ),

          pw.Text(
            'Services from ${data.dateFrom} to ${data.dateTo}',
            style: pw.TextStyle(color: _ReceiptColors.grayText, fontSize: 9),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _sectionHeaderBar(String title) {
  return pw.Container(
    width: double.infinity,
    color: _ReceiptColors.lightHeader,
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}

pw.Widget _fieldBlock(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: _ReceiptColors.grayText,
            fontSize: 7,
            letterSpacing: 0.8,
          ),
        ),

        pw.SizedBox(height: 2),

        pw.Text(
          value.isEmpty ? ' ' : value,
          style: pw.TextStyle(color: _ReceiptColors.black, fontSize: 11),
        ),

        pw.SizedBox(height: 4),

        pw.Divider(color: _ReceiptColors.border, thickness: 0.6),
      ],
    ),
  );
}

pw.Widget _buildCustomerBox(MultiOrderReceiptData data) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _ReceiptColors.border, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeaderBar('RECEIVED FROM'),

        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _fieldBlock('NAME', data.customerName)),

              pw.SizedBox(width: 14),

              pw.Expanded(child: _fieldBlock('PHONE', data.customerPhone)),

              pw.SizedBox(width: 20),

              pw.Expanded(child: _fieldBlock('EMAIL', data.customerEmail)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================== جدول السيارات والخدمات ====================

pw.Widget _buildOrdersTable(MultiOrderReceiptData data) {
  final headerStyle = pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold);

  final rowStyle = pw.TextStyle(color: _ReceiptColors.black, fontSize: 8.5);

  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _ReceiptColors.lightHeader),
      children: [
        _tableCell('#', headerStyle, isHeader: true),

        _tableCell('VIN / VEHICLE', headerStyle, isHeader: true),

        _tableCell(
          'SERVICE',
          headerStyle,
          isHeader: true,
          align: pw.Alignment.center,
        ),

        _tableCell(
          'AMOUNT PAID',
          headerStyle,
          isHeader: true,
          align: pw.Alignment.centerRight,
        ),
      ],
    ),
  ];

  for (int i = 0; i < data.orders.length; i++) {
    final o = data.orders[i];

    // إذا لم توجد خدمات
    if (o.qty.isEmpty) {
      rows.add(
        pw.TableRow(
          children: [
            _tableCell((i + 1).toString().padLeft(2, '0'), rowStyle),

            _tableCell('${o.vin} ${o.year} ${o.brand} ${o.model}', rowStyle),

            _tableCell('', rowStyle),

            _tableCell(
              '\$${o.amount.toStringAsFixed(0)}',
              rowStyle,
              align: pw.Alignment.centerRight,
            ),
          ],
        ),
      );

      continue;
    }

    // كل خدمة = Row مستقل
    for (int serviceIndex = 0; serviceIndex < o.qty.length; serviceIndex++) {
      final detail = o.qty[serviceIndex];

      final serviceName =
          detail.service?.description ?? detail.item?.itemDescription ?? '';

      rows.add(
        pw.TableRow(
          children: [
            _tableCell(
              serviceIndex == 0 ? (i + 1).toString().padLeft(2, '0') : '',
              rowStyle,
            ),

            _tableCell(
              serviceIndex == 0
                  ? '${o.vin} ${o.year} ${o.brand} ${o.model}'
                  : '',
              rowStyle,
            ),

            _tableCell(serviceName, rowStyle),

            _tableCell(
              '\$${(detail.cost ?? 0).toStringAsFixed(0)}',
              rowStyle,
              align: pw.Alignment.centerRight,
            ),
          ],
        ),
      );
    }
  }

  return pw.Table(
    border: pw.TableBorder.all(color: _ReceiptColors.border, width: 0.6),
    columnWidths: {
      0: const pw.FixedColumnWidth(30),
      1: const pw.FlexColumnWidth(3), // VIN
      2: const pw.FlexColumnWidth(2), // SERVICE
      3: const pw.FixedColumnWidth(65),
    },
    children: rows,
  );
}

pw.Widget _tableCell(
  String text,
  pw.TextStyle style, {
  bool isHeader = false,
  pw.Alignment align = pw.Alignment.centerLeft,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: pw.Align(
      alignment: align,
      child: pw.Text(text, style: style),
    ),
  );
}

pw.Widget _buildTechnicianNotes(MultiOrderReceiptData data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'TECHNICIAN NOTES',
        style: pw.TextStyle(
          color: _ReceiptColors.grayText,
          fontSize: 8,
          letterSpacing: 0.8,
        ),
      ),

      pw.SizedBox(height: 6),

      pw.Container(
        height: 130,
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _ReceiptColors.border, width: 0.7),
        ),
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          data.technicianNotes,
          style: pw.TextStyle(color: _ReceiptColors.black, fontSize: 9),
        ),
      ),

      pw.SizedBox(height: 8),

      pw.Text(
        data.footerNote,
        style: pw.TextStyle(color: _ReceiptColors.grayText, fontSize: 7.5),
      ),
    ],
  );
}

pw.Widget _buildTotalsBox(MultiOrderReceiptData data) {
  pw.Widget row(String label, String value, {bool isBold = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _ReceiptColors.border, width: 0.6),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: _ReceiptColors.grayText,
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),

          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ReceiptColors.black,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _ReceiptColors.border, width: 0.7),
    ),
    child: pw.Column(
      children: [
        row(
          'LABOR',
          data.labor > 0 ? '\$${data.labor.toStringAsFixed(2)}' : '',
        ),

        row(
          'PARTS',
          data.parts > 0 ? '\$${data.parts.toStringAsFixed(2)}' : '',
        ),

        row('SUBTOTAL', '\$${data.subtotal.toStringAsFixed(2)}'),

        row('TAX', data.tax > 0 ? '\$${data.tax.toStringAsFixed(2)}' : ''),

        pw.Container(
          color: _ReceiptColors.totalBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL PAID \$${data.total.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================== دالة الإرسال ====================

Future<bool> sendMultiOrderReceiptEmail({
  required String toEmail,
  required String customerName,
  required String receiptId,
  required MultiOrderReceiptData receiptData,
  String? ccEmail,
}) async {
  final smtpServer = gmail('alifouaad24@gmail.com', 'tdhhwaczycgqemmh');

  final pdfBytes = await generateMultiOrderReceiptPdf(receiptData);

  final message = Message()
    ..from = const Address('alifouaad24@gmail.com', 'The Geist')
    ..recipients.add(toEmail)
    ..subject = 'Payment Receipt #$receiptId'
    ..text =
        'Dear $customerName,\n\nThank you for your payment. Please find attached your payment receipt for the services completed.\n\nThe Geist LLC'
    ..attachments = [
      StreamAttachment(
        Stream.fromIterable([pdfBytes]),
        'application/pdf',
        fileName: 'receipt_$receiptId.pdf',
      ),
    ];
  if (ccEmail != null && ccEmail.trim().isNotEmpty) {
    message.ccRecipients.add(ccEmail.trim());
  }
  try {
    final sendReport = await send(message, smtpServer);

    print('تم إرسال الإيصال: $sendReport');

    return true;
  } on MailerException catch (e) {
    print('فشل إرسال الإيصال: $e');

    for (var p in e.problems) {
      print('المشكلة: ${p.code}: ${p.msg}');
    }

    return false;
  }
}
