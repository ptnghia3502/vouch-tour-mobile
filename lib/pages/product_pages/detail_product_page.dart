import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vouch_tour_mobile/controllers/product_controller.dart';
import 'package:vouch_tour_mobile/services/api_service.dart';

class DetailProductPage extends ConsumerWidget {
  DetailProductPage({Key? key, required this.getIndex}) : super(key: key);

  final int getIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(proudctNotifierProvider);
    final TextEditingController actualPriceController = TextEditingController();

    // Check if the products list is empty or if the getIndex is out of range
    if (products.isEmpty || getIndex < 0 || getIndex >= products.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Loading',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(
          child: Text('Loading...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: const Color(0xFF022238),
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFFE8F6FB),
              child: Image.network(
                products[getIndex].images.isNotEmpty
                    ? products[getIndex].images[0].fileURL
                    : '',
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Image.network(
                    'https://www.howtogeek.com/wp-content/uploads/2022/05/frowning-BSOD-Header.png?height=200p&trim=2,2,2,2&crop=16:9',
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    products[getIndex].productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ).copyWith(color: const Color(0xFF843667)),
                  ),
                  const Gap(12),

                  // RatingBar and review code
                  Row(
                    children: [
                      RatingBar(
                        itemSize: 20,
                        initialRating: 4,
                        minRating: 1,
                        maxRating: 5,
                        allowHalfRating: true,
                        ratingWidget: RatingWidget(
                          empty: const Icon(
                            Icons.star_border,
                            color: Colors.amber,
                          ),
                          full: const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          half: const Icon(
                            Icons.star_half_sharp,
                            color: Colors.amber,
                          ),
                        ),
                        onRatingUpdate: (value) => null,
                      ),
                      const Gap(20),
                      const Text('4953 review')
                    ],
                  ),

                  const Gap(16),
                  const Text(
                    'Mô tả sản phẩm:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  Text(products[getIndex].description),
                  const Gap(40),

                  Row(
                    children: [
                      const Text(
                        'Nhà cung cấp:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text(products[getIndex].supplier.supplierName),
                    ],
                  ),

                  const Gap(8),
                  Row(
                    children: [
                      const Text(
                        'Địa chỉ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text(products[getIndex].supplier.address),
                    ],
                  ),
                  const Gap(20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giá niêm yết: ${products[getIndex].retailPrice} VND',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Container(
                      //   child: Row(
                      //     children: [
                      //       IconButton(
                      //         onPressed: () {
                      //           ref
                      //               .read(proudctNotifierProvider.notifier)
                      //               .decreaseQty(products[getIndex].id);
                      //         },
                      //         icon: const Icon(
                      //           Icons.do_not_disturb_on_outlined,
                      //           size: 30,
                      //         ),
                      //       ),
                      //       Text(
                      //         products[getIndex].qty.toString(),
                      //         style: const TextStyle(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.bold,
                      //         ).copyWith(fontSize: 24),
                      //       ),
                      //       IconButton(
                      //         onPressed: () {
                      //           ref
                      //               .read(proudctNotifierProvider.notifier)
                      //               .incrementQty(products[getIndex].id);
                      //         },
                      //         icon: const Icon(
                      //           Icons.add_circle_outline,
                      //           size: 30,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  Text(
                    'Giá phân phối: ${products[getIndex].resellPrice} VND',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF843667),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  'Bạn muốn bán lại cho khách với giá:'),
                              content: TextField(
                                controller: actualPriceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    hintText: 'Giá thực tế sản phẩm'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Get the values from the input fields
                                    final productId = products[getIndex].id;
                                    final actualPrice = double.parse(
                                        actualPriceController.text);

                                    // Call the addToCart API
                                    ApiService.addToCart(productId, actualPrice)
                                        .then((statusCode) {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      if (statusCode == 200) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Success'),
                                              content: const Text(
                                                  'Thêm vào menu thành công'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the success dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Error'),
                                              content: const Text(
                                                  'Giá bán lại không được thấp quá 90% giá phân phối,'
                                                  ' hoặc lớn hơn giá phân phối'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the error dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    });
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Thêm sản phẩm vào menu'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
