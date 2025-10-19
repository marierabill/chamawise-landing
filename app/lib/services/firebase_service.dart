import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {
final FirebaseFirestore _db = FirebaseFirestore.instance;


CollectionReference chamas() => _db.collection('chamas');
CollectionReference users() => _db.collection('users');


Future<DocumentReference> createChama(Map<String, dynamic> data) async {
return await chamas().add(data);
}


Future<void> addMember(String chamaId, Map<String, dynamic> member) async {
await chamas().doc(chamaId).collection('members').add(member);
}


Future<void> addContribution(String chamaId, Map<String, dynamic> contrib) async {
await chamas().doc(chamaId).collection('contributions').add(contrib);
}
}