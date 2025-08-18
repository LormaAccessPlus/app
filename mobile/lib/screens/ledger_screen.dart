import 'package:flutter/material.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(title: Text('Ledger')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Semester Dropdown
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[100],
                      ),
                      child: DropdownButton<String>(
                        value: 'First Semester 2024-2025',
                        isExpanded: true,
                        underline: SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: 'First Semester 2024-2025',
                            child: Text('First Semester 2024-2025'),
                          ),
                          DropdownMenuItem(
                            value: 'Second Semester 2024-2025',
                            child: Text('Second Semester 2024-2025'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                    SizedBox(height: 16),

                    // Tuition Fee Card
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Tuition Fee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Spacer(),
                                Text('₱15,000.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                },
                                children: [
                                  _tuitionRow('General Education Subject', '₱5,000.00'),
                                  _tuitionRow('Laboratory Subject', '₱5,000.00'),
                                  _tuitionRow('Professional Subjects', '₱5,000.00'),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            ...[
                              _feeRow('ACCESS FEE', '50.00', isMobile),
                              _feeRow('Laboratory Subjects', '5,000.00', isMobile),
                              _feeRow('Accounting Fee', '500.00', isMobile),
                              _feeRow('Athletic and Cultural Fee', '100.00', isMobile),
                              _feeRow('Communication and Media Fee', '200.00', isMobile),
                              _feeRow('Guidance and Counseling Fee', '100.00', isMobile),
                              _feeRow('Health and Wellness Fee', '200.00', isMobile),
                              _feeRow('ID Fee', '200.00', isMobile),
                              _feeRow('Information Technology and Cloud Services', '2,000.00', isMobile),
                              _feeRow('Laboratory Fee', '3,000.00', isMobile),
                              _feeRow('Registration Fee', '900.00', isMobile),
                              _feeRow('Renewable Energy Fee', '2,000.00', isMobile),
                              _feeRow('Research and Extension', '1,000.00', isMobile),
                              _feeRow('Laboratory Fee', '500.00', isMobile),
                            ],
                            SizedBox(height: 8),
                            // Sub Total
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF08695A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Sub Total:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('₱13,800.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF08695A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Miscellaneous Fees:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('₱15,000.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            // Grand Total
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Color(0xFF08695A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Grand Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('₱27,800.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            // Outstanding Balance
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Outstanding Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('₱27,800.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('As of April 1, 2025 7:58am', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Installment Section
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF08695A),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Text('Installment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                              },
                              children: [
                                _installmentRow('1st Installment (Prelims) [25.00%]', 'Jan. 5, 2025'),
                                _installmentRow('2nd Installment (Prelims) [25.00%]', 'Feb. 5, 2025'),
                                _installmentRow('3rd Installment (Midterms) [25.00%]', 'May 5, 2025'),
                                _installmentRow('4th Installment (Finals) [25.00%]', 'June 5, 2025'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Transactions Section
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF08695A),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Text('Transactions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _tableHeader('Order No.', isMobile),
                                  _tableHeader('Name', isMobile),
                                  _tableHeader('Date', isMobile),
                                  _tableHeader('By', isMobile),
                                  _tableHeader('Debit', isMobile),
                                  _tableHeader('Credit', isMobile),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text('No transactions found.', style: TextStyle(color: Colors.grey[600])),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TableRow _tuitionRow(String label, String price) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(label, style: TextStyle(fontSize: 15)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            price,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  TableRow _installmentRow(String label, String due) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(label, style: TextStyle(fontSize: 15)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            due,
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _feeRow(String label, String amount, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Make label flexible and wrap if too long
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '₱$amount',
            style: TextStyle(color: Colors.black, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String label, bool isMobile) {
    return Container(
      width: isMobile ? 90 : 120,
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}