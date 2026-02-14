import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../services/currency_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoadingRates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final currencyService = CurrencyService();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: expenseProvider.isDarkMode,
                onChanged: (value) {
                  expenseProvider.toggleTheme();
                  HapticFeedback.selectionClick();
                },
                secondary: Icon(
                  expenseProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
              ),
              const Divider(),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Currency',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Preferred Currency'),
                subtitle: Text(
                  '${expenseProvider.currency} - ${currencyService.getCurrencySymbol(expenseProvider.currency)}',
                ),
                leading: const Icon(Icons.attach_money),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyPicker(context, expenseProvider),
              ),
              ListTile(
                title: const Text('Update Exchange Rates'),
                subtitle: const Text('Fetch latest conversion rates'),
                leading: const Icon(Icons.sync),
                trailing: _isLoadingRates
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isLoadingRates
                    ? null
                    : () => _updateExchangeRates(expenseProvider),
              ),
              const Divider(),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Copy expenses as JSON'),
                leading: const Icon(Icons.file_download),
                onTap: () => _exportData(expenseProvider),
              ),
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all expenses'),
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () =>
                    _showClearDataDialog(context, expenseProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, ExpenseProvider provider) {
    final currencyService = CurrencyService();
    final currencies = currencyService.getSupportedCurrencies();

    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected =
                      provider.currency == currency;

                  return ListTile(
                    title: Text(currency),
                    subtitle: Text(
                        currencyService.getCurrencySymbol(currency)),
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    selected: isSelected,
                    onTap: () {
                      provider.setCurrency(currency);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                            content: Text(
                                'Currency changed to $currency')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateExchangeRates(
      ExpenseProvider provider) async {
    setState(() {
      _isLoadingRates = true;
    });

    try {
      await provider.loadExchangeRates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Exchange rates updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRates = false;
        });
      }
    }
  }

  void _exportData(ExpenseProvider provider) {
    final jsonData = provider.exportData();

    Clipboard.setData(ClipboardData(text: jsonData));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Data copied to clipboard')),
    );
  }

  void _showClearDataDialog(
      BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will delete all expenses. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAllExpenses();
              Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                      content: Text('All data cleared')),
                );
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
