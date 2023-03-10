import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:products_app/providers/providers.dart';
import 'package:products_app/ui/input_decorations.dart';
import 'package:products_app/widgets/product_image.dart';
import 'package:products_app/services/services.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
        create: (_) => ProductFormProvider(productService.selectedProduct),
        child: _ProductScreen(productService: productService));
  }
}

class _ProductScreen extends StatelessWidget {
  const _ProductScreen({
    required this.productService,
  });

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(
                  url: productService.selectedProduct.picture,
                ),
                Positioned(
                    top: 60,
                    left: 20,
                    child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 40, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop())),
                Positioned(
                    top: 60,
                    right: 20,
                    child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            size: 40, color: Colors.white),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 100);

                          if (image == null) return;

                          productService
                              .previewSelectedProductImage(image.path);

                          // Capture a photo
                          // final XFile? photo = await picker.pickImage(
                          //     source: ImageSource.camera);
                          // Pick a video
                          // final XFile? image = await picker.pickVideo(
                          //     source: ImageSource.gallery);
                          // Capture a video
                          // final XFile? video = await picker.pickVideo(
                          //     source: ImageSource.camera);
                          // Pick multiple images
                          // final List<XFile>? images =
                          //     await picker.pickMultiImage();
                        }))
              ],
            ),
            const _ProductForm(),
            const SizedBox(height: 100)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          onPressed: productService.isLoading
              ? null
              : () async {
                  if (!productForm.isValidForm()) return;
                  // Manejo de la imagen
                  final String? imageUrl = await productService.uploadImage();
                  if (imageUrl != null) productForm.product.picture = imageUrl;

                  await productService.saveOrCreateProduct(productForm.product);
                },
          child: productService.isUpdated
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.save)),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm();

  @override
  Widget build(BuildContext context) {
    final producForm = Provider.of<ProductFormProvider>(context);
    final product = producForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
            key: producForm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: product.name,
                  onChanged: (value) => product.name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es Obligatorio';
                    }
                    return null;
                  },
                  decoration: InputDecorations.authInputDecoration(
                      hintText: 'Nombre del Producto', labelText: 'Nombre'),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  initialValue: '${product.price}',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^(\d+)?\.?\d{0,2}'))
                  ],
                  onChanged: (value) {
                    if (double.tryParse(value) == null) {
                      product.price = 0;
                    } else {
                      product.price = double.parse(value);
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.authInputDecoration(
                      hintText: '\$150', labelText: 'Precio:'),
                ),
                const SizedBox(height: 30),
                SwitchListTile.adaptive(
                    value: product.available,
                    title: const Text('Disponible'),
                    onChanged: producForm.updateaAvailability),
                const SizedBox(height: 30)
              ],
            )),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 5),
                blurRadius: 5)
          ]);
}
