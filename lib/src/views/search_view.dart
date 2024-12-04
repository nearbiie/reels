import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:leuke/src/services/stores_service.dart'; // Import your service file
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:get/get.dart';
import 'dart:ui' as UI;

import '../core.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  VideoRecorderController videoRecorderController = Get.find();

  final int _pageSize = 50;
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 1);

  bool _locationEnabled = true;
  int? _zoneId;
  final StoreService _storeService = StoreService(); // Service instance
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pagingController.addPageRequestListener((pageKey) {
      if (_isSearching) {
        _searchStores(_searchController.text, pageKey);
      } else {
        _fetchStores(pageKey);
      }
    });
    _checkLocationServices(); // Check location on startup
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationServices();
    }
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _locationEnabled = serviceEnabled;
    });

    print("Location service enabled: $_locationEnabled");

    if (_locationEnabled) {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      print("Location Permission: $permission");

      // Request permission if not granted
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        // Handle location permission denial
        print('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle location permission permanently denied
        print('Location permission permanently denied');
        return;
      }

      // If permission is granted, initialize zone ID fetch
      await _initializeAndFetchZoneId();
    } else {
      // Show error dialog if location service is not enabled
      print('Location service is not enabled');
      setState(() {
        _locationEnabled = false;
      });
    }
  }

  Future<void> _initializeAndFetchZoneId() async {
    try {
      // Step 1: Get current location
      Position position = await _getCurrentLocation();
      print("Current Location: ${position.latitude}, ${position.longitude}");

      // Step 2: Fetch zone ID using the coordinates
      final zoneIdResponse = await _storeService.fetchZoneId(
          position.latitude, position.longitude);
      print("Fetched Zone ID Response: $zoneIdResponse");

      if (zoneIdResponse != null) {
        // Now trigger the API call to get stores based on the zone ID
        _zoneId = zoneIdResponse;
        _fetchStores(zoneIdResponse);
      } else {
        print("No zone ID found in the response.");
        throw Exception('No zone ID found for current location');
      }
    } catch (e) {
      print("Error in _initializeAndFetchZoneId: $e");
      setState(() {
        _locationEnabled = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Unable to fetch zone ID. Please try again later.'),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print("Location Permission: $permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Fetch current position
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchStores(int pageKey) async {
    if (_zoneId == null) {
      print("Zone ID is null, cannot fetch stores.");
      return;
    }

    try {
      final storesData = await _storeService.fetchStores(
        zoneId: _zoneId!,
        limit: _pageSize,
        offset: (pageKey - 1) * _pageSize,
      );

      final newItems =
          List<Map<String, dynamic>>.from(storesData['stores'] ?? []);
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = 'Failed to load stores';
      print("Error in _fetchStores: $e");
    }
  }

  Future<void> _searchStores(String name, int pageKey) async {
    if (_zoneId == null || name.isEmpty) {
      print("Zone ID is null or search query is empty.");
      return;
    }

    try {
      final storesData = await _storeService.searchStores(
        name: name,
        zoneId: _zoneId!,
      );

      final newItems =
          List<Map<String, dynamic>>.from(storesData['stores'] ?? []);
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      _pagingController.error = 'Failed to search stores';
      print("Error in _searchStores: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Stores'),
      ),
      body: !_locationEnabled
          ? _buildLocationDisabledWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search stores...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                            _pagingController
                                .refresh(); // Refresh list when search is triggered
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PagedListView<int, Map<String, dynamic>>(
                    pagingController: _pagingController,
                    builderDelegate:
                        PagedChildBuilderDelegate<Map<String, dynamic>>(
                      itemBuilder: (context, store, index) => InkWell(
                        onTap: () => _showStoreDetails(store),
                        child: Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(store['logo_full_url'] ?? ''),
                              onBackgroundImageError: (_, __) =>
                                  Icon(Icons.image_not_supported),
                            ),
                            title: Text(
                              store['name'] ?? 'Unknown Store',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _truncateText(store['address'] ??
                                      'No address available'),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      '${store['rating_count'] ?? 0}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                SharedData().sharedValue = jsonEncode(store);
                                MBS.showCupertinoModalBottomSheet(
                                  // expand: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => SizedBox(
                                    width: Get.mediaQuery.size.width,
                                    height: 120,
                                    child: BottomSheetAddButton(),
                                  ),
                                );
                              },
                              child: Text('Hire'),
                            ),
                          ),
                        ),
                      ),
                      firstPageErrorIndicatorBuilder: (_) => Center(
                        child: Text(
                            'No Stores available in your region. Pull to refresh.'),
                      ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          Center(child: Text('No stores available')),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLocationDisabledWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Location services are disabled.'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkLocationServices,
            child: Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text) {
    return text.length > 40 ? text.substring(0, 40) + '...' : text;
  }

  Future<void> _showStoreDetails(Map<String, dynamic> store) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(store['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(store['logo_full_url'] ?? ''),
              onBackgroundImageError: (_, __) =>
                  Icon(Icons.image_not_supported),
            ),
            SizedBox(height: 10),
            Text('Address: ${store['address'] ?? 'No address available'}'),
            Text('Rating: ${store['rating_count'] ?? 0} stars'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
