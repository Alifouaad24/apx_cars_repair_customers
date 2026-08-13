import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// ==================== نماذج البيانات ====================

class InvoiceItem {
  final String description;
  final int qty;
  final double rate;

  InvoiceItem({
    required this.description,
    required this.qty,
    required this.rate,
  });

  double get amount => qty * rate;
}

class InvoiceData {
  final String invoiceNumber;
  final String date;

  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;

  final String vehicleMakeModel;
  final String vehicleYear;
  final String vin; // يجب أن يكون 17 حرف بالضبط
  final String plate;
  final String mileage;

  final List<InvoiceItem> services;
  final String technicianNotes;
  final String footerNote;

  final double labor;
  final double parts;
  final double taxRate; // مثال: 0.07 لـ 7%

  InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    required this.vehicleMakeModel,
    required this.vehicleYear,
    required this.vin,
    required this.plate,
    required this.mileage,
    required this.services,
    this.technicianNotes = '',
    this.footerNote =
        'Electrical diagnostics are billed per hour. Parts carry a 12-month / 12,000-mile warranty; labor carries a 90-day warranty. Vehicles left over 5 days after completion incur storage fees.',
    this.labor = 0,
    this.parts = 0,
    this.taxRate = 0,
  });

  double get subtotal =>
      services.fold(0.0, (sum, s) => sum + s.amount) + labor + parts;
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
}

// ==================== ألوان التصميم ====================

class _InvoiceColors {
  static const bg = PdfColor.fromInt(0xFFFFFFFF);
  static const panel = PdfColor.fromInt(0xFF1e1e1e); // خلفية الصناديق
  static const lightHeader = PdfColor.fromInt(
    0xFFe8e6df,
  ); // شريط عناوين فاتح (CUSTOMER / VEHICLE / جدول)
  static const orange = PdfColor.fromInt(0xFFd97a3f);
  static const black = PdfColors.black;
  static const grayText = PdfColor.fromInt(0xFF9b9a94);
  static const border = PdfColor.fromInt(0xFF3a3a38);
  static const totalBg = PdfColor.fromInt(0xFFf0eee7);
}

// ==================== دالة توليد PDF ====================

Future<Uint8List> generateInvoiceeePdf(InvoiceData data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: _InvoiceColors.bg,
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(data),
              pw.SizedBox(height: 14),
              pw.Divider(color: _InvoiceColors.border, thickness: 1),
              pw.SizedBox(height: 14),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildCustomerBox(data)),
                  pw.SizedBox(width: 14),
                  pw.Expanded(child: _buildVehicleBox(data)),
                ],
              ),
              pw.SizedBox(height: 16),
              _buildServicesTable(data),
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

