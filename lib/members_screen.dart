import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'member_detail_screen.dart';

class Member {
  final String name;
  final String email;
  final String image;
  final String description;
  final String nid;
  String? docID; // Firestore document ID

  Member( {
    this.docID,
    required this.name,
    required this.email,
    required this.image,
    required this.description,
    required this.nid,
  });

  // Convert a JSON object to a Member instance
  factory Member.fromJson(Map<String, dynamic> json, String id) {
    return Member(
      docID: id,
      name: json['name'],
      email: json['email'],
      image: json['image'],
      description: json['description'],
      nid: json['nid'],
    );
  }

  // Convert a Member instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'description': description,
      'nid': nid,
    };
  }
}

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final List<Member> _members = [];
  List<Member> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMembers);
    loadAllMembers();
  }

  // Load all members from Firestore
  Future<void> loadAllMembers() async {
    final rawData =
        await FirebaseFirestore.instance.collection('members').get();
    List<Member> membersAll = [];
    for (var e in rawData.docs) {
      membersAll.add(Member.fromJson(e.data(), e.id));
    }
    setState(() {
      _members.clear();
      _members.addAll(membersAll);
      _filteredMembers = _members;
      isLoading = false;
    });
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.name.toLowerCase().contains(query) ||
            member.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _addMember(
      String name, String email, String image, String description, String nid) async {
    final member = Member(
      name: name,
      email: email,
      image: image,
      description: description,
        nid: nid,

    );
    await FirebaseFirestore.instance.collection('members').add(member.toJson());
    loadAllMembers();
  }

  Future<void> _removeMember(int index, String docID) async {
    if (docID.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(docID)
          .delete();
    }
    setState(() {
      _members.removeAt(index);
      _filterMembers();
    });
  }

  void _showAddMemberDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController nidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                      labelText: 'URL of the DP (Optional)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: nidController,
                  decoration: const InputDecoration(labelText: 'NID No.'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addMember(
                  nameController.text,
                  emailController.text,
                  imageController.text.isEmpty
                      ? 'https://miro.medium.com/v2/resize:fit:600/format:webp/1*PiHoomzwh9Plr9_GA26JcA.png'
                      : imageController.text,
                  descriptionController.text,
                  nidController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members'),
          actions: [
            ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for members...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Image.network(member.image),
                      title: Text(member.name),
                      subtitle: Text(member.email),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MemberDetailScreen(member: member),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeMember(index, member.docID ?? '');
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
