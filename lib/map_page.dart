import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map_ui_test/network_service.dart';
import 'package:flutter_map_ui_test/models.dart';
import 'package:semaphore/semaphore.dart';
import 'dart:async';
import 'package:flutter_map_ui_test/bottom_expandable_page.dart';
import 'package:flutter_map_ui_test/fade_page_route.dart';
import 'package:flutter_map_ui_test/detail_screen_page.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() {
    return new MapPageState();
  }
}

class MapPageState extends State<MapPage> {
  /// Is a network call for listings going on or not.
  bool _isFetchingListings = false;

  /// Are markers being added on maps.
  bool _isAddingMarkers = false;

  /// Was a marker clicked by the user.
  bool _isMarkerCLicked = false;

  GoogleMapController _mapController;

  BottomExpandableController _bottomExpandableController;

  NetworkService _networkService;

  /// [Marker] id to [Listing] mapping
  Map<String, Listing> _markerListingMap = Map();

  Listing _selectedListing = Listing(
    city: '',
    country: '',
    listPrice: '',
    displayImage: '',
    id: 0,
    bathrooms: 0,
    longitude: 0.0,
    latitude: 0.0,
    hasOutdatedThumbnails: false,
  );

  @override
  void initState() {
    super.initState();

    _networkService = NetworkService();

    _bottomExpandableController = BottomExpandableController();

    _bottomExpandableController.addOnCompleteExpandedListener(() {
      Timer(Duration(seconds: 1), () {
        _bottomExpandableController.closeBottomSheet();
      });

      Navigator.of(context).push(
        FadePageRoute(
          builder: (context) {
            return DetailScreenPage(
              listing: _selectedListing,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomExpandablePage(
        controller: _bottomExpandableController,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          options: GoogleMapOptions(
            trackCameraPosition: true,
            zoomGesturesEnabled: true,
          ),
        ),
        bottomLayout: Material(
          child: quickViewWidget,
        ),
        // Content height should be calculated manually
        //
        contentHeight: 217.0,
      ),
    );
  }

  Widget get quickViewWidget {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12.0),
            height: 6.0,
            width: 60.0,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'QUICK VIEW',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${_selectedListing.city}, ${_selectedListing.country}',
            style: TextStyle(
              fontSize: 40.0,
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '\$${_selectedListing.listPrice}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Icon(Icons.directions_subway),
                SizedBox(width: 4.0),
                Text(
                  '5',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(width: 16.0),
                Icon(Icons.work),
                SizedBox(width: 4.0),
                Text(
                  '2',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Callback when map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _initializeMapController();
    _moveMapCameraToPosition();
  }

  // Add camera callback to map controller
  // Add [Marker] clicked callback
  void _initializeMapController() {
    _mapController.onMarkerTapped.add((marker) {
      _isMarkerCLicked = true;

      // Get associated [Listing] from marker
      final listing = _markerListingMap[marker.id];
      setState(() {
        _selectedListing = listing;
      });

      print('Marker Clicked');

      _bottomExpandableController.expandBottomSheet();

      // Reset the marker clicked after a fixed time, so that
      // request is not send again due to camera movement.
      Timer(Duration(seconds: 1), () {
        _isMarkerCLicked = false;
      });
    });

    _mapController.addListener(() {
      print("###############");
      print(_mapController.isCameraMoving);
      print(_isFetchingListings);
      print(_isAddingMarkers);

      if (!_mapController.isCameraMoving &&
          !_isFetchingListings &&
          !_isAddingMarkers &&
          !_isMarkerCLicked) {
        _isFetchingListings = true;
        _fetchListings();
      }
    });
  }

  // Move the Google Map Camera to 'Miami'
  void _moveMapCameraToPosition() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(26.036424258311133, -80.11430830594588),
          zoom: 15.0,
        ),
      ),
    );
  }

  // Network call to listings API
  void _fetchListings() async {
    final position = _mapController.cameraPosition.target;
    final zoom = _mapController.cameraPosition.zoom;
    final factor = (22.0 - zoom) * 0.001;

    final listings = await _networkService.fetchListings(CamLatLngBounds(
      northEastLat: position.latitude + factor,
      northEastLng: position.longitude + factor,
      southWestLat: position.latitude - factor,
      southWestLng: position.longitude - factor,
    ));
    _isFetchingListings = false;

    _isAddingMarkers = true;
    await _addMarkersFromListings(listings);
    _isAddingMarkers = false;
  }

  _addMarkersFromListings(List<Listing> listings) async {
    _markerListingMap.clear();
    _mapController.clearMarkers();

    for (int i = 0; i < listings.length; i++) {
      final listing = listings[i];

      final marker = await _mapController.addMarker(MarkerOptions(
        position: LatLng(listing.latitude, listing.longitude),
      ));

      _markerListingMap[marker.id] = listing;
    }
  }
}
