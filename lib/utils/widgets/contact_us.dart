import 'package:workforce/utils/images_and_Labels.dart';
import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      width: MediaQuery.of(context).size.width.roundToDouble(),
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft:
                Radius.circular(5.0) //                 <--- border radius here
            ,
            topRight:
                Radius.circular(5.0) //                 <--- border radius here
            ),
      ),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(contactUs,
              width: MediaQuery.of(context).size.width.roundToDouble(),
              height: 0.25 * MediaQuery.of(context).size.height.roundToDouble(),
              fit: BoxFit.cover),
        ),
        Container(
            // width: 0.98 *
            //     MediaQuery.of(context)
            //         .size
            //         .width
            //         .roundToDouble(),
            // margin:
            //     const EdgeInsets.symmetric(horizontal: 10.0),
            margin: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: ListTile(
              title: RichText(
                text: new TextSpan(
                  style: new TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: 'For any questions or enquires ',
                        style: TextStyle(fontSize: 18.0)),
                    new TextSpan(
                        text: 'contact us or whatsapp us',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0)),
                    new TextSpan(text: ' at 98xxxxxxxx'),
                  ],
                ),
              ),
              leading: Icon(
                Icons.call_outlined,
                color: Colors.blue,
                size: 30.0,
                semanticLabel: 'Query',
              ),
            )),
      ]),
    );
  }
}
