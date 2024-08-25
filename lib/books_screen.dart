import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'book_detail_screen.dart';

class Book {
  final String title;
  final String author;
  final String image;
  final String description;
  String? docID;
  double rating;
  List<Comment> comments;

  Book({
    this.docID,
    required this.title,
    required this.author,
    required this.image,
    required this.description,
    this.rating = 0.0,
    this.comments = const [],
  });

  // Convert Book object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'image': image,
      'description': description,
      'rating': rating,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // Create Book object from JSON
  factory Book.fromJson(Map<String, dynamic> json, String id) {
    return Book(
      docID: id,
      title: json['title'],
      author: json['author'],
      image: json['image'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
    );
  }
}

class Comment {
  final String user;
  final String text;
  final bool liked;

  Comment({
    required this.user,
    required this.text,
    this.liked = false,
  });

  // Convert Comment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'text': text,
      'liked': liked,
    };
  }

  // Create Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'],
      text: json['text'],
      liked: json['liked'] ?? false, // Default to false if liked is not present
    );
  }
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final List<Book> _books = [
    // Book(
    //   title: 'Book 1',
    //   author: 'Author 1',
    //   image: 'https://picsum.photos/150?random=1',
    //   description: 'Description of Book 1',
    // ),
    // Book(
    //   title: 'Book 2',
    //   author: 'Author 2',
    //   image: 'https://picsum.photos/150?random=2',
    //   description: 'Description of Book 2',
    // ),
  ];

  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBooks = _books;
    _searchController.addListener(_filterBooks);
    loadAllBooks();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addBook(
      String title, String author, String image, String description) async {
    final book = Book(
      title: title,
      author: author,
      image: image,
      description: description,
    );
    setState(() {
      _books.add(book);

      _filterBooks();
    });
    await FirebaseFirestore.instance.collection('books').add(book.toJson());
    loadAllBooks();
  }

  void _removeBook(int index, String docID) async {
    if (docID.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('books')
          .doc(_books[index].docID)
          .delete();
    }

    setState(() {
      _books.removeAt(index);
      _filterBooks();
    });
  }

  void _showAddBookDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                      labelText: 'URL of the\'cover (Optional)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                _addBook(
                  titleController.text,
                  authorController.text,
                  imageController.text.isEmpty
                      ? 'https://firebasestorage.googleapis.com/v0/b/library-manage-mahi.appspot.com/o/user_photos%2Fb.jpeg?alt=media&token=5b96a4e4-46d6-4ccd-9b1d-056b65536e8b'
                      : imageController.text,
                  descriptionController.text,
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

  bool isLoading = true;

  loadAllBooks() async {
    final rawData = await FirebaseFirestore.instance.collection('books').get();
    List<Book> booksAll = [];
    for (var e in rawData.docs) {
      booksAll.add(Book.fromJson(e.data(), e.id));
    }
    setState(() {
      _books.clear();
      _books.addAll(booksAll);
      _filteredBooks = _books;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Books'),
          actions: [
            ElevatedButton.icon(
              onPressed: _showAddBookDialog,
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
                  hintText: 'Search for books...',
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
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Image.network(book.image),
                      title: Text(book.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Author: ${book.author}'),
                          RatingBar.builder(
                            initialRating: book.rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                book.rating = rating;
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    BookDetailScreen(book: book),
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
                          _removeBook(index, book.docID ?? '');
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
