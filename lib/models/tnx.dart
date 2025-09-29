import 'item.dart';
import 'user.dart';

class Tnx {
  final int id;
  final User user;
  final List<Item> items;
  final DateTime date;

  Tnx({
    required this.id,
    required this.user,
    required this.items,
    required this.date,
  });

  double get total {
    return items.fold(0, (sum, item) => sum + item.price);
  }
}