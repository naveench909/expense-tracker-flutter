import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'category_breakdown_screen.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime _selectedMonth = DateTime.now();
  double _totalSpending = 0.0;
  int _transactionCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    final transactionProvider = context.read<TransactionProvider>();
    await transactionProvider.loadTransactionsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final total = await transactionProvider.getMonthlyTotal(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    setState(() {
      _totalSpending = total;
      _transactionCount = transactionProvider.transactions.length;
      _isLoading = false;
    });
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
    _loadMonthlyData();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final averagePerTransaction =
        _transactionCount > 0 ? _totalSpending / _transactionCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: _selectedMonth.month >= DateTime.now().month &&
                                _selectedMonth.year >= DateTime.now().year
                            ? Colors.grey
                            : null,
                      ),
                      onPressed: _selectedMonth.month >= DateTime.now().month &&
                              _selectedMonth.year >= DateTime.now().year
                          ? null
                          : () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Total Spending',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${NumberFormat('#,##,##0.00').format(_totalSpending)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      title: 'Transactions',
                      value: _transactionCount.toString(),
                    ),
                    _StatCard(
                      title: 'Average',
                      value: '₹${NumberFormat('#,##0').format(averagePerTransaction)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryBreakdownScreen(
                      year: _selectedMonth.year,
                      month: _selectedMonth.month,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.pie_chart),
              label: const Text('View Category Breakdown'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactionProvider.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions this month',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactionProvider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction =
                              transactionProvider.transactions[index];
                          return ListTile(
                            title: Text(transaction.merchant),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy').format(transaction.date),
                            ),
                            trailing: Text(
                              '₹${NumberFormat('#,##0.00').format(transaction.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
