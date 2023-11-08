import 'package:client/model/productModel.dart';
import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  final Review review;
  const ReviewTile({ Key? key, required this.review }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade200)
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.5,
            backgroundImage: NetworkImage(review.user.avatar),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(review.review)
              ],
            ),
          )
        ],
      ),
    );
  }
}