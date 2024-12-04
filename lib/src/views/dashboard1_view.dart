import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leuke/src/services/dashboard1_service.dart'; // Assuming the service is in this file

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  List<StoreData> _storeData = [];
  bool _isLoading = false;
  int _page = 1; // Pagination for infinite scroll

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
  }

  // Function to load dashboard data with pagination
  void _loadDashboardData() {
    setState(() {
      _isLoading = true;
    });

    DashboardService1().fetchDashboardData(page: _page).then((data) {
      setState(() {
        _storeData.addAll(data);
        _isLoading = false;
        _page++;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $error');
    });
  }

  // Function to refresh the list of stores
  Future<void> _refreshData() async {
    setState(() {
      _page = 1;
      _storeData.clear();
    });
    _loadDashboardData();
  }

  // Function to calculate the total amount
  double _calculateTotalAmount() {
    return _storeData.fold(0.0, (sum, store) => sum + store.videoAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        children: [
          // Total Amount Tile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            ),
                        color: Colors.blue.shade700),
                    child:
                        //  ListTile(
                        //   title: Text('Total Amount'),
                        //   subtitle: Text('\$${_calculateTotalAmount()}'),
                        //   leading: Icon(Icons.attach_money, color: Colors.green),
                        // ),
                        Center(
                      child: Text(
                        'Total',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            ),
                        color: Colors.green.shade700),
                    child:
                        //  ListTile(
                        //   title: Text('Total Amount'),
                        //   subtitle: Text('\$${_calculateTotalAmount()}'),
                        //   leading: Icon(Icons.attach_money, color: Colors.green),
                        // ),
                        Center(
                      child: Text(
                        'Amount',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            ),
                        color: Colors.orange),
                    child:
                        //  ListTile(
                        //   title: Text('Total Amount'),
                        //   subtitle: Text('\$${_calculateTotalAmount()}'),
                        //   leading: Icon(Icons.attach_money, color: Colors.green),
                        // ),
                        Center(
                      child: Text(
                        '\$${_calculateTotalAmount()}',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),

          // Current Projects Tile
          Container(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: ListTile(
                title: Text('Current Projects'),
                subtitle: Text('You have ${_storeData.length} active projects'),
                trailing: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Action for the send button (e.g., trigger payment)
                  },
                ),
              ),
            ),
          ),

          // Store Tiles List with Pull to Refresh and Infinite Scroll
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                itemCount:
                    _storeData.length + 1, // Adding 1 for the loading indicator
                itemBuilder: (context, index) {
                  if (index == _storeData.length) {
                    return _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox.shrink();
                  }

                  final store = _storeData[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: store.storeLogo.isNotEmpty
                            ? NetworkImage(store.storeLogo)
                            : AssetImage('assets/default_store_icon.png')
                                as ImageProvider,
                        radius: 30.0,
                      ),
                      title: Text(store.storeName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Video Status: ${store.videoStatus}'),
                          Text('Payment Status: ${store.paymentStatus}'),
                          if (store.paymentLink != null)
                            Text('Amount: \$${store.videoAmount}'),
                        ],
                      ),
                      trailing: store.paymentStatus == 'paid'
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                      onTap: () {
                        if (store.paymentStatus != 'paid') {
                          // Trigger the 'Pay' action
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Pay for ${store.storeName}'),
                                content: Text('Amount: \$${store.videoAmount}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Handle payment action here
                                      Navigator.pop(context);
                                    },
                                    child: Text('Pay'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle send action here
                                      Navigator.pop(context);
                                    },
                                    child: Text('Send'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  );
                },
                // Infinite Scroll
                controller: ScrollController()
                  ..addListener(() {
                    if (_isLoading) return;
                    if (_isLoading || !_isAtBottom()) return;
                    _loadDashboardData();
                  }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isAtBottom() {
    return (ScrollController().position.pixels ==
        ScrollController().position.maxScrollExtent);
  }
}
