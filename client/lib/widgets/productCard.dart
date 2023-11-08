import 'package:client/model/productModel.dart';
import 'package:client/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({ 
    Key? key, 
    required this.product
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: SizedBox(
          width: 200,
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0)
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.files.first.url),
                    fit: BoxFit.fitHeight
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.length > 50 ? product.name.substring(0, 50) : product.name,
                      style: const TextStyle(
                        fontSize: 16
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        '${product.price.toString()} THB',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
              ),
            )
          ],
        ),
        )
      ),
    );
  }
}