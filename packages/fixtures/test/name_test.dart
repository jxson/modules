import 'package:test/test.dart';
import 'package:fixtures/fixtures.dart';
import 'package:fixtures/src/name.dart';

void main() {
  /**
   * Name should have:
   *  * String value
   *  * Unique namepsaced id based on name value
   *  * Allow override: new Name('Bob'); this should create an identical id
   */

  group('Name name = new Name();', () {
    test('generates random name', () {
      Name n1 = new Name();
      Name n2 = new Name();

      // TODO override == operator to compare ids
      expect(n1, isNot(equals(n2)));
      expect(n1.toString(), isNot(equals(n2.toString())));
    }, skip: 'WIP');
  });

  group('Name name = new Name(<string>);', () {
    test('Names with the same values are identical', () {
      Name bob1 = new Name('Bob');
      Name bob2 = new Name('Bob');

      expect(bob1.id, equals(bob2.id));
      expect(bob1, equals(bob2));
    });
  });
}
