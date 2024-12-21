/// main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyC6aBglqWSZrbgXJ7uIOFy8O4gzxpkBhnU",
          authDomain: "grocery-1c168.firebaseapp.com",
          projectId: "grocery-1c168",
          storageBucket: "grocery-1c168.appspot.com",
          messagingSenderId: "440373061013",
          appId: "1:440373061013:web:3ec814bec6a5a66bc2029c"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery Admin',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

// LoginPage
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty ? 'Please enter an email' : null,
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a password' : null,
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 16),
              if (isLoading) CircularProgressIndicator(),
              if (!isLoading)
                ElevatedButton(
                  onPressed: loginUser,
                  child: Text('Login'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text('Don’t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SignupPage
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup Failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty ? 'Please enter an email' : null,
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a password' : null,
                onSaved: (value) => password = value!,
              ),
              SizedBox(height: 16),
              if (isLoading) CircularProgressIndicator(),
              if (!isLoading)
                ElevatedButton(
                  onPressed: signupUser,
                  child: Text('Sign Up'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modify HomePage to include Logout
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
              child: Text('View Orders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
              child: Text('Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                );
              },
              child: Text('Manage Products'),
            ),
          ],
        ),
      ),
    );
  }
}


// orders_page.dart
class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String searchQuery = '';

  Stream<QuerySnapshot> getOrders() {
    if (searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection('orders').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('userName', isGreaterThanOrEqualTo: searchQuery)
          .where('userName', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by User Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: Image.network(
                  order['imageUrl'] ?? '',
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                title: Text(order['userName']),
                subtitle: Text('Total: \$${order['totalPrice']}'),
                trailing: Text(order['orderDate'].toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String category = '';
  int price = 0;
  int salePrice = 0;
  bool isOnSale = false;
  bool isPiece = false;
  File? image; // For mobile
  XFile? webImage; // For web

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          webImage = pickedFile; // Store XFile for web
        } else {
          image = File(pickedFile.path); // Store File for mobile
        }
      });
    }
  }

  Future<String> uploadImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().millisecondsSinceEpoch}');

    if (kIsWeb && webImage != null) {
      // Web: Upload image as bytes
      final data = await webImage!.readAsBytes();
      await ref.putData(data);
    } else if (image != null) {
      // Mobile: Upload image as file
      await ref.putFile(image!);
    } else {
      throw Exception("No image selected");
    }

    return await ref.getDownloadURL();
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (image == null && webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    String imageUrl = await uploadImage();

    final newProduct = {
      'title': title,
      'productCategoryName': category,
      'price': price,
      'salePrice': salePrice,
      'isOnSale': isOnSale,
      'isPiece': isPiece,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now(),
    };

    await FirebaseFirestore.instance.collection('products').add(newProduct);

    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category' : null,
                onSaved: (value) => category = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => price = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                salePrice = value!.isNotEmpty ? int.parse(value) : 0,
              ),
              SwitchListTile(
                title: Text('On Sale'),
                value: isOnSale,
                onChanged: (value) => setState(() => isOnSale = value),
              ),
              SwitchListTile(
                title: Text('Is Piece'),
                value: isPiece,
                onChanged: (value) => setState(() => isPiece = value),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 16),

              // Image Display
              if (kIsWeb && webImage != null)
                FutureBuilder<Uint8List>(
                  future: webImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading image');
                    } else if (snapshot.hasData) {
                      return Image.memory(snapshot.data!, height: 200);
                    } else {
                      return Text('No image selected');
                    }
                  },
                ),
              if (!kIsWeb && image != null)
                Image.file(image!, height: 200),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String searchQuery = '';

  Stream<QuerySnapshot> getProducts() {
    if (searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection('products').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .snapshots();
    }
  }

  Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by Product Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(
                  product['imageUrl'] ?? '',
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
                title: Text(product['title']),
                subtitle: Text('Price: \$${product['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final productData = {
                          'title': product['title'],
                          'productCategoryName': product['productCategoryName'],
                          'price': product['price'],
                          'salePrice': product['salePrice'],
                          'isOnSale': product['isOnSale'],
                          'isPiece': product['isPiece'],
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductPage(
                              productId: product.id,
                              productData: productData,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  EditProductPage({required this.productId, required this.productData});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}
class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String category;
  late int price;
  late int salePrice;
  late bool isOnSale;
  late bool isPiece;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing product data, with type casting for numbers
    title = widget.productData['title'];
    category = widget.productData['productCategoryName'];
    price = int.tryParse(widget.productData['price'].toString()) ?? 0; // Handle String to int conversion
    salePrice = int.tryParse(widget.productData['salePrice'].toString()) ?? 0; // Handle String to int conversion
    isOnSale = widget.productData['isOnSale'] ?? false;
    isPiece = widget.productData['isPiece'] ?? false;
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Update product in Firestore
    await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
      'title': title,
      'productCategoryName': category,
      'price': price,
      'salePrice': salePrice,
      'isOnSale': isOnSale,
      'isPiece': isPiece,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                initialValue: category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
                onSaved: (value) => category = value!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => price = int.tryParse(value!) ?? 0,
              ),
              TextFormField(
                initialValue: salePrice.toString(),
                decoration: InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => salePrice = int.tryParse(value ?? '0') ?? 0,
              ),
              SwitchListTile(
                title: Text('On Sale'),
                value: isOnSale,
                onChanged: (value) => setState(() => isOnSale = value),
              ),
              SwitchListTile(
                title: Text('Is Piece'),
                value: isPiece,
                onChanged: (value) => setState(() => isPiece = value),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateProduct,
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
