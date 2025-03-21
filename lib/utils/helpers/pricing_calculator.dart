/// TPriceCalculator handles all price-related calculations for the e-commerce app
class TPriceCalculator {
  /// Calculates the final price including tax and shipping
  /// Parameters:
  /// - productPrice: Base price of the product
  /// - location: Customer's location for tax and shipping calculation
  /// Returns: Total price including tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    double shippingCost = getShippingCost(location);
    double totalPrice = productPrice + taxAmount + shippingCost;

    return totalPrice;
  }

  /// Calculates shipping cost based on location
  /// Parameters:
  /// - productPrice: Base price of the product
  /// - location: Customer's location for shipping calculation
  /// Returns: Formatted string of shipping cost with 2 decimal places
  static String calculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// Calculates tax amount based on product price and location
  /// Parameters:
  /// - productPrice: Base price of the product
  /// - location: Customer's location for tax calculation
  /// Returns: Formatted string of tax amount with 2 decimal places
  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  /// Gets tax rate based on location
  /// Currently returns fixed rate of 18%
  /// Parameters:
  /// - location: Customer's location
  /// Returns: Tax rate as decimal (0.18 = 18%)
  static double getTaxRateForLocation(String location) {
    return 0.18; // Fixed 18% tax rate
  }

  /// Gets shipping cost based on location
  /// Currently returns fixed cost of 0.5
  /// Parameters:
  /// - location: Customer's location
  /// Returns: Shipping cost as decimal
  static double getShippingCost(String location) {
    return 0.5; // Fixed shipping cost
  }
}
