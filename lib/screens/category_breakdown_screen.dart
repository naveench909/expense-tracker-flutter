import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/transaction_card.dart';
import '../screens/add_transaction_screen.dart';

class CategoryBreakdownScreen extends StatefulWidget {
  final int year;
  final int month;

  const CategoryBreakdownScreen({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  State<CategoryBreakdownScreen> createState() =>
      _CategoryBreakdownScreenState();
}

class _CategoryBreakdownScreenState extends State<CategoryBreakdownScreen> {
  Map<String, double> _breakdown = {};
  double _totalSpending = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBreakdown();
  }

  Future<void> _loadBreakdown() async {
    setState(() {
      _isLoading = true;
    });

    final transactionProvider = context.read<TransactionProvider>();
    final breakdown = await transactionProvider.getCategoryBreakdown(
      widget.year,
      widget.month,
    );
    final total = await transactionProvider.getMonthlyTotal(
      widget.year,
      widget.month,
    );

    setState(() {
      _breakdown = breakdown;
      _totalSpending = total;
      _isLoading = false;
    });
  }

  void _viewCategoryTransactions(String categoryId) async {
    final transactionProvider = context.read<TransactionProvider>();
    await transactionProvider.loadTransactionsByMonth(widget.year, widget.month);
    final transactions = transactionProvider.filterByCategory(categoryId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategoryTransactionsSheet(
        categoryId: categoryId,
        transactions: transactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Category Breakdown'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sortedBreakdown = _breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Breakdown'),
      ),
      body: sortedBreakdown.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No spending data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedBreakdown.length,
              itemBuilder: (context, index) {
                final entry = sortedBreakdown[index];
                final categoryId = entry.key;
                final amount = entry.value;
                final percentage = (_totalSpending > 0)
                    ? (amount / _totalSpending * 100)
                    : 0.0;
                final category = categoryProvider.getCategoryById(categoryId);

                if (category == null) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _viewCategoryTransactions(categoryId),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppConstants.getIconData(category.icon),
                                color: AppConstants.getColorFromHex(category.color),
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}% of total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${NumberFormat('#,##,##0.00').format(amount)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppConstants.getColorFromHex(category.color),
                              ),
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
}

class _CategoryTransactionsSheet extends StatelessWidget {
  final String categoryId;
  final List transactions;

  const _CategoryTransactionsSheet({
    required this.categoryId,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.getCategoryById(categoryId);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (category != null) ...[
                    Icon(
                      AppConstants.getIconData(category.icon),
                      color: AppConstants.getColorFromHex(category.color),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      category?.name ?? 'Transactions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('No transactions'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionCard(
                          transaction: transactions[index],
                          category: category,
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                  transaction: transactions[index],
                                ),
                              ),
                            );
                          },
                          onDelete: () async {
                            await context
                                .read<TransactionProvider>()
                                .deleteTransaction(transactions[index].id);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
