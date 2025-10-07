import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class DatabaseService {
  static final SupabaseClient _client = supabase;

  // Category operations
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Product operations
  static Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    bool? isFeatured,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_bn
            )
          ''')
          .eq('is_active', true);

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,name_bn.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select('''
            *,
            categories:category_id (
              id,
              name,
              name_bn
            )
          ''')
          .eq('id', productId)
          .eq('is_active', true)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Cart operations
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('cart_items')
          .select('''
            *,
            products:product_id (
              id,
              name,
              name_bn,
              price,
              sale_price,
              image_urls,
              weight,
              unit
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }

  static Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if item already exists in cart
      final existingItem = await _client
          .from('cart_items')
          .select('id, quantity')
          .eq('user_id', user.id)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingItem != null) {
        // Update quantity if item exists
        await _client
            .from('cart_items')
            .update({
              'quantity': existingItem['quantity'] + quantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingItem['id']);
      } else {
        // Insert new item
        await _client.from('cart_items').insert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': quantity,
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  static Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      await _client
          .from('cart_items')
          .update({
            'quantity': quantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  static Future<void> removeFromCart(String cartItemId) async {
    try {
      await _client
          .from('cart_items')
          .delete()
          .eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  static Future<void> clearCart() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  static Future<int> getCartItemCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response = await _client
          .from('cart_items')
          .select('quantity')
          .eq('user_id', user.id);

      int totalCount = 0;
      for (var item in response) {
        totalCount += (item['quantity'] as int);
      }
      return totalCount;
    } catch (e) {
      return 0;
    }
  }

  // Order operations
  static Future<String> createOrder({
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
    Map<String, dynamic>? billingAddress,
    String? phone,
    String? notes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Generate order number
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // Create order
      final orderResponse = await _client
          .from('orders')
          .insert({
            'user_id': user.id,
            'order_number': orderNumber,
            'total_amount': totalAmount,
            'shipping_address': shippingAddress,
            'billing_address': billingAddress ?? shippingAddress,
            'phone': phone,
            'notes': notes,
            'status': 'pending',
          })
          .select('id')
          .single();

      final orderId = orderResponse['id'];

      // Get cart items
      final cartItems = await getCartItems();

      // Create order items
      final orderItems = cartItems.map((cartItem) {
        final product = cartItem['products'];
        final quantity = cartItem['quantity'];
        final unitPrice = product['sale_price'] ?? product['price'];
        
        return {
          'order_id': orderId,
          'product_id': product['id'],
          'quantity': quantity,
          'unit_price': unitPrice,
          'total_price': quantity * unitPrice,
        };
      }).toList();

      await _client.from('order_items').insert(orderItems);

      // Clear cart after successful order
      await clearCart();

      return orderNumber;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('orders')
          .select('''
            *,
            order_items:order_items (
              *,
              products:product_id (
                id,
                name,
                name_bn,
                image_urls
              )
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Utility methods
  static double calculateCartTotal(List<Map<String, dynamic>> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final product = item['products'];
      final quantity = item['quantity'];
      final price = product['sale_price'] ?? product['price'];
      total += quantity * price;
    }
    return total;
  }

  static String formatPrice(double price) {
    return 'Tk ${price.toStringAsFixed(0)}';
  }

  static bool isOnSale(Map<String, dynamic> product) {
    return product['sale_price'] != null && 
           product['sale_price'] < product['price'];
  }

  static double getEffectivePrice(Map<String, dynamic> product) {
    return product['sale_price'] ?? product['price'];
  }
}