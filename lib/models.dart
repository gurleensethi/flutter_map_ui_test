class Listing {
  final String displayImage;
  final bool hasOutdatedThumbnails;
  final int id;
  final int bathrooms;
  final double latitude;
  final double longitude;
  final String country;
  final String city;
  final String listPrice;

  Listing({
    this.displayImage,
    this.hasOutdatedThumbnails,
    this.id,
    this.bathrooms,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    this.listPrice,
  });

  factory Listing.fromJSON(map) {
    return Listing(
      displayImage: map["displayImage"],
      hasOutdatedThumbnails: map["hasOutdatedThumbnails"],
      id: map["id"],
      latitude: double.parse(map["latitude"]),
      longitude: double.parse(map["longitude"]),
      bathrooms: map["bathrooms"],
      listPrice: map["listPrice"],
      country: map["country"],
      city: map["city"],
    );
  }
}

class Property {
  final int id;
  final String city;
  final String country;
  final String listPrice;
  final int yearBuilt;
  final String description;

  Property({
    this.id,
    this.city,
    this.country,
    this.listPrice,
    this.yearBuilt,
    this.description,
  });

  factory Property.fromJSON(map) {
    List<dynamic> photos = map['photos'];

    return Property(
      id: map["id"],
      city: map["city"],
      country: map["country"],
      listPrice: map["listPrice"],
      yearBuilt: map["yearBuilt"],
      description: map["description"],
    );
  }
}

class CamLatLngBounds {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;

  CamLatLngBounds({
    this.northEastLat,
    this.northEastLng,
    this.southWestLat,
    this.southWestLng,
  });
}
