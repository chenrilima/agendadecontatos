import 'dart:io';

import 'package:agendacontatos_app/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _namedFocus = FocusNode();

  bool _userEdited = false;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if(widget.contact == null) {
        _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.peso;
      _emailController.text = _editedContact.data;

    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
       child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(_editedContact.peso ?? "New Contact"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if(_editedContact.peso != null && _editedContact.peso.isNotEmpty){
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_namedFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null ?
                          FileImage(File(_editedContact.img)) :
                          AssetImage("images/img.png"),
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera).then((file){
                      if(file == null) return;
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _namedFocus,
                  decoration: InputDecoration(labelText: "Name"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.peso = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.data = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<bool> _requestPop() {
    if(_userEdited){
      showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Discard Changes?"),
          content: Text("If you get out, the changes will be lost"),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },

            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }

  }

}
