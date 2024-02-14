import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled14/Cubit/States.dart';

import '../Model/ProductModel.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(initialState());
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController emailRegister = TextEditingController();
  TextEditingController passwordRegister = TextEditingController();
  TextEditingController phone_number = TextEditingController();
  TextEditingController emailLogin = TextEditingController();
  TextEditingController passwordLogin = TextEditingController();
  TextEditingController creditCardController = TextEditingController();
  List<ProductModel> productsCard = [];
  List<ProductModel> order = [];
  String paymentMethod = "";
  List<int> count = [];
  int loggedUserId = -1;
  double totalPrice = 0.0;

  void addProductToCard(ProductModel product) {
    productsCard.add(product);
    totalPrice += product.price;

    emit(ProductsAddedToCard());
  }

  bool isShowed = true;

  void showPassword(bool x) {
    isShowed = x;
    emit(ShowPasswordState());
  }

  static AppCubit get(context) => BlocProvider.of(context);
  late Database databas;

  Widget showTextField() {
    if (paymentMethod == "Visa") {
      return TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return "This field is required";
          }
          return null;
        },
        controller: creditCardController,
        decoration: InputDecoration(hintText: "Credit card Number"),
      );
    }
    return Text("");
  }

  createDatabase() {
    openDatabase(
      'e-commerce.db',
      version: 4,
      onCreate: (db, version) async {
        print("Database Created");
        await db
            .execute(
                "Create Table users (id INTEGER PRIMARY KEY,name TEXT,phoneNumber TEXT ,email TEXT,password TEXT,address TEXT)")
            .then((value) {
          print("Table created");
        }).catchError((onError) {
          print("Catched Error is ${onError.toString()}");
        });
        await db
            .execute(
                "CREATE TABLE orders (id INTEGER PRIMARY KEY, userId INTEGER, productName TEXT, quantity INTEGER, totalPrice REAL,creditCardNumber ,FOREIGN KEY (userId) REFERENCES users(id))")
            .then((value) {
          print("Orders Table created");
        }).catchError((onError) {
          print("Catched Error is ${onError.toString()}");
        });
      },
      onOpen: (db) {
        print("Database Opened");
      },
    ).then((value) {
      databas = value;

      getProfileFromDatabaase();
    });
    emit(CreateDataProfile());
  }

  void insertIntoDatabase(String name, String phoneNumber, String email,
      String password, String address) async {
    await databas.transaction((txn) async {
      txn
          .rawInsert(
              'Insert into users (name,phoneNumber,email,password,address) VALUES ("$name","$phoneNumber","$email","$password","$address")')
          .then((value) {
        print("$value raw inserted");
      }).catchError((e) {
        print(e);
      });
    });
    Future<int?> authenticateUser(String email, String password) async {
      // Your authentication logic here, which could involve an API call or database lookup
      // Return the user ID if authentication is successful, or null otherwise
      // For demonstration purposes, let's return a hardcoded user ID (1) for successful login
      return 1;
    }

    getProfileFromDatabaase();
    emit(InsertinProfile());
  }

  void insertInOrders(String productName, int quantity, double price,
      int userID, String creditCard) async {
    await databas.transaction((txn) async {
      txn
          .rawInsert(
              'Insert into orders (userId, productName, quantity, totalPrice,creditCardNumber) VALUES ($userID, "$productName", $quantity, $price,$creditCard)')
          .then((value) {
        print("$value raw inserted");
      }).catchError((e) {
        print(e);
      });
    });
    getOrdersFromDatabaase();
    emit(InsertInOrders());
  }

  Future<int?> getUserIdByEmail(String email) async {
    // Ensure that the databaseProfile is initialized before using it
    if (databas == null) {
      await createDatabase(); // Initialize the databaseProfile
    }

    // Fetch user data from the database
    final data =
        await databas.rawQuery("SELECT id FROM users WHERE email=?", [email]);

    if (data.isNotEmpty) {
      return data.first['id'] as int?; // Return the user ID as an int
    } else {
      return null; // Return null if no user is found with the given email
    }
  }

  void deleteFromOrders(int id) async {
    await databas.rawDelete('Delete from orders WHERE id=?', [id]).then(
        (value) => print("raw deleted"));
    getOrdersFromDatabaase();
    emit(DeleteFromOrders());
  }

  List<Map> orders = [];

  Future<List<Map>> getOrdersFromDatabaase() async {
    // Ensure that the databaseProfile is initialized before using it
    if (databas == null) {
      await createDatabase(); // Initialize the databaseProfile
    }

    // Fetch data from the database
    final data = await databas.rawQuery("Select * from orders");
    orders = data;
    // print(orders);
    emit(getFromOrders());
    return orders;
  }

  List<Map> datalogin = [];

  Future<List<Map>> getProfileFromDatabaase() async {
    // Ensure that the databaseProfile is initialized before using it
    if (databas == null) {
      await createDatabase(); // Initialize the databaseProfile
    }

    // Fetch data from the database
    final data = await databas.rawQuery("Select * from users");
    datalogin = data;
    print(datalogin);
    emit(getFromDataProfile());
    return datalogin;
  }

  void deleteFromDatabase(int id) async {
    await databas.rawDelete('Delete from users WHERE id=?', [id]).then(
        (value) => print("raw deleted"));
    getFromDataProfile();
    emit(DeleteFromUsersDatabase());
  }
}
