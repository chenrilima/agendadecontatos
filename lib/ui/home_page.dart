
import 'dart:io';

import 'package:agendacontatos_app/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
               const PopupMenuItem<OrderOptions> (
                 child: Text("Order from A-Z"),
                 value: OrderOptions.orderaz,
               ),
              const PopupMenuItem<OrderOptions> (
                child: Text("Order from Z-A"),
                value: OrderOptions.orderza,
              ),
          ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
            Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: contacts[index].img != null ?
                  FileImage(File(contacts[index].img)) :
                  AssetImage("images/img.png"),
                  fit: BoxFit.cover
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start ,
                children: [
                Text(contacts[index].peso ?? "",
            style: TextStyle(fontSize: 22.0,
                fontWeight: FontWeight.bold),
          ),
          Text(contacts[index].data ?? "",
          style: TextStyle(fontSize: 18.0),
          ),
            ],
    ),
    )
            ],
    ),
    ),
    ),
      onTap: () {
        _showOptions(context, index);
      },
    );
        }

     void _showOptions(BuildContext context, int index) {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheet(
                onClosing: (){},
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         Padding(
                           padding: EdgeInsets.all(10.0),
                           child:  FlatButton(
                             child: Text("Call",
                               style: TextStyle(color: Colors.blue, fontSize: 20.0),
                             ),
                             onPressed: () {
                                  launch("tel:${contacts[index].data}");
                                  Navigator.pop(context);
                             },
                           ),
                         ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child:  FlatButton(
                              child: Text("Edit",
                                style: TextStyle(color: Colors.blue, fontSize: 20.0),
                              ),
                              onPressed: () {
                                  Navigator.pop(context); // fechar a janela e ir pra próxima
                                  _showContactPage(contact: contacts[index]);
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child:  FlatButton(
                              child: Text("Delete",
                                style: TextStyle(color: Colors.pink, fontSize: 20.0),
                              ),
                              onPressed: () {
                                helper.deleteContact(contacts[index].id);
                               setState(() {
                                 contacts.removeAt(index);
                                 Navigator.pop(context);
                               });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
              );
            }
            );
     }

     void  _showContactPage({Contact contact}) async {
     final recContact =  await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
        );
     if(recContact != null) {
       if(contact != null) {
         await helper.updateContact(recContact);
         _getAllContacts();
       } else {
         await helper.saveContact(recContact);
       }
       _getAllContacts();
     }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
        return  a.peso.toLowerCase().compareTo(b.peso.toLowerCase());
            });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
         return b.peso.toLowerCase().compareTo(a.peso.toLowerCase());
              });
        break;
    }
    setState(() {

    });
  }

}
