import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:vouch_tour_mobile/pages/main_pages/group_page.dart';
import 'package:vouch_tour_mobile/pages/main_pages/menu_page.dart';
import 'package:vouch_tour_mobile/pages/main_pages/order_page.dart';
import 'package:vouch_tour_mobile/pages/main_pages/profile_page.dart';
import 'package:vouch_tour_mobile/models/dashboard_tour_guide_model.dart';
import 'package:vouch_tour_mobile/services/api_service.dart';
//import 'package:vouch_tour_mobile/utils/drawer.dart';
import 'package:vouch_tour_mobile/utils/footer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfGroup = 0;
  int numberOfOrderCompleted = 0;
  int numberOfOrderCanceled = 0;
  int numberOfOrderWaiting = 0;
  int numberOfProductSold = 0;
  int point = 0;

  PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  void _navigateToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final DashboardTourGuideModel tourGuide =
          await ApiService.fetchTourGuideById(ApiService.currentUserId);

      setState(() {
        numberOfGroup = tourGuide.reportInMonth.numberOfGroup;
        numberOfOrderCompleted = tourGuide.reportInMonth.numberOfOrderCompleted;
        numberOfOrderCanceled = tourGuide.reportInMonth.numberOfOrderCanceled;
        numberOfOrderWaiting = tourGuide.reportInMonth.numberOfOrderWaiting;
        numberOfProductSold = tourGuide.reportInMonth.numberOfProductSold;
        point = tourGuide.reportInMonth.point;
      });
    } catch (e) {
      // Handle API error
      print('API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Hệ thống hỗ trợ TourGuide"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Add your notification logic here
              },
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Point Widget with Box Cover
                          SizedBox(
                            width: 200,
                            height: 80,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Điểm Thưởng',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.blue),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$point',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.star,
                                          color: Colors.yellow),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'Hoàn thành thêm ${10 - (numberOfOrderCompleted % 10)} đơn để nhận thêm điểm',
                                  style: const TextStyle(
                                      fontSize: 16.0, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                LinearPercentIndicator(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  lineHeight: 16.0,
                                  percent: 1 -
                                      ((10 - (numberOfOrderCompleted % 10)) /
                                          10),
                                  center: Text(
                                    "${100 - ((10 - (numberOfOrderCompleted % 10)) * 10)}%",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                  trailing: const Icon(Icons.mood),
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),

                          // Pie Chart Widget with Box Cover
                          SizedBox(
                            //width: 200,
                            //height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Tổng quát',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Bạn có ${numberOfOrderCompleted + numberOfOrderCanceled + numberOfOrderWaiting} đơn hàng',
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        SfCircularChart(
                                          legend: const Legend(isVisible: true),
                                          series: <CircularSeries>[
                                            PieSeries<Data, String>(
                                              dataSource: <Data>[
                                                Data('Hoàn thành',
                                                    numberOfOrderCompleted),
                                                Data('Đã Hủy',
                                                    numberOfOrderCanceled),
                                                Data('Đang Đợi',
                                                    numberOfOrderWaiting),
                                              ],
                                              xValueMapper: (Data data, _) =>
                                                  data.category,
                                              yValueMapper: (Data data, _) =>
                                                  data.value,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Number of Group Widget with Box Cover
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.44, // Adjust the width as needed
                                  height: MediaQuery.of(context).size.height *
                                      0.08, // Adjust the height as needed
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Số nhóm quản lý',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$numberOfGroup',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.44, // Adjust the width as needed
                                  height: MediaQuery.of(context).size.height *
                                      0.08, // Adjust the height as needed
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Số sản phẩm đã bán',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$numberOfProductSold',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  OrderPage(),
                  GroupPage(),
                  ProviderScope(
                    child: MenuPage(),
                  ),
                  const ProfilePage(),
                ],
              ),
            ),
          ],
        ),
        // drawer: AppDrawer(),
        bottomNavigationBar: AppFooter(
          currentIndex: _currentPageIndex,
          onTap: _navigateToPage,
          pageController: _pageController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Data {
  final String category;
  final int value;

  Data(this.category, this.value);
}
