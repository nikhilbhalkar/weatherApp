import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wether_app/secrets.dart';

class WetherApp extends StatefulWidget {
  const WetherApp({super.key});

  @override
  State<WetherApp> createState() => _WetherAppState();
}

class _WetherAppState extends State<WetherApp> {
  Future getCurrentWether() async {
    String cityName = 'pune';
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWetherApiKey'));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An Unexpected error occured';
      }
      return data;
      //temp = data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Wether App',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            setState(() {
              
            });
          }, icon:const Icon(Icons.refresh))
        ],
      ),
      body: 
    FutureBuilder(
      future: getCurrentWether(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Unexpected Error Occured'),
          );
        }

        final data = snapshot.data!;
        final currentdata = data['list'][0];
        final currentemp = currentdata['main']['temp'];
        final currentsky = currentdata['weather'][0]['main'];
        final currentpressure = currentdata['main']['pressure'];
        final currentwindspeed = currentdata['wind']['speed'];
        final currenthumidity = currentdata['main']['humidity'];

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main cart
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "$currentemp k",
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Icon(
                              currentsky == 'Clouds' || currentsky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              '$currentsky',
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Hourly Forcast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final hourlyforcast = data['list'];
                    final time = DateTime.parse(hourlyforcast[index + 1]['dt_txt']);
                    return CardWidget(
                      temp: hourlyforcast[index + 1]['main']['temp'].toString(),
                      time:DateFormat.j().format(time) ,
                      icon: hourlyforcast[index + 1]['weather'][0]['main'] ==
                                  'Clouds' ||
                              hourlyforcast[index + 1]['weather'][0]['main'] ==
                                  'Rain'
                          ? Icons.cloud
                          : Icons.sunny,
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //additional information
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AdditionalInfo(
                    icon: Icons.water_drop,
                    lable: 'Humidity',
                    value: currenthumidity.toString(),
                  ),
                  AdditionalInfo(
                      icon: Icons.air,
                      lable: 'Wind speed',
                      value: currentwindspeed.toString()),
                  AdditionalInfo(
                      icon: Icons.beach_access,
                      lable: 'Pressure',
                      value: currentpressure.toString()),
                ],
              )
            ],
          ),
        );
      },
    )
      ,

    );
    
    
    
  }
}

class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String lable;
  final String value;

  const AdditionalInfo({
    super.key,
    required this.icon,
    required this.lable,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(lable),
        const SizedBox(
          height: 8,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class Icondata {}

class CardWidget extends StatelessWidget {
  final String temp;
  final String time;
  final IconData icon;
  const CardWidget({
    super.key,
    required this.temp,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(temp),
          ],
        ),
      ),
    );
  }
}
