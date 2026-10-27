
import 'package:flutter_test/flutter_test.dart';
import 'package:voucher_master/main.dart';

void main() {
  testWidgets('Voucher Master app starts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VoucherMasterApp());

    expect(find.byType(VoucherMasterApp), findsOneWidget);
  });
}
