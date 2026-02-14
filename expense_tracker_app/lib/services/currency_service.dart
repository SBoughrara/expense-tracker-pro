import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Using exchangerate-api.com free tier
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  Map<String, double>? _cachedRates;
  DateTime? _lastFetch;

  Future<Map<String, double>> getExchangeRates() async {
    // Cache rates for 1 hour
    if (_cachedRates != null && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < const Duration(hours: 1)) {
      return _cachedRates!;
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
final rawRates = Map<String, dynamic>.from(data['rates']);

final rates = rawRates.map(
  (key, value) => MapEntry(key, (value as num).toDouble()),
);
        
        _cachedRates = rates;
        _lastFetch = DateTime.now();
        
        return rates;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // Return cached rates if available, otherwise throw
      if (_cachedRates != null) {
        return _cachedRates!;
      }
      rethrow;
    }
  }

  double convertCurrency(double amount, String fromCurrency, String toCurrency, Map<String, double> rates) {
    if (fromCurrency == toCurrency) return amount;
    
    // Convert to USD first, then to target currency
    final usdAmount = fromCurrency == 'USD' ? amount : amount / rates[fromCurrency]!;
    final convertedAmount = toCurrency == 'USD' ? usdAmount : usdAmount * rates[toCurrency]!;
    
    return convertedAmount;
  }

  List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 
      'CAD', 'AUD', 'CHF', 'SEK', 'NZD', 'MXN',
      'SGD', 'HKD', 'NOK', 'KRW', 'TRY', 'RUB',
      'BRL', 'ZAR'
    ];
  }

  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'CNY':
        return '¥';
      default:
        return currency;
    }
  }
}