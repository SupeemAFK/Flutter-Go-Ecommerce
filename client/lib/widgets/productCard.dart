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
              Padding(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${product.price.toString()} THB'),
                        TextButton(
                          onPressed:() => userProvider.addtoCurrentUserCart(product.id, 1), 
                          child: Icon(
                            Icons.shopping_cart,
                            color: Color.fromARGB(255, 29, 29, 29),
                            size: 18,
                          ),
                        )
                      ],
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