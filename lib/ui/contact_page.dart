import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/helpers/contact_help.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  bool _userEdited = false;
  Contact _editedContact;

  ContactHelper _helper = ContactHelper();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.contact == null) {
        _editedContact = Contact();
      } else {
        _editedContact = Contact.fromMap(widget.contact.toMap());

        _nameController.text = _editedContact.name;
        _emailController.text = _editedContact.email;
        _phoneController.text = _editedContact.phone;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            _saveContact(context);
          },
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _editedContact.img != null
                        ? FileImage(File(_editedContact.img))
                        : AssetImage('images/person.png'))),
                ),
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                    if (file != null) {
                      _userEdited = true;
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
                style: TextStyle(fontSize: 18.0),
                onChanged: (text) {
                  _userEdited = true;
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                style: TextStyle(fontSize: 18.0),
                onChanged: (text) {
                  _userEdited = true;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                ),
                style: TextStyle(fontSize: 18.0),
                onChanged: (text) {
                  _userEdited = true;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveContact(BuildContext context) {
    if (_editedContact.name != null && _nameController.text.isEmpty) {
      FocusScope.of(context).requestFocus(_nameFocus);
      return;
    }

    _editedContact.name = _nameController.text;
    _editedContact.email = _emailController.text;
    _editedContact.phone = _phoneController.text;

    if (_editedContact.id != null) {
      _helper.updateContact(_editedContact);
    } else {
      _helper.saveContact(_editedContact);
    }

    Navigator.pop(context, _userEdited ? _editedContact : null);
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Descartar alterações?'),
            content: Text('Se você sair as alterações serão perdidas.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Sim'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
