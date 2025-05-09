import "package:avert/docs/accounting.dart";
import "package:test/test.dart";

void main() {
  group("Accounting: AccountValue", () {
    AccountValue diff = AccountValue.zero();
    test("setting initial value of 7000 Dr", () {
      diff += AccountValue.debit(7000);
      expect(diff.type, EntryType.debit);
      expect(diff.amount, 7000);
    });

    final double value = 6000;
    test("add $value Cr to diff", () {
      diff += AccountValue.credit(value);
      expect(diff.type, EntryType.debit);
      expect(diff.amount, 1000);
    });

  });
}
