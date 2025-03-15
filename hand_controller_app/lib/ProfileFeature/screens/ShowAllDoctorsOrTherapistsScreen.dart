import 'package:flutter/material.dart';
import 'package:hand_controller_app/AuthFeature/models/Doctor.dart';
import 'package:hand_controller_app/ProfileFeature/screens/ProfileScreen.dart';
import 'package:hand_controller_app/ProfileFeature/services/RatingService.dart';
import 'package:hand_controller_app/core/widgets/AppBarWidget.dart';
import 'package:hand_controller_app/core/widgets/LoadingWidget.dart';
import '../../AuthFeature/services/AuthService.dart';
import '../../AuthFeature/services/UserService.dart';
import '../../AlertDialogs/ExitDialogWidget.dart';
import '../../GlobalThemeData.dart';
import '../models/Rating.dart';

class ShowAllDoctorsOrTherapistsScreen extends StatefulWidget {
  const ShowAllDoctorsOrTherapistsScreen({Key? key}) : super(key: key);

  @override
  _ShowAllDoctorsOrTherapistsScreenState createState() =>
      _ShowAllDoctorsOrTherapistsScreenState();
}

class _ShowAllDoctorsOrTherapistsScreenState
    extends State<ShowAllDoctorsOrTherapistsScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final RatingService ratingService = RatingService();

  late Future<void> _fetchDoctorsFuture;

  late List<Doctor> doctors;
  List<Doctor> filteredDoctors = [];
  List<bool> _isExpandedList = [];
  Map<String, List<Rating>> ratingsMap = {};
  TextEditingController searchController = TextEditingController();

  bool _isFilterTileExpended = false;

  late String userId;

  String _searchByField = 'name'; // Default search by
  String _orderByField = 'name'; // Default order by
  bool _isAscending = true; // Default sorting order
  String _searchedString = ''; // Search text entered

  @override
  void initState() {
    super.initState();
    _fetchDoctorsFuture = fetchDoctors();
  }

  void _applyFilters() {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        String valueToSearch = '';
        switch (_searchByField) {
          case 'name':
            valueToSearch = doctor.name;
            break;
          case 'specialization':
            valueToSearch = doctor.specialization;
            break;
        }
        return valueToSearch.toLowerCase().contains(_searchedString.toLowerCase());
      }).toList();

      if (_orderByField.isNotEmpty) {
        filteredDoctors.sort((a, b) {
          var valueA = '';
          var valueB = '';
          switch (_orderByField) {
            case 'name':
              valueA = a.name.toLowerCase();
              valueB = b.name.toLowerCase();
              break;
            case 'rating':
              valueA = a.rating.toString();
              valueB = b.rating.toString();
              break;
          }
          return _isAscending ? valueA.compareTo(valueB) : valueB.compareTo(valueA);
        });
      }
    });
  }

  Widget _buildSearchByButton(String field, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchByField = field;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _searchByField == field
              ? CustomTheme.accentColor2
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _searchByField == field ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _filterBySearchField(String searchText) {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        String valueToSearch = '';
        switch (_searchByField) {
          case 'name':
            valueToSearch = doctor.name;
            break;
          case 'specialization':
            valueToSearch = doctor.specialization;
            break;
        }
        return valueToSearch.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  Widget _buildOrderByButton(String field, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_orderByField == field) {
            _isAscending = !_isAscending; // Toggle sorting order
          } else {
            _orderByField = field; // Set the new sort field
            _isAscending = true; // Default to ascending order
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _orderByField == field
              ? CustomTheme.accentColor2
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _orderByField == field ? Colors.white : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_orderByField == field)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchDoctors() async {
    String? uid = await userService.getUserUid();
    if (uid != null) {
      List<dynamic>? doctorsLocal = await userService.getUsersByRoles(['Doctor', 'Therapist']);

      if (doctorsLocal.isNotEmpty) {
        List<Doctor> fetchedDoctors = doctorsLocal.cast<Doctor>();

        Map<String, List<Rating>> tempRatingsMap = {};
        for (var doctor in fetchedDoctors) {
          List<Rating> ratings = await ratingService.getRatingsByDoctorId(doctor.uid);
          tempRatingsMap[doctor.uid] = ratings;
        }

        setState(() {
          ratingsMap = tempRatingsMap;
          doctors = fetchedDoctors;
          filteredDoctors = fetchedDoctors;
          userId = uid;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await ExitDialog.showExitDialog(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              height: kToolbarHeight + 20,
            ),
            Column(
              children: [
                AppBarWidget(leadingIcon: Icons.arrow_back,),
                Expanded(
                  child: FutureBuilder(
                    future: _fetchDoctorsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CustomTheme.mainColor2,
                                  CustomTheme.mainColor
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: const Center(
                                child: LoadingWidget()));
                      } else {
                        _isExpandedList =
                            List.generate(doctors.length, (index) => false);
                        return showAllDoctorsContentWidget();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showAllDoctorsContentWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.mainColor2, CustomTheme.mainColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "These are the Doctors / Specialists available",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomTheme.accentColor4,
                      CustomTheme.accentColor2
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      blurRadius: 20, // Blur radius
                      offset: Offset(0, 0), // Offset of the shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search doctors...',
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _searchedString = value;
                    _filterBySearchField(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: CustomTheme.accentColor4,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    backgroundColor: Colors.transparent,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isFilterTileExpended = expanded;
                      });
                    },
                    title: const Text(
                      'Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.accentColor4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Search by:',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildSearchByButton('name', 'Name'),
                                        _buildSearchByButton('rating', 'Rating'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  const Text(
                                    'Order By:',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildOrderByButton('name', 'Name'),
                                        _buildOrderByButton('rating', 'Rating'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          CustomTheme.accentColor4,
                                          CustomTheme.accentColor2,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        searchController.clear();
                                        filteredDoctors = doctors;
                                        _applyFilters();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0, // Remove elevation
                                      ),
                                      child: const Text(
                                        "Clear All",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                          Colors.white, // Set text color to white
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          CustomTheme.accentColor4,
                                          CustomTheme.accentColor2,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _applyFilters();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0, // Remove elevation
                                      ),
                                      child: const Text(
                                        "Apply",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.white, // Set text color to white
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  final doctorRatings = ratingsMap[doctor.uid] ?? [];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: CustomTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Theme(
                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        backgroundColor: Colors.transparent,
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isExpandedList[index] = expanded;
                          });
                        },
                        title: Text(
                          doctor.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: CustomTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Specialization:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    doctor.specialization,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8,),
                                  const Text(
                                    'Email:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    doctor.email,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  const Text(
                                    'Phone Number:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    doctor.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  const Text(
                                    'Rating:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) {
                                        double averageRating = doctorRatings.isNotEmpty
                                            ? doctorRatings.map((rating) => rating.starsNumber).reduce((a, b) => a + b) / doctorRatings.length
                                            : 0.0;

                                        if (index < averageRating.floor()) {
                                          return Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          );
                                        } else if (index < averageRating &&
                                            (averageRating - index) >= 0.5) {
                                          return Icon(
                                            Icons.star_half,
                                            color: Colors.yellow,
                                          );
                                        } else {
                                          return Icon(
                                            Icons.star_border,
                                            color: Colors.yellow,
                                          );
                                        }
                                      }),
                                      Text(
                                        '(${doctorRatings.length})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            CustomTheme.accentColor4,
                                            CustomTheme.accentColor2,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await userService.updateUserField(userId, 'doctorId', doctor.uid);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfileScreen(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          elevation: 0, // Remove elevation
                                        ),
                                        child: const Text(
                                          "Choose",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .white, // Set text color to white
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
