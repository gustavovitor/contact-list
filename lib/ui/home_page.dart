import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/helpers/contact_help.dart';
import 'package:lista_contatos/ui/contact_page.dart';

import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {ordemaz, ordemza}

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

  void _getAllContacts() {
    helper.findAll().then((contacts) {
      setState(() {
        this.contacts = contacts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            onSelected: (value) {
              _orderList(value);
            },
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar A-Z'),
                value: OrderOptions.ordemaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar Z-A'),
                value: OrderOptions.ordemza,
              ),
            ]
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToContactPage(context);
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, contacts[index]);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, Contact contact) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                        image: contact.img != null
                            ? FileImage(File(contact.img))
                            : AssetImage('images/person.png'))),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(contact.name ?? "", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0
                ),),
                Container(
                  width: 220,
                  child: Text(contact.email ?? "", style: TextStyle(
                    fontSize: 18.0
                  ),),
                ),
                Text(contact.phone ?? "", style: TextStyle(
                  fontSize: 18.0
                ),)
              ],
            )
          ],
        ),
      ),
      onTap: () {
        _showOptions(context, contact);
      },
    );
  }

  void _navigateToContactPage(BuildContext context, {Contact contact}) async {
    final receivedContact = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact)
      )
    );

    if (receivedContact != null) {
      _getAllContacts();
    }
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text('Ligar', style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        Navigator.pop(context);
                        launch('tel:${contact.phone}');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text('Editar', style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToContactPage(context, contact: contact);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text('Excluír', style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        helper.deleteContact(contact.id);
                        setState(() {
                          contacts.removeAt(contacts.indexOf(contact));
                        });
                        Navigator.pop(context);
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

  void _orderList(OrderOptions selected) {
    setState(() {
      switch (selected) {
        case OrderOptions.ordemaz:
          contacts.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case OrderOptions.ordemza:
          contacts.sort((a, b) {
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
          break;
      }
    });
  }
}
