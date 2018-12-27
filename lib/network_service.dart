import 'package:http_middleware/http_middleware.dart';
import 'package:http_logger/http_logger.dart';
import 'dart:convert';
import 'package:flutter_map_ui_test/models.dart';

class NetworkService {
  HttpWithMiddleware _http;

  NetworkService() {
    _http = HttpWithMiddleware.build(
      middlewares: [
        HttpLogger(logLevel: LogLevel.BODY),
      ],
    );
  }

  // Fetch listings within a given boundary
  Future<List<Listing>> fetchListings(CamLatLngBounds bounds) async {
    final response =
        await _http.post('https://staging.nobbas.com/api//houses/maps',
            body: jsonEncode({
              "listingCategory": "Purchase",
              "place": "Miami, FL, USA",
              "northEastLat": bounds.northEastLat,
              "northEastLong": bounds.northEastLng,
              "southWestLat": bounds.southWestLat,
              "southWestLong": bounds.southWestLng,
              "countNeeded": true,
              "sortBy": null,
              "skip": 0,
              "limit": 250,
              "buildingLimit": 10
            }),
            headers: {
          'Content-Type': 'application/json',
        });

    final parsedResponse = jsonDecode(response.body);

    List<dynamic> listings = parsedResponse["listings"];

    List<Listing> parsedListings =
        listings.map((map) => Listing.fromJSON(map)).toList();

    return parsedListings;
  }

  // Fetch listing details from id
  Future<Property> fetchListingDetails(String id) async {
    final response =
        await _http.get("https://staging.nobbas.com/api/houses/$id");

    print("Response:\n ${response.body}");

    final parsedResponse = jsonDecode(response.body);

    return Property.fromJSON(parsedResponse['property'][0]);
  }
}
