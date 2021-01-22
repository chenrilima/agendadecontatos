import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String pesoColumn = "pesoColumn";
final String dataColumn = "dataColumn";
final String imgColumn = "imgColumn";

// definindo o nome das colunas, com final, não é possível mudar o valor da String

class ContactHelper { // criando a classe ContatcHelper

    static final ContactHelper _instance = ContactHelper.internal(); // variavel da minha classe e criando um objeto da própria classe

    factory ContactHelper() => _instance;

    ContactHelper.internal();

    Database _db;

  Future<Database>  get db async {
      if(_db != null) {
          return _db;
      } else {
        _db =  await initDb();
        return _db;
      }
    }

   Future<Database> initDb() async { // usando async e await, pois o getDatabase não retorna no mesmo instante.
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "contactsnew.db");
      
     return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
        await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $pesoColumn TEXT, $dataColumn TEXT,"
              "$imgColumn TEXT)"
        );
      });
    }

  Future<Contact>  saveContact(Contact contact) async {
      Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
    }

    Future<Contact> getContact (int id) async {
      Database dbContact = await db;
      List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, pesoColumn, dataColumn, imgColumn],
        where: "$id = ?",
        whereArgs: [id]);
      if(maps.length > 0) {
        return Contact.fromMap(maps.first);
      } else {
        return null;
      }
    }

  Future<int>  deleteContact(int id) async {
      Database dbContact = await db;
     return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]); // deletar um contato, onde o id é mesmo id que passei.
    }

  Future<int>  updateContact(Contact contact) async {
      Database dbContact = await db;
    return await  dbContact.update(contactTable,
          contact.toMap(),
          where: "$idColumn = ?",
          whereArgs: [contact.id]);
    }

   Future<List> getAllContacts() async {
      Database dbContact = await db;
      List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
      List<Contact> listContact = List();
      for(Map m in listMap) { // para cada mapa na lista de mapas, eu transformo em contato e adiciono na listContact
        listContact.add(Contact.fromMap(m));
      }
      return listContact;
    }

   Future<int> getNumber() async {
      Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable "));
    }

   Future close() async {
      Database dbContact = await db;
    dbContact.close();
       }
    }

class Contact { // criando a classe Contact

  int id;
  String peso;
  String data;
  String img;

  Contact();

  Contact.fromMap( Map map) { // criando um construtor que usará um map
    id = map[idColumn];
    peso = map[pesoColumn];
    data = map[dataColumn];
    img = map[imgColumn];
  }

  Map toMap() { // função que transforma os dados do contato em mapa
    Map<String, dynamic> map = {
      pesoColumn: peso,
      dataColumn: data,
      imgColumn: img,
    };
    if(id != null) { // se o id for diferente de nulo, eu armazeno o id
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, Peso: $peso, Data: $data, img: $img)";
  }
}
