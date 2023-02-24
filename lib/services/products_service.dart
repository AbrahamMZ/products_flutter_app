import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:products_app/models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-backend-960e2-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  late Product selectedProduct;
  File? newPictureFile;

  bool isLoading = true;
  bool isUpdated = false;

  final storage = const FlutterSecureStorage();

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'idToken') ?? ''});
    final res = await http.get(url);

    final Map<String, dynamic> productMap = json.decode(res.body);

    productMap.forEach((key, value) {
      final tempProduct = Product.fromJson(value);
      tempProduct.id = key;

      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();

    return products;
  }

  Future saveOrCreateProduct(Product product) async {
    isUpdated = true;
    notifyListeners();

    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }

    isUpdated = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await storage.read(key: 'idToken') ?? ''});
    await http.put(url, body: product.toRawJson());

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'idToken') ?? ''});
    final res = await http.post(url, body: product.toRawJson());
    final decodeData = json.decode(res.body);

    product.id = decodeData['name'];
    products.add(product);

    return product.id!;
  }

  void previewSelectedProductImage(String path) {
    selectedProduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;
    isUpdated = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dfhbhzd9q/image/upload?upload_preset=ml_default');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final res = await http.Response.fromStream(streamResponse);

    if (res.statusCode != 200 && res.statusCode != 201) {
      // Algo Salio Al subir imagen a Cloudinary
      return null;
    }
    newPictureFile = null;
    final decodeData = json.decode(res.body);
    return decodeData['secure_url'];
  }
}
