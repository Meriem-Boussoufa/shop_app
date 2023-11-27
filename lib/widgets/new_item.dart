import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/data/categories.dart';
import 'package:shop_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _fromKey = GlobalKey<FormState>();
  var _enteredName = '';
  int _enteredQuantity = 0;
  Category _selectedCategory = categories[Categories.fruit]!;
  bool _isLoading = false;

  void _saveItem() {
    if (_fromKey.currentState!.validate()) {
      _fromKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final url = Uri.https('light-client-367617-default-rtdb.firebaseio.com',
          'shopping-list.json');
      http
          .post(url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(
                {
                  'name': _enteredName,
                  'quantity': _enteredQuantity,
                  'category': _selectedCategory.title,
                },
              ))
          .then((res) {
        final Map<String, dynamic> resData = json.decode(res.body);
        if (res.statusCode == 200) {
          Navigator.of(context).pop(
            GroceryItem(
              id: resData['name'],
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _fromKey,
            child: Column(
              children: [
                TextFormField(
                  onSaved: (newValue) {
                    _enteredName = newValue!;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  maxLength: 50,
                  validator: (String? value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                          onSaved: (newValue) {
                            _enteredQuantity = int.parse(newValue!);
                          },
                          keyboardType: TextInputType.number,
                          initialValue: '1',
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                          ),
                          validator: (String? value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'Must be a valid, positive number.';
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: DropdownButtonFormField(
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    height: 16,
                                    width: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.value.title),
                                ],
                              ))
                      ],
                      value: _selectedCategory,
                      onChanged: (Category? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ))
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _fromKey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