pw.Widget _buildHeader(InvoiceData data) {
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
              border: pw.Border.all(color: _InvoiceColors.black, width: 1.2),
            ),
            child: pw.Text(
              'G',
              style: pw.TextStyle(
                color: _InvoiceColors.black,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
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
                  color: _InvoiceColors.black,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'AUTOMOTIVE ELECTRICAL SERVICES',
                style: pw.TextStyle(
                  color: _InvoiceColors.orange,
                  fontSize: 8,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Phone (317) 516-9700 · saifaldinsami@gmail.com',
                style: pw.TextStyle(
                  color: _InvoiceColors.grayText,
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
            'Invoice',
            style: pw.TextStyle(
              color: _InvoiceColors.black,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'NO. ${data.invoiceNumber}',
            style: pw.TextStyle(color: _InvoiceColors.grayText, fontSize: 9),
          ),
          pw.Text(
            data.date,
            style: pw.TextStyle(color: _InvoiceColors.grayText, fontSize: 9),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _sectionHeaderBar(String title) {
  return pw.Container(
    width: double.infinity,
    color: _InvoiceColors.lightHeader,
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
            color: _InvoiceColors.grayText,
            fontSize: 7,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value.isEmpty ? ' ' : value,
          style: pw.TextStyle(color: _InvoiceColors.black, fontSize: 11),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: _InvoiceColors.border, thickness: 0.6),
      ],
    ),
  );
}

pw.Widget _buildCustomerBox(InvoiceData data) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _InvoiceColors.border, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeaderBar('CUSTOMER'),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _fieldBlock('NAME', data.customerName),
              _fieldBlock('PHONE', data.customerPhone),
              _fieldBlock('EMAIL', data.customerEmail),
              _fieldBlock('ADDRESS', data.customerAddress),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildVehicleBox(InvoiceData data) {
  final vinChars = data.vin.padRight(17).split('').take(17).toList();

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _InvoiceColors.border, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeaderBar('VEHICLE'),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _fieldBlock('MAKE / MODEL', data.vehicleMakeModel),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: _fieldBlock('YEAR', data.vehicleYear)),
                ],
              ),
              pw.Text(
                'VIN — 17 CHARACTERS',
                style: pw.TextStyle(
                  color: _InvoiceColors.orange,
                  fontSize: 7,
                  letterSpacing: 0.8,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                children: vinChars
                    .map(
                      (c) => pw.Container(
                        width: 15,
                        height: 18,
                        margin: const pw.EdgeInsets.only(right: 2),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: _InvoiceColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          c.trim(),
                          style: pw.TextStyle(
                            color: _InvoiceColors.black,
                            fontSize: 7,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Expanded(child: _fieldBlock('PLATE', data.plate)),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: _fieldBlock('MILEAGE', data.mileage)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildServicesTable(InvoiceData data) {
  final headerStyle = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
  final rowStyle = pw.TextStyle(color: _InvoiceColors.black, fontSize: 10);

  const totalRows = 9;
  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _InvoiceColors.lightHeader),
      children: [
        _tableCell('#', headerStyle, isHeader: true),
        _tableCell('SERVICE PERFORMED', headerStyle, isHeader: true),
        _tableCell(
          'QTY',
          headerStyle,
          isHeader: true,
          align: pw.Alignment.center,
        ),
        _tableCell(
          'RATE',
          headerStyle,
          isHeader: true,
          align: pw.Alignment.centerRight,
        ),
        _tableCell(
          'AMOUNT',
          headerStyle,
          isHeader: true,
          align: pw.Alignment.centerRight,
        ),
      ],
    ),
  ];

  for (int i = 0; i < totalRows; i++) {
    final hasData = i < data.services.length;
    final s = hasData ? data.services[i] : null;
    rows.add(
      pw.TableRow(
        children: [
          _tableCell((i + 1).toString().padLeft(2, '0'), rowStyle),
          _tableCell(s?.description ?? '', rowStyle),
          _tableCell(
            hasData ? s!.qty.toString() : '',
            rowStyle,
            align: pw.Alignment.center,
          ),
          _tableCell(
            hasData ? '\$${s!.rate.toStringAsFixed(0)}' : '',
            rowStyle,
            align: pw.Alignment.centerRight,
          ),
          _tableCell(
            hasData ? '\$${s!.amount.toStringAsFixed(0)}' : '',
            rowStyle,
            align: pw.Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: _InvoiceColors.border, width: 0.6),
    columnWidths: {
      0: const pw.FixedColumnWidth(28),
      1: const pw.FlexColumnWidth(4),
      2: const pw.FixedColumnWidth(40),
      3: const pw.FixedColumnWidth(60),
      4: const pw.FixedColumnWidth(70),
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
      child: pw.Text(text, style: isHeader ? style : style),
    ),
  );
}

pw.Widget _buildTechnicianNotes(InvoiceData data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'TECHNICIAN NOTES',
        style: pw.TextStyle(
          color: _InvoiceColors.grayText,
          fontSize: 8,
          letterSpacing: 0.8,
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Container(
        height: 130,
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _InvoiceColors.border, width: 0.7),
        ),
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          data.technicianNotes,
          style: pw.TextStyle(color: _InvoiceColors.black, fontSize: 9),
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        data.footerNote,
        style: pw.TextStyle(color: _InvoiceColors.grayText, fontSize: 7.5),
      ),
    ],
  );
}

pw.Widget _buildTotalsBox(InvoiceData data) {
  pw.Widget row(String label, String value, {bool isBold = false}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _InvoiceColors.border, width: 0.6),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: _InvoiceColors.grayText,
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _InvoiceColors.black,
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
      border: pw.Border.all(color: _InvoiceColors.border, width: 0.7),
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
          color: _InvoiceColors.totalBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL AMOUNT \$${data.total.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '\$',
                style: pw.TextStyle(
                  color: _InvoiceColors.orange,
                  fontSize: 14,
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

// ==================== دالة الإرسال (مدمجة مع التوليد) ====================

Future<bool> sendInvoiceEmail({
  required String toEmail,
  required String customerName,
  required String orderId,
  required InvoiceData invoiceData,
}) async {
  final smtpServer = gmail('alifouaad24@gmail.com', 'tdhhwaczycgqemmh');

  final pdfBytes = await generateInvoiceeePdf(invoiceData);

  final message = Message()
    ..from = const Address('alifouaad24@gmail.com', 'The Giest')
    ..recipients.add(toEmail)
    ..subject = 'Invoice #$orderId'
    ..text = 'مرفق فاتورتك يا $customerName'
    ..attachments = [
      StreamAttachment(
        Stream.fromIterable([pdfBytes]),
        'application/pdf',
        fileName: 'invoice_$orderId.pdf',
      ),
    ];

  try {
    final sendReport = await send(message, smtpServer);
    print('تم الإرسال: $sendReport');
    return true;
  } on MailerException catch (e) {
    print('فشل الإرسال: $e');
    for (var p in e.problems) {
      print('المشكلة: ${p.code}: ${p.msg}');
    }
    return false;
  }
}

// ==================== مثال استخدام ====================

/*
void main() async {
  final invoice = InvoiceData(
    invoiceNumber: '4456',
    date: '07/30/2026',
    customerName: 'HR Auto Body',
    customerPhone: '3172208557',
    customerEmail: 'Hrautobody0@gmail.com',
    customerAddress: '437 E Hanna Ave Indianapolis, IN 46227',
    vehicleMakeModel: '2019 Ford F-150',
    vehicleYear: '',
    vin: '1FTFW1RG5KFB89047',
    plate: '',
    mileage: '',
    services: [
      ServiceItem(description: 'Radar Calibration', qty: 1, rate: 375),
    ],
    technicianNotes: '',
  );

  await sendInvoiceEmail(
    toEmail: 'client@example.com',
    customerName: invoice.customerName,
    orderId: invoice.invoiceNumber,
    invoiceData: invoice,
  );
}
*/
