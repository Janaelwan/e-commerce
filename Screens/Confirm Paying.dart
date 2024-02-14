import 'package:flutter/material.dart';
import '../Cubit/cubit.dart';

class ConfirmPaying extends StatefulWidget {
  const ConfirmPaying({Key? key});

  @override
  State<ConfirmPaying> createState() => _ConfirmPayingState();
}

class _ConfirmPayingState extends State<ConfirmPaying> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = AppCubit.get(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Order Confirmation",
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  FutureBuilder<List<Map>>(
                    future: cubit.getProfileFromDatabaase(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Map>? userInfo = snapshot.data;
                        // Filter orders for the logged-in user
                        List<Map> loggedUser = userInfo!
                            .where((user) => user["id"] == cubit.loggedUserId)
                            .toList();

                        if (loggedUser.isEmpty) {
                          // Handle case where user data is not found
                          return Text('User information not found for the logged-in user.');
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Your address is: ${loggedUser[0]["address"]}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Your name to the order: ${loggedUser[0]["name"]}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Your email to the order: ${loggedUser[0]["email"]}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  Text(
                    "Select Your payment method",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  RadioListTile(
                    title: Text('Cash'),
                    value: 'Cash',
                    groupValue: cubit.paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        cubit.paymentMethod = value as String;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Visa'),
                    value: 'Visa',
                    groupValue: cubit.paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        cubit.paymentMethod = value as String;
                      });
                    },
                  ),
                  cubit.showTextField(),

                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.black),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          for (int i = 0; i < cubit.productsCard.length; i++) {
                            cubit.insertInOrders(
                              "${cubit.productsCard[i].title}",
                              cubit.count[i],
                              cubit.productsCard[i].price,
                              cubit.loggedUserId,
                              cubit.creditCardController.text,
                            );
                          }
                          cubit.productsCard.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Order confirmed"),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Confirm order",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
