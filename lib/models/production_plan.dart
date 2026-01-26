import 'recipe.dart';
import 'item.dart';

class ProductionPlanNode {
  final RecipeItem item;
  final Recipe? recipe;
  final double ratePerMinute;
  final double machines;
  final List<ProductionPlanNode> inputs;
  final bool isTruncated;

  const ProductionPlanNode({
    required this.item,
    required this.recipe,
    required this.ratePerMinute,
    required this.machines,
    required this.inputs,
    this.isTruncated = false,
  });

  bool get isRaw => recipe == null;

  String get machineLabel {
    if (recipe == null) return 'Raw Resource';
    if (recipe!.producedIn.isNotEmpty) {
      return recipe!.producedIn.join(', ');
    }
    if (recipe!.inCraftBench) return 'Craft Bench';
    return 'Build Gun';
  }
}
