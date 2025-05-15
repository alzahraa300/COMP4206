class Users {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String profileImageUrl;
  final List<String> classifications;
  final int age;

  Users({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
    required this.classifications,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'classifications': classifications,
      'age': age,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      classifications: List<String>.from(map['classifications']),
      age: map['age'],
    );
  }
}
