part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> provinceData = [];
  bool isLoading = false;
  bool isLoadingCityOrigin = false;
  bool isLoadingCityDestination = false;

  Future<dynamic> getProvinces() async {
    await MasterDataService.getProvince().then((value) {
      setState(() {
        provinceData = value;
      });
    });
  }

  dynamic provinceIdOrigin;
  dynamic selectedprovinceOrigin;

  dynamic provinceIdDestination;
  dynamic selectedprovinceDestination;

  dynamic cityDataOrigin;
  dynamic cityIdOrigin;
  dynamic selectedCityOrigin;

  dynamic cityDataDestination;
  dynamic cityIdDestination;
  dynamic selectedCityDestination;

  Future<List<City>> getCities(var provId, var originORdestination) async {
    dynamic city;
    await MasterDataService.getCity(provId).then((value) {
      setState(() {
        city = value;
        if (originORdestination == 'origin') {
          isLoadingCityOrigin = false;
        } else {
          isLoadingCityDestination = false;
        }
      });
    });
    return city;
  }

  var selectedCourier = 'jne';
  List<Costs> costData = [];

  Future<dynamic> getCost(
      var courier, var origin, var destination, var weight) async {
    dynamic costs;
    await MasterDataService.getCost(origin, destination, weight, courier)
        .then((value) {
      setState(() {
        costs = value;
      });
      isLoading = false;
    });
    return costs;
  }

  var weight = 0;

  @override
  void initState() {
    super.initState();
    getProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Hitung Ongkir",
          style: TextStyle(
            color: Colors.white, // Mengatur warna teks App Bar menjadi biru
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 145, 77, 255),
      ),
      body: // Adjust padding as needed
          AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Opsi Kurir',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    DropdownButtonFormField(
                                      items: [
                                        DropdownMenuItem(
                                          value: 'jne',
                                          child: Text('jne'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'pos',
                                          child: Text('pos'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'tiki',
                                          child: Text('tiki'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCourier = value
                                              as String; // Update selected value
                                        });
                                      },
                                      value: selectedCourier,
                                      isDense:
                                          true, // Reduces the vertical space
                                      isExpanded: false,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Berat (gram)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      weight = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Origin",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButtonFormField(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceIdOrigin = value;
                                            isLoadingCityOrigin = true;
                                            selectedCityOrigin = null;
                                            cityDataOrigin = getCities(
                                                provinceIdOrigin, 'origin');
                                          });
                                          cityIdOrigin = null;
                                        },
                                        value: provinceIdOrigin,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: 'Pilih Provinsi',
                                        ),
                                      ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataOrigin,
                                  builder: (context, snapshot) {
                                    if (isLoadingCityOrigin) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityOrigin,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: selectedCityOrigin == null
                                            ? Text('Pilih Kota')
                                            : Text(selectedCityOrigin.cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityOrigin = newValue;
                                            cityIdOrigin =
                                                selectedCityOrigin.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Tidak ada data");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: Text('Pilih Kota'),
                                        items: [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20), // Adjust padding as needed
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Destination",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButtonFormField(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceIdDestination = value;
                                            isLoadingCityDestination = true;
                                            selectedCityDestination = null;
                                            cityDataDestination = getCities(
                                                provinceIdDestination,
                                                'destination');
                                            cityIdDestination = null;
                                          });
                                        },
                                        value: provinceIdDestination,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText: 'Pilih Provinsi',
                                        ),
                                      ),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataDestination,
                                  builder: (context, snapshot) {
                                    if (isLoadingCityDestination) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: selectedCityDestination == null
                                            ? Text('Pilih Kota')
                                            : Text(selectedCityDestination
                                                .cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityDestination = newValue;
                                            cityIdDestination =
                                                selectedCityDestination.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Tidak ada data");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: Text('Pilih Kota'),
                                        items: [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (cityIdDestination == null ||
                                      cityIdOrigin == null ||
                                      weight < 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Data belum lengkap!'),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    setState(() async {
                                      costData = await getCost(
                                        selectedCourier,
                                        cityIdOrigin,
                                        cityIdDestination,
                                        weight,
                                      );
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 145, 77,
                                      255), // Mengatur warna latar belakang tombol menjadi biru
                                ),
                                child: Text(
                                  'Hitung Estimasi Harga',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Mengatur warna teks menjadi putih
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: costData.isEmpty || costData[0].cost.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: Text("Tidak Ada Data"),
                            )
                          : ListView.builder(
                              itemCount: costData.length,
                              itemBuilder: (context, index) {
                                return CardProvince(costData[index]);
                              })),
                ),
              ],
            ),
            isLoading == true ? UiLoading.loadingBlock() : Container()
          ],
        ),
      ),
    );
  }
}
