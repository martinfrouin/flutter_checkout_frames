/// Configuration for Frames
class FramesConfig {
  /// Your Checkout.com public key
  final String publicKey;

  /// Enable debug mode
  final bool debug;

  /// Cardholder information
  final Cardholder? cardholder;

  const FramesConfig({
    required this.publicKey,
    this.debug = false,
    this.cardholder,
  });
}

/// Cardholder information
class Cardholder {
  /// The name of the cardholder
  final String? name;

  /// The phone number of the customer
  final String? phone;

  /// The cardholder billing address
  final BillingAddress? billingAddress;

  const Cardholder({
    this.name,
    this.phone,
    this.billingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (billingAddress != null) 'billing_address': billingAddress!.toJson(),
    };
  }
}

/// Billing address information
class BillingAddress {
  /// Address line 1
  final String? addressLine1;

  /// Address line 2
  final String? addressLine2;

  /// Zip code
  final String? zip;

  /// City
  final String? city;

  /// State
  final String? state;

  /// Country code (ISO 3166-1 alpha-2)
  final String? country;

  const BillingAddress({
    this.addressLine1,
    this.addressLine2,
    this.zip,
    this.city,
    this.state,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (zip != null) 'zip': zip,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
    };
  }
}
