import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/routing/routes.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/admin/presentation/pages/add_category_page.dart';
import 'package:medical_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:medical_app/features/home/presentation/widgets/category_app_bar.dart';
import 'package:medical_app/features/home/presentation/widgets/category_empty_state.dart';
import 'package:medical_app/features/home/presentation/widgets/category_grid_view.dart';
import 'package:medical_app/features/home/presentation/widgets/category_search_field.dart';
import 'package:medical_app/features/home/domain/entities/category_entity.dart';
import 'package:medical_app/features/home/domain/usecases/get_categories_stream.dart';

class CategoryPage extends StatefulWidget {
  final GetCategoriesStream? getCategoriesStream;
  final Stream<List<CategoryEntity>>? categoriesStream;
  final ValueChanged<String>? onCategoryTap;
  final ValueChanged<CategoryEntity>? onCategoryEntityTap;

  final bool? isAdmin;
  final FirebaseAuth? firebaseAuth;
  final UserRemoteDataSource? userRemoteDataSource;
  final ValueChanged<CategoryEntity>? onEditCategory;

  const CategoryPage({
    super.key,
    this.getCategoriesStream,
    this.categoriesStream,
    this.onCategoryTap,
    this.onCategoryEntityTap,
    this.isAdmin,
    this.firebaseAuth,
    this.userRemoteDataSource,
    this.onEditCategory,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Stream<List<CategoryEntity>>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    if (widget.categoriesStream != null) {
      _stream = widget.categoriesStream;
    } else if (widget.getCategoriesStream != null) {
      _stream = widget.getCategoriesStream!();
    } else if (getIt.isRegistered<GetCategoriesStream>()) {
      _stream = getIt<GetCategoriesStream>()();
    } else {
      _stream = Stream.value(const <CategoryEntity>[]);
    }
  }

  @override
  void didUpdateWidget(covariant CategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoriesStream != oldWidget.categoriesStream ||
        widget.getCategoriesStream != oldWidget.getCategoriesStream) {
      _initStream();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  FirebaseAuth? get _auth {
    if (widget.firebaseAuth != null) return widget.firebaseAuth;
    try {
      return getIt.isRegistered<FirebaseAuth>()
          ? getIt<FirebaseAuth>()
          : FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserRemoteDataSource? get _userRemoteDataSource {
    if (widget.userRemoteDataSource != null) return widget.userRemoteDataSource;
    try {
      return getIt.isRegistered<UserRemoteDataSource>()
          ? getIt<UserRemoteDataSource>()
          : null;
    } catch (_) {
      return null;
    }
  }

  void _handleCategoryTap(CategoryEntity category) {
    if (widget.onCategoryEntityTap != null) {
      widget.onCategoryEntityTap!(category);
    } else if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(category.name);
    } else {
      Navigator.pushNamed(
        context,
        Routes.categoryDoctors,
        arguments: category,
      );
    }
  }

  Future<void> _navigateToEditCategory(CategoryEntity category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCategoryPage(initialCategory: category),
      ),
    );
  }

  void _handleEditCategory(CategoryEntity category) {
    if (widget.onEditCategory != null) {
      widget.onEditCategory!(category);
    } else {
      _navigateToEditCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdmin != null) {
      return _buildPage(context, isAdmin: widget.isAdmin!);
    }

    final firebaseAuth = _auth;
    final remoteDataSource = _userRemoteDataSource;

    if (firebaseAuth == null || remoteDataSource == null) {
      return _buildPage(context, isAdmin: false);
    }

    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, authSnapshot) {
        final currentUser = authSnapshot.data ?? firebaseAuth.currentUser;
        if (currentUser == null) {
          return _buildPage(context, isAdmin: false);
        }

        return StreamBuilder<UserModel?>(
          stream: remoteDataSource.getUserStream(currentUser.uid),
          builder: (context, userSnapshot) {
            return _buildPage(
              context,
              isAdmin: userSnapshot.data?.role == 'admin',
            );
          },
        );
      },
    );
  }

  Widget _buildPage(BuildContext context, {required bool isAdmin}) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CategoryAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              SizedBox(height: 20.h),
              StreamBuilder<List<CategoryEntity>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 48.h),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.darkTeal,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      alignment: Alignment.center,
                      child: Text(
                        '${snapshot.error}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.inter14W400,
                          Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final allCategories =
                      snapshot.data ?? const <CategoryEntity>[];
                  if (allCategories.isEmpty) {
                    return const CategoryEmptyState();
                  }

                  final query = _searchQuery.trim().toLowerCase();
                  final filteredCategories = query.isEmpty
                      ? allCategories
                      : allCategories
                          .where((c) => c.name.toLowerCase().contains(query))
                          .toList();

                  if (filteredCategories.isEmpty) {
                    return const CategoryEmptyState();
                  }

                  return CategoryGridView(
                    categories: filteredCategories,
                    isAdmin: isAdmin,
                    onEditCategory:
                        isAdmin ? _handleEditCategory : null,
                    onCategoryTap: _handleCategoryTap,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CategoryScreen = CategoryPage;