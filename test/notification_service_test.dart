import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lankasmartmart/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    late FakeFirebaseFirestore fakeFs;

    setUp(() {
      fakeFs = FakeFirebaseFirestore();
      NotificationService.overrideFirestore(fakeFs);
    });

    tearDown(() {
      // reset any overrides; using null avoids touching real Firebase
      NotificationService.overrideFirestore(null);
    });

    test('ensureDefaults creates four documents when none exist', () async {
      expect((await fakeFs.collection('notifications').get()).docs, isEmpty);
      await NotificationService.ensureDefaults();
      final snap = await fakeFs.collection('notifications').get();
      expect(snap.docs.length, 4);
      // each id should match and message should be correct
      for (var i = 1; i <= 4; i++) {
        final doc = snap.docs.firstWhere((d) => d.id == 'msg$i');
        expect(doc.data()['message'], isNotEmpty);
      }
    });

    test('getRandomMessage returns null when collection empty', () async {
      final msg = await NotificationService.getRandomMessage();
      expect(msg, isNull);
    });

    test('getRandomMessage returns one of existing messages', () async {
      await fakeFs.collection('notifications').doc('a').set({'message': 'foo'});
      await fakeFs.collection('notifications').doc('b').set({'message': 'bar'});
      final msg = await NotificationService.getRandomMessage();
      expect(['foo', 'bar'], contains(msg));
    });

    test('getRandomMessage ignores null or empty messages', () async {
      await fakeFs.collection('notifications').doc('x').set({'message': ''});
      await fakeFs.collection('notifications').doc('y').set({'message': null});
      await fakeFs.collection('notifications').doc('z').set({'message': 'valid'});
      final msg = await NotificationService.getRandomMessage();
      expect(msg, equals('valid'));
    });
  });
}
