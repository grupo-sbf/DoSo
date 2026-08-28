import 'package:doso/doso.dart';
import 'package:flutter_test/flutter_test.dart';

SoAsync<Exception, int> alwaysAsync() async => const Do.success(1);

SoExceptionAsync<String> alwaysAsyncException() async =>
    const Do.success('ok');

SoSync<Exception, int> alwaysSync() => const Do.success(2);

SoExceptionSync<String> alwaysSyncException() => const Do.success('ok');

SoException<int> flexible({required bool async}) =>
    async ? Future.value(const Do.success(3)) : const Do.success(3);

void main() {
  group('SoAsync', () {
    test('is a real Future, usable with Future.wait without a cast', () async {
      final results = await Future.wait([alwaysAsync(), alwaysAsync()]);

      expect(results, hasLength(2));
      expect(results.every((r) => r.isSuccess), isTrue);
    });

    test('exposes Future members that FutureOr does not', () async {
      final result = await alwaysAsync().timeout(const Duration(seconds: 1));

      expect(result.getOrElse(0), equals(1));
    });

    test('SoExceptionAsync works with record wait', () async {
      final (a, b) = await (alwaysAsyncException(), alwaysAsyncException()).wait;

      expect(a.getOrElse(''), equals('ok'));
      expect(b.getOrElse(''), equals('ok'));
    });
  });

  group('SoSync', () {
    test('returns a Do directly, with no await needed', () {
      final result = alwaysSync();

      expect(result.getOrElse(0), equals(2));
    });

    test('SoExceptionSync returns a Do directly', () {
      expect(alwaysSyncException().getOrElse(''), equals('ok'));
    });
  });

  group('So', () {
    test('still accepts both a sync and an async implementation', () async {
      expect((await flexible(async: false)).getOrElse(0), equals(3));
      expect((await flexible(async: true)).getOrElse(0), equals(3));
    });

    test('SoAsync is assignable to So', () async {
      final So<Exception, int> asSo = alwaysAsync();

      expect((await asSo).getOrElse(0), equals(1));
    });

    test('SoSync is assignable to So', () async {
      final So<Exception, int> asSo = alwaysSync();

      expect((await asSo).getOrElse(0), equals(2));
    });
  });
}
