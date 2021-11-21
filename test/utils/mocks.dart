import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mocktail/mocktail.dart';

class MockPagingController<PageKeyType, ItemType> extends Mock
    implements PagingController<PageKeyType, ItemType> {}
