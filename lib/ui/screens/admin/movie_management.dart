import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/models/movie.dart';
import 'package:review_film_app/ui/providers/movie_provider.dart';
import 'package:review_film_app/ui/providers/category_provider.dart';
import 'package:review_film_app/ui/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MovieManagement extends StatefulWidget {
  const MovieManagement({super.key});

  @override
  State<MovieManagement> createState() => _MovieManagementState();
}

class _MovieManagementState extends State<MovieManagement> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final movies = movieProvider.movies;

    return Scaffold(
      appBar: AppBar(title: const Text('Quản Lý Phim')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child:
            movieProvider.isLoading
                ? const LoadingIndicator()
                : movies.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có phim nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm phim mới'),
                        onPressed: () => _showMovieForm(context),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  image:
                                      movie.posterUrl.isNotEmpty
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              movie.posterUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    movie.isAgeRestricted
                                        ? Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '18+',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Đạo diễn: ${movie.director}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${movie.rating}/10',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.grey.shade600,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${movie.duration} phút'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thể loại: ${movie.categories}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Chỉnh sửa',
                                  onPressed:
                                      () => _showMovieForm(context, movie),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Xóa',
                                  onPressed:
                                      () => _confirmDelete(context, movie),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMovieForm(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: 'Xóa Phim',
            content: 'Bạn có chắc chắn muốn xóa phim "${movie.title}"?',
            confirmText: 'Xóa',
            onConfirm: () {
              Provider.of<MovieProvider>(
                context,
                listen: false,
              ).deleteMovie(movie.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa phim ${movie.title}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
    );
  }

  void _showMovieForm(BuildContext context, [Movie? movie]) {
    showDialog(context: context, builder: (context) => MovieForm(movie: movie));
  }
}

class MovieForm extends StatefulWidget {
  final Movie? movie;

  const MovieForm({super.key, this.movie});

  @override
  State<MovieForm> createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _directorController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isAgeRestricted = false;
  List<String> _selectedCategories = [];
  DateTime? _selectedDate;

  // Thêm các biến cho upload ảnh
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _descriptionController.text = widget.movie!.description;
      _directorController.text = widget.movie!.director;
      _releaseDateController.text = widget.movie!.releaseDate;
      _posterUrlController.text = widget.movie!.posterUrl;
      _ratingController.text = widget.movie!.rating.toString();
      _durationController.text = widget.movie!.duration.toString();
      _isAgeRestricted = widget.movie!.isAgeRestricted;
      _selectedCategories =
          widget.movie!.categories.split(',').map((e) => e.trim()).toList();

      try {
        _selectedDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(widget.movie!.releaseDate);
      } catch (e) {
        // If date parsing fails, leave it as null
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _directorController.dispose();
    _releaseDateController.dispose();
    _posterUrlController.dispose();
    _ratingController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: const Locale('vi', 'VN'),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _releaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    } catch (e) {
      print('Lỗi khi hiển thị date picker: $e');
      // Hiển thị dialog nhập thủ công nếu date picker gặp lỗi
      _showManualDateInputDialog();
    }
  }

  // Thêm phương thức nhập ngày thủ công
  void _showManualDateInputDialog() {
    final TextEditingController dateController = TextEditingController();
    if (_selectedDate != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }

    // Hiển thị hộp thoại nhập ngày.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Hộp thoại chứa TextField nhập ngày.
        return AlertDialog(
          title: const Text('Nhập ngày phát hành'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vui lòng nhập ngày phát hành theo định dạng yyyy-MM-dd:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Ngày phát hành',
                  hintText: 'VD: 2023-12-31',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dateController.text.isNotEmpty) {
                  try {
                    // Neu ngay hop le, cập nhật _selectedDate và _releaseDateController.
                    final date = DateFormat(
                      'yyyy-MM-dd',
                    ).parse(dateController.text);
                    setState(() {
                      _selectedDate = date;
                      _releaseDateController.text = dateController.text;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Định dạng ngày không hợp lệ. Vui lòng nhập theo định dạng yyyy-MM-dd',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  // Thêm hàm upload ảnh lên ImgBB
  Future<void> _uploadImageToImgBB() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      // Tạo request để upload lên ImgBB sử dụng multipart/form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );

      // Thêm API key
      request.fields['key'] = 'e64a49ca517de7491f78d8edf586515a';

      // Thêm file ảnh
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        ),
      );

      // Gửi request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw TimeoutException(
            'Quá thời gian kết nối, vui lòng thử lại sau.',
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      // Nếu statusCode == 200, kiểm tra jsonData['success'].
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          setState(() {
            // Sử dụng URL display_url thay vì url để có chất lượng tốt hơn
            _posterUrlController.text = jsonData['data']['display_url'];
            _isUploading = false;
          });

          // Hiển thị thông báo thành công
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải ảnh lên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            // Sửa cú pháp truy cập lồng nhau trong JSON
            String errorMessage = 'Không xác định';
            if (jsonData['error'] != null &&
                jsonData['error']['message'] != null) {
              errorMessage = jsonData['error']['message'];
            }
            _uploadError = 'Lỗi upload: $errorMessage';
            _isUploading = false;
          });
        }
      } else {
        setState(() {
          _uploadError = 'Lỗi server: ${response.statusCode}';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('Permission')) {
          _uploadError =
              'Không có quyền truy cập ảnh. Vui lòng cấp quyền trong cài đặt ứng dụng.';
        } else if (e.toString().contains('network')) {
          _uploadError =
              'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        } else {
          _uploadError = 'Lỗi: ${e.toString()}';
        }
        _isUploading = false;
      });

      // In ra log để debug
      print('Lỗi upload ảnh: $e');
    }
  }

  // Thêm hàm chọn ảnh từ thiết bị
  Future<void> _pickImage() async {
    try {
      // Thay vì hiển thị dialog, thử trực tiếp với gallery
      await _getImage(ImageSource.gallery);
    } catch (e) {
      setState(() {
        _uploadError = 'Không thể mở chọn ảnh: $e';
      });
      print('Lỗi mở chọn ảnh: $e');

      // Hiển thị dialog để nhập URL thủ công khi không thể chọn ảnh
      _showManualUrlInputDialog();
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      // Thêm log để debug
      print('Bắt đầu chọn ảnh từ: ${source.toString()}');

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      print('Kết quả chọn ảnh: ${pickedFile != null ? 'Thành công' : 'Null'}');

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _uploadError = null;
        });

        // Upload ảnh ngay sau khi chọn
        await _uploadImageToImgBB();
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Không thể chọn ảnh: $e';
      });
      print('Lỗi chi tiết khi chọn ảnh: $e');
    }
  }

  // Thêm phương thức để nhập URL thủ công
  void _showManualUrlInputDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nhập URL ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Không thể chọn ảnh từ thiết bị. Vui lòng nhập URL ảnh trực tiếp:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL ảnh',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  setState(() {
                    _posterUrlController.text = urlController.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    // Thay đổi phần hiển thị trường URL Poster
    Widget _buildPosterField() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poster phim',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _posterUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL Poster',
                          hintText: 'URL hình ảnh poster',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng upload ảnh hoặc nhập URL poster';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.upload),
                      label: const Text('Tải lên'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showManualUrlInputDialog,
                      icon: const Icon(Icons.link),
                      label: const Text('Nhập URL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isUploading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Đang tải ảnh lên...'),
                      ],
                    ),
                  )
                else if (_uploadError != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _uploadError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_posterUrlController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xem trước:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _posterUrlController.text,
                            height: 150,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: 100,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                width: 100,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.red.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(Icons.movie, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.movie == null ? 'Thêm Phim Mới' : 'Chỉnh Sửa Phim',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Tên phim',
                          hint: 'Nhập tên phim',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên phim';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Mô tả',
                          hint: 'Nhập mô tả phim',
                          icon: Icons.description,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mô tả phim';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _directorController,
                          label: 'Đạo diễn',
                          hint: 'Nhập tên đạo diễn',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên đạo diễn';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _releaseDateController,
                          decoration: InputDecoration(
                            labelText: 'Ngày phát hành',
                            hintText: 'Chọn ngày phát hành',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn ngày phát hành';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Thay thế trường URL Poster bằng widget mới
                        _buildPosterField(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _ratingController,
                                label: 'Đánh giá (0-10)',
                                hint: 'Nhập điểm đánh giá',
                                icon: Icons.star,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập điểm đánh giá';
                                  }
                                  try {
                                    final rating = double.parse(value);
                                    if (rating < 0 || rating > 10) {
                                      return 'Điểm đánh giá phải từ 0-10';
                                    }
                                  } catch (e) {
                                    return 'Vui lòng nhập số hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _durationController,
                                label: 'Thời lượng (phút)',
                                hint: 'Nhập thời lượng phim',
                                icon: Icons.timer,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập thời lượng';
                                  }
                                  try {
                                    final duration = int.parse(value);
                                    if (duration <= 0) {
                                      return 'Thời lượng phải lớn hơn 0';
                                    }
                                  } catch (e) {
                                    return 'Vui lòng nhập số hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isAgeRestricted,
                                activeColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    _isAgeRestricted = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Giới hạn độ tuổi (18+)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (_isAgeRestricted)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '18+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Thể loại phim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                categories.map((category) {
                                  final isSelected = _selectedCategories
                                      .contains(category.name);
                                  return FilterChip(
                                    label: Text(category.name),
                                    selected: isSelected,
                                    selectedColor: Colors.red.shade100,
                                    checkmarkColor: Colors.red,
                                    backgroundColor: Colors.grey.shade100,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedCategories.add(
                                            category.name,
                                          );
                                        } else {
                                          _selectedCategories.remove(
                                            category.name,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveMovie,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(widget.movie == null ? 'Thêm mới' : 'Cập nhật'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _saveMovie() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một thể loại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    final movie = Movie(
      id: widget.movie?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      director: _directorController.text,
      releaseDate: _releaseDateController.text,
      posterUrl: _posterUrlController.text,
      categories: _selectedCategories.join(', '),
      isAgeRestricted: _isAgeRestricted,
      rating: double.parse(_ratingController.text),
      duration: int.parse(_durationController.text),
    );

    if (widget.movie == null) {
      movieProvider.addMovie(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm phim mới thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      movieProvider.updateMovie(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật phim thành công'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
