import 'package:flutter/material.dart';
import 'package:flutter_map_ui_test/models.dart';

class DetailScreenPage extends StatefulWidget {

  final Listing listing;

  const DetailScreenPage({Key key, this.listing}) : super(key: key);

  @override
  DetailScreenPageState createState() {
    return new DetailScreenPageState();
  }
}

class DetailScreenPageState extends State<DetailScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 12.0),
              height: 6.0,
              width: 60.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'DETAIL VIEW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${widget.listing.city}, ${widget.listing.country}',
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
                      '\$${widget.listing.listPrice}',
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
      ),
    );
  }
}
