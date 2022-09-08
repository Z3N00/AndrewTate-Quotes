
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:toast/toast.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';


// Main start of the app
void main() {

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

// setting App name and home
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Andrew Tate Quotes',
      home: MainPage(),
    );
  }

}

class MainPage extends StatefulWidget {

   @override
  _MainState createState() => _MainState();

}

class _MainState extends State<MainPage> {

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _isAdloaded = false;
  bool _isInterAdloaded = false;

  String quote, owner, imglink;
  bool working = false;
  final grey = Colors.blueGrey[800];
  ScreenshotController screenshotController;

  @override
  void initState() {

    super.initState();
    screenshotController = ScreenshotController();
    quote = "";

    imglink = "";

    _initBannerAd();
    getQuote();
    _initAd();


  }

  // get a interstitial ad
  void _initAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? "ca-app-pub-7825997610273388/6299887020" : "ca-app-pub-7825997610273388/4958885198",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: onAdLoaded,
          onAdFailedToLoad: (error) {}
      )
    );
  }

  void onAdLoaded(InterstitialAd ad){
    _interstitialAd = ad;
    _isInterAdloaded = true;

    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
          _interstitialAd.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
          _interstitialAd.dispose();
      }
    );
  }

  // get a banner ad
  _initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid ? "ca-app-pub-7825997610273388/2306184585" : "ca-app-pub-7825997610273388/3779048357",
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isAdloaded = true;
          },
          onAdFailedToLoad: (ad, error) {},
        ),
        request: AdRequest(),
    );
    _bannerAd.load();
  }

  // get a random Quote from the API
  getQuote() async {
    try {
      setState(() {
        working = true;
        quote = imglink = "";
      });
      var response = await http.post(
          Uri.encodeFull('http://api.forismatic.com/api/1.0/'),
          body: {"method": "getQuote", "format": "json", "lang": "en"});
      setState(() {
        try {
          var res = jsonDecode(response.body);
          owner = res["quoteAuthor"].toString().trim();
          quote = res["quoteText"].replaceAll("â", " ");
          getImg("Andrew Tate");
        } catch (e) {
          getQuote();
        }
      });
    } catch (e) {
      offline();
    }
  }

  // if it is offline, show a fixed Quote
  offline() {
    setState(() {
      owner = "Andrew Tate Top G";
      quote = "Turn On Your Internet Pussy!!";
      imglink = "";
      working = false;
    });
  }

  // When copy button clicked, copy the quote to clipboard
  copyQuote() {
    ClipboardManager.copyToClipBoard(quote + "\n- ").then((result) {
      Toast.show("Quote Copied", context, duration: Toast.LENGTH_SHORT);
    });
  }

  // When share button clicked, share a text and screnshot of the quote
  shareQuote() async {
    final directory = (await getApplicationDocumentsDirectory())
        .path; //from path_provide package
    String path =
        '$directory/screenshots${DateTime.now().toIso8601String()}.png';
    screenshotController.capture(path: path).then((_) {
      Share.shareFiles([path], text: quote);
    }).catchError((onError) {
      print(onError);
    });
  }

  // get image of the quote author, using Wikipedia Api
  getImg(String name) async {
    // var image = await http.get(
    //     "https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrlimit=1&prop=pageimages%7Cextracts&pithumbsize=400&gsrsearch=" +
    //         name +
    //         "&format=json");

    var image = Image.asset("img/s1.jpg");


    setState(() {
      try {
       // var res = json.decode(image.body)["query"]["pages"];
       // res = res[res.keys.first];
        imglink = image as String;
        print("-------------------------------------");
        print(imglink);
        print("----------------------------------------");
      } catch (e) {
        imglink = "";
      }
      working = false;
    });
  }

  // Choose to show the loaded image from the Api or the offline one
  Widget drawImg() {
    // if (imglink.isEmpty) {
    //   return Image.asset("img/offline.jpg", fit: BoxFit.cover);
    // } else {
    //   return Image.asset("img/s1.jpg", fit: BoxFit.cover);
    // }
    var rnd = Random();
    var digit = rnd.nextInt(10);
    //print(digit);
    return Image.asset("img/s${digit}.jpg", fit: BoxFit.cover);

  }

  // Main build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[

              drawImg(),
              Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.6, 1],
                      colors: [
                        grey.withAlpha(70),
                        grey.withAlpha(220),
                        grey.withAlpha(255),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: quote != null ? '“ ' : "",
                              style: TextStyle(
                                  fontFamily: "Ic",
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30),
                              children: [
                                TextSpan(
                                    text: quote != null ? quote : "",
                                    style: TextStyle(
                                        fontFamily: "Ic",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22)),
                                TextSpan(
                                    text: quote != null ? '”' : "",
                                    style: TextStyle(
                                        fontFamily: "Ic",
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green,
                                        fontSize: 30))
                              ]),
                        ),
                        // Text(owner.isEmpty ? "" : "\n" + owner,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //         fontFamily: "Ic",
                        //         color: Colors.white,
                        //         fontSize: 18)),
                      ])),
              AppBar(
                title: Text(
                  "What Colour is Your Bugatti?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
            ]),
      ),
      bottomNavigationBar: _isAdloaded ? Container(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd,),
      ) : SizedBox(),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                if(!working){
                  getQuote();
                  if(_isInterAdloaded){
                    _initAd();
                    _interstitialAd.show();
                  }
                }else {
                      null;
                  }
              },
                //!working ? getQuote : null,
                // if (_isInterAdloaded) {
                //   _interstitialAd.show();
                // }
              child: Icon(Icons.refresh, size: 35, color: Colors.white),
            ),
            InkWell(
              onTap: quote.isNotEmpty ? copyQuote : null,
              child: Icon(Icons.content_copy, size: 30, color: Colors.white),
            ),
            InkWell(
              onTap: quote.isNotEmpty ? shareQuote : null,
              child: Icon(Icons.share, size: 30, color: Colors.white),
            )
          ]),
    );
  }
}
