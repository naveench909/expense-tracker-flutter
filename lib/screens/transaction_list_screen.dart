import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../widgets/transaction_card.dart';
import '../utils/constants.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();
  String? _filterCategory;
  String? _filterPaymentMethod;
  List<ExpenseTransaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<TransactionProvider>().loadTransactions();
    _applyFilters();
  }

  void _applyFilters() {
    final transactionProvider = context.read<TransactionProvider>();
    var transactions = transactionProvider.transactions;

    if (_filterCategory != null) {
      transactions = transactions
          .where((t) => t.categoryId == _filterCategory)
          .toList();
    }

    if (_filterPaymentMethod != null) {
      transactions = transactions
          .where((t) => t.paymentMethod == _filterPaymentMethod)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      transactions = transactions
          .where((t) => t.merchant
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredTransactions = transactions;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterCategory = null;
      _filterPaymentMethod = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _editTransaction(ExpenseTransaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await context.read<TransactionProvider>().deleteTransaction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    if (_filteredTransactions.isEmpty && 
        _filterCategory == null && 
        _filterPaymentMethod == null && 
        _searchController.text.isEmpty) {
      _filteredTransactions = transactionProvider.transactions;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by merchant',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(_filterCategory == null
                          ? 'Category'
                          : categoryProvider.getCategoryById(_filterCategory!)?.name ?? 'Category'),
                      selected: _filterCategory != null,
                      onSelected: (selected) async {
                        if (selected) {
                          final category = await showDialog<String>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('Select Category'),
                              children: categoryProvider.categories
                                  .map<Widget>((cat) => SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context, cat.id),
                                        child: Text(cat.name),
                                      ))
                                  .toList(),
                            ),
                          );
                          if (category != null) {
                            setState(() {
                              _filterCategory = category;
                            });
                            _applyFilters();
                          }
                        } else {
                          setState(() {
                            _filterCategory = null;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(_filterPaymentMethod ?? 'Payment Method'),
                      selected: _filterPaymentMethod != null,
                      onSelected: (selected) async {
                        if (selected) {
                          final method = await showDialog<String>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('Select Payment Method'),
                              children: AppConstants.paymentMethods
                                  .map((method) => SimpleDialogOption(
                                        onPressed: () => Navigator.pop(context, method),
                                        child: Text(method),
                                      ))
                                  .toList(),
                            ),
                          );
                          if (method != null) {
                            setState(() {
                              _filterPaymentMethod = method;
                            });
                            _applyFilters();
                          }
                        } else {
                          setState(() {
                            _filterPaymentMethod = null;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                    if (_filterCategory != null || _filterPaymentMethod != null)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: transactionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final category = categoryProvider.getCategoryById(transaction.categoryId);
                      return TransactionCard(
                        transaction: transaction,
                        category: category,
                        onTap: () => _editTransaction(transaction),
                        onDelete: () => _deleteTransaction(transaction.id!),
                      );
                    },
                  ),
                ),
    );
  }
}
