import 'package:flutter/material.dart';
import 'package:project_bander/api/api_handler.dart';
import 'package:project_bander/modules/layout/data/details_screen/available_flights.dart';
import 'package:project_bander/modules/layout/data/passenger_data.dart';
import 'package:project_bander/modules/layout/data/status.dart';
import 'package:project_bander/modules/layout/data/veriflcation.dart';
import '../../../core/theme/app_color.dart';
import '../../widget/drawer/my_custom_drawer.dart';

class HomeTab extends StatefulWidget {
  static const route = "hometab";
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<ApiStation> _stations = [];
  bool _loadingStations = true;
  ApiStation? fromStation;
  ApiStation? toStation;
  String departureDate = "اختر تاريخاً";
  int _screen = 0;
  String _selectedCategory = '';
  double _discountPercent = 0;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final result = await ApiService().getAllStations();
    if (mounted)
      setState(() {
        _loadingStations = false;
        if (result['success'] == true) {
          _stations = List<ApiStation>.from(result['data'] ?? []);
        }
      });
  }

  void _goTo(int screen) => setState(() => _screen = screen);
  void _goBack() {
    if (_screen > 0) setState(() => _screen--);
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case 1:
        return PassengerData(
          fromStation: fromStation!,
          toStation: toStation!,
          departureDate: departureDate,
          onNext: () => _goTo(2),
          onBack: _goBack,
        );
      case 2:
        return Status(
          fromStation: fromStation!,
          toStation: toStation!,
          departureDate: departureDate,
          onSkip: () {
            _discountPercent = 0;
            _goTo(4);
          },
          onNext: (cat) {
            _selectedCategory = cat;
            if (cat == 'Military' || cat == 'Disabled') {
              _discountPercent = 100;
            } else if (cat == 'Child' || cat == 'Senior') {
              _discountPercent = 50;
            }
            _goTo(3);
          },
          onBack: _goBack,
        );
      case 3:
        return Veriflcation(
          category: _selectedCategory,
          fromStation: fromStation!,
          toStation: toStation!,
          departureDate: departureDate,
          onNext: () => _goTo(4),
          onBack: _goBack,
        );
      case 4:
        return AvailableFlights(
          fromStation: fromStation!,
          toStation: toStation!,
          departureDate: departureDate,
          onBack: _goBack,
          discountPercent: _discountPercent,
        );
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      drawer: MyCustomDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColor.white,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    AppBar(
                      iconTheme: const IconThemeData(color: Colors.white),
                      backgroundColor: AppColor.black,
                      elevation: 0,
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              "assets/images/logo_img/ion_train-sharp.png",
                              width: 40,
                            ),
                            const Text(
                              "Trainy _ قطاري",
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: "Cairo",
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 350,
                      color: AppColor.black,
                    ),
                    const SizedBox(height: 180),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "المسارات الشائعة",
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildPopularRoute(
                                "اسوان الي الاقصر",
                                "تبدأ من 20",
                              ),
                              buildPopularRoute(
                                "القاهرة الي الاسكندرية",
                                "تبدأ من 15",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 390,
                    height: 420,
                    decoration: const BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              "اين تريد ان تذهب؟",
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: "Cairo",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        buildInputLabel("من"),
                        _loadingStations
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: LinearProgressIndicator(),
                              )
                            : buildStationDropdown(
                                "اختر محطة الانطلاق",
                                fromStation,
                                (val) => setState(() => fromStation = val),
                              ),
                        const SizedBox(height: 10),
                        buildInputLabel("إلى"),
                        _loadingStations
                            ? const SizedBox()
                            : buildStationDropdown(
                                "اختر محطة الوصول",
                                toStation,
                                (val) => setState(() => toStation = val),
                              ),
                        const SizedBox(height: 10),
                        buildInputLabel("تاريخ المغادرة"),
                        buildDatePickerField(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 580,
                left: 20,
                right: 20,
                child: Center(
                  child: SizedBox(
                    width: 390,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (fromStation == null ||
                            toStation == null ||
                            departureDate == "اختر تاريخاً") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "من فضلك اختر محطة الانطلاق والوصول والتاريخ",
                              ),
                            ),
                          );
                          return;
                        }
                        _goTo(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(125),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "متابعة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
    child: Align(
      alignment: Alignment.topRight,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Cairo",
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget buildStationDropdown(
    String hint,
    ApiStation? value,
    Function(ApiStation?) onChanged,
  ) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.only(left: 5, right: 15),
    height: 65,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(45),
      border: Border.all(color: Colors.black12),
      boxShadow: const [
        BoxShadow(color: Colors.black, blurRadius: 1, offset: Offset(0, 0)),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<ApiStation>(
        value: value,
        isExpanded: true,
        icon: const SizedBox.shrink(),
        hint: Row(
          children: [
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: 30,
            ),
            const Spacer(),
            Text(
              hint,
              style: const TextStyle(
                fontFamily: "Cairo",
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(Icons.train, color: Colors.black, size: 28),
          ],
        ),
        selectedItemBuilder: (_) => _stations
            .map<Widget>(
              (s) => Row(
                children: [
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 30,
                  ),
                  const Spacer(),
                  Text(
                    s.stationName,
                    style: const TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(Icons.train, color: Colors.black, size: 28),
                ],
              ),
            )
            .toList(),
        items: _stations
            .map(
              (s) => DropdownMenuItem<ApiStation>(
                value: s,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    s.stationName,
                    style: const TextStyle(fontFamily: "Cairo", fontSize: 22),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget buildDatePickerField() => GestureDetector(
    onTap: () async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );
      if (picked != null)
        setState(() {
          departureDate =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        });
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(49),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 1, offset: Offset(0, 0)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Text(
              departureDate,
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 20,
                color: departureDate == "اختر تاريخاً"
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(Icons.calendar_month, color: Colors.black, size: 28),
          ],
        ),
      ),
    ),
  );

  Widget buildPopularRoute(String route, String price) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        route,
        style: const TextStyle(
          fontFamily: "Cairo",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      Text(
        price,
        style: const TextStyle(
          fontFamily: "Cairo",
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    ],
  );
}
