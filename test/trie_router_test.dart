import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routemaster/routemaster.dart';
import 'package:routemaster/src/trie_router/trie_router.dart';

import 'helpers.dart';

class TestRoute extends Page<void> {
  final String id;

  TestRoute(this.id);

  @override
  String toString() {
    return "Test route '$id'";
  }

  @override
  Route<void> createRoute(BuildContext context) {
    throw UnimplementedError();
  }
}

RouteInfo getRouteInfo(RouterResult routerResult) {
  return RouteInfo.fromRouterResult(routerResult, '/');
}

void main() {
  test('Can add and get single routes', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', (_) => rootRoute);
    router.add('/one', (_) => route1);
    router.add('/one/two', (_) => route2);

    final dataRoot = router.get('/')!;
    expect(dataRoot.pathSegment, '/');
    expect(dataRoot.builder(getRouteInfo(dataRoot)), rootRoute);
    expect(dataRoot.pathParameters.isEmpty, isTrue);

    final data1 = router.get('/one')!;
    expect(data1.pathSegment, '/one');
    expect(data1.builder(getRouteInfo(data1)), route1);
    expect(data1.pathParameters.isEmpty, isTrue);

    final data2 = router.get('/one/two')!;
    expect(data2.pathSegment, '/one/two');
    expect(data2.builder(getRouteInfo(data2)), route2);
    expect(data2.pathParameters.isEmpty, isTrue);
  });

  test('Can add and get all routes', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');
    final route2 = TestRoute('two');

    router.add('/', (_) => rootRoute);
    router.add('/one', (_) => route1);
    router.add('/one/two', (_) => route2);

    final routes = router.getAll('/one/two')!;
    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/one');
    expect(routes[1].builder(getRouteInfo(routes[1])), route1);
    expect(routes[1].pathParameters.isEmpty, isTrue);

    expect(routes[2].pathSegment, '/one/two');
    expect(routes[2].builder(getRouteInfo(routes[2])), route2);
    expect(routes[2].pathParameters.isEmpty, isTrue);
  });

  test('Can get route which starts with parameter', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final route1 = TestRoute('one');

    router.add('/', (_) => rootRoute);
    router.add('/:id/one', (_) => route1);

    final routes = router.getAll('/myId/one')!;
    expect(routes.length, 2);

    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/myId/one'); // actual '/myId'
    expect(routes[1].builder(getRouteInfo(routes[1])), route1);
    expect(routes[1].pathParameters.isEmpty, isFalse);
  });

  test('Can get route which starts with multiple parameters', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final idRoute1 = TestRoute('id1');
    final idRoute2 = TestRoute('id2');
    final finalRoute = TestRoute('id2');

    router.add('/', (_) => rootRoute);
    router.add('/:id1', (_) => idRoute1);
    router.add('/:id1/:id2', (_) => idRoute2);
    router.add('/:id1/:id2/final', (_) => finalRoute);

    final routes = router.getAll('/prod1/prod2/final')!;
    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/prod1');
    expect(routes[1].builder(getRouteInfo(routes[1])), idRoute1);
    expect(routes[1].pathParameters.isEmpty, isFalse);

    expect(routes[2].pathSegment, '/prod1/prod2');
    expect(routes[2].builder(getRouteInfo(routes[2])), idRoute2);
    expect(routes[2].pathParameters.isEmpty, isFalse);

    expect(routes[3].pathSegment, '/prod1/prod2/final');
    expect(routes[3].builder(getRouteInfo(routes[3])), finalRoute);
    expect(routes[3].pathParameters.isEmpty, isFalse);
  });

  test('Can get route which starts with multiple skipped parameters', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final finalRoute = TestRoute('id2');

    router.add('/', (_) => rootRoute);
    router.add('/:id1/:id2/final', (_) => finalRoute);

    final routes = router.getAll('/prod1/prod2/final')!;
    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/prod1/prod2/final');
    expect(routes[1].builder(getRouteInfo(routes[1])), finalRoute);
    expect(routes[1].pathParameters.isEmpty, isFalse);
  });

  test('Can get route with parameter in middle', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final productRoute = TestRoute('product');
    final productIdRoute = TestRoute('productId');
    final detailsRoute = TestRoute('details');

    router.add('/', (_) => rootRoute);
    router.add('/product', (_) => productRoute);
    router.add('/product/:id', (_) => productIdRoute);
    router.add('/product/:id/details', (_) => detailsRoute);

    final routes = router.getAll('/product/myProduct/details')!;

    expect(routes.length, 4);

    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/product');
    expect(routes[1].builder(getRouteInfo(routes[1])), productRoute);
    expect(routes[1].pathParameters.isEmpty, isTrue);

    expect(routes[2].pathSegment, '/product/myProduct');
    expect(routes[2].builder(getRouteInfo(routes[2])), productIdRoute);
    expect(routes[2].pathParameters.isEmpty, isFalse);

    expect(routes[3].pathSegment, '/product/myProduct/details');
    expect(routes[3].builder(getRouteInfo(routes[3])), detailsRoute);
    expect(routes[3].pathParameters.isEmpty, isFalse);
  });

  test('Can get route with multiple parameters in middle', () {
    final router = TrieRouter();
    final rootRoute = TestRoute('root');
    final productRoute = TestRoute('product');
    final productId1Route = TestRoute('productId1');
    final productId2Route = TestRoute('productId2');
    final detailsRoute = TestRoute('details');

    router.add('/', (_) => rootRoute);
    router.add('/product', (_) => productRoute);
    router.add('/product/:id1', (_) => productId1Route);
    router.add('/product/:id1/:id2', (_) => productId2Route);
    router.add('/product/:id1/:id2/details', (_) => detailsRoute);

    final routes = router.getAll('/product/prod1/prod2/details')!;

    expect(routes.length, 5);

    expect(routes[0].pathSegment, '/');
    expect(routes[0].builder(getRouteInfo(routes[0])), rootRoute);
    expect(routes[0].pathParameters.isEmpty, isTrue);

    expect(routes[1].pathSegment, '/product');
    expect(routes[1].builder(getRouteInfo(routes[1])), productRoute);
    expect(routes[1].pathParameters.isEmpty, isTrue);

    expect(routes[2].pathSegment, '/product/prod1');
    expect(routes[2].builder(getRouteInfo(routes[2])), productId1Route);
    expect(routes[2].pathParameters.isEmpty, isFalse);

    expect(routes[3].pathSegment, '/product/prod1/prod2');
    expect(routes[3].builder(getRouteInfo(routes[3])), productId2Route);
    expect(routes[3].pathParameters.isEmpty, isFalse);

    expect(routes[4].pathSegment, '/product/prod1/prod2/details');
    expect(routes[4].builder(getRouteInfo(routes[4])), detailsRoute);
    expect(routes[4].pathParameters.isEmpty, isFalse);
  });

  test('Throws ConflictingPathError', () {
    final router = TrieRouter();
    router.add('/test/:id1', (info) => MaterialPageOne());

    expect(
      () {
        router.add('/test/:id2', (info) => MaterialPageOne());
      },
      throwsA(predicate((e) =>
          e is ConflictingPathError &&
          e.toString() ==
              "Attempt to add '/test/:id2' but a path containing '/test/:id1' has already been added. Adding two paths prefixed with ':' at the same index is not allowed.")),
    );
  });

  test('RouterResult not equal with different paths', () {
    final result1 = RouterResult((_) => MaterialPageOne(), {}, '/one');
    final result2 = RouterResult((_) => MaterialPageTwo(), {}, '/two');

    expect(result1.hashCode == result2.hashCode, isFalse);
    expect(result1 == result2, isFalse);
  });

  test('RouterResult toString() is correct', () {
    final result = RouterResult((_) => MaterialPageOne(), {'a': 'b'}, '/');
    expect(result.toString(), "RouterData - path: '/',  params: '{a: b}'");
  });
}
