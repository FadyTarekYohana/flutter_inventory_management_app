import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static SharedPreferences? _preferences;
  static const _keyCart = "cart";
  static Map<String, String> cart = {};
  static const _keyInStock = "inStock";
  static bool inStock = false;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setInStock(bool inStock) async =>
      await _preferences!.setBool(_keyInStock, inStock);

  static Future addItemToCart(String itemId, String quantity) async {
    cart[itemId] = quantity;
    String encodedMap = json.encode(cart);
    print(encodedMap);
    await _preferences!.setString(_keyCart, encodedMap);
  }

  static removeItemFromCard(String itemId) async {
    cart.remove(itemId);
    String encodedMap = json.encode(cart);
    print(encodedMap);
    await _preferences!.setString(_keyCart, encodedMap);
  }

  static Map<String, String> getCart() {
    String encodedMap = _preferences!.getString(_keyCart) ?? '';
    Map<String, String> decodedMap = json.decode(encodedMap);
    print(decodedMap);
    return decodedMap;
  }

  static bool getInStock() => _preferences!.getBool(_keyInStock) ?? false;
}
