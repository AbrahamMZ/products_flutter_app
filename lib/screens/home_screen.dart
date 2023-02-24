import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:products_app/models/models.dart';
import 'package:products_app/widgets/widgets.dart';
import 'package:products_app/services/services.dart';
import 'package:products_app/screens/screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final productService = Provider.of<ProductsService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    if (productService.isLoading) return const LoadingScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
              onPressed: () {
                authService.logout();
                Navigator.pushReplacementNamed(context, 'login');
              },
              icon: const Icon(Icons.login_outlined))
        ],
      ),
      body: ListView.builder(
          itemCount: productService.products.length,
          itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () {
                  productService.selectedProduct =
                      productService.products[index].copy();
                  Navigator.pushNamed(context, 'product');
                },
                child: ProductCard(
                  product: productService.products[index],
                ),
              )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productService.selectedProduct =
              Product(available: false, name: '', price: 0);
          Navigator.pushNamed(context, 'product');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
