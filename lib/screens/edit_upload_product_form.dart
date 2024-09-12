import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobiledashboard/consts/app_constants.dart';
import 'package:mobiledashboard/consts/my_validators.dart';
import 'package:mobiledashboard/models/product_model.dart';
import 'package:mobiledashboard/screens/loading_manger.dart';
import 'package:mobiledashboard/services/my_app_method.dart';
import 'package:mobiledashboard/widgets/subtitle_text.dart';
import 'package:mobiledashboard/widgets/title_text.dart';
import 'package:uuid/uuid.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({
    super.key,
    this.productModel,
  });
  final ProductModel? productModel;

  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? productNetworkImage;

  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController,
      _discountPercentageController;
  String? _categoryValue;
  bool _isOnSale = false;
  bool _isStrip = false;
  bool _isLoading = false;
  String? productImageUrl;

  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.images;
      _categoryValue = widget.productModel!.category;
      _isOnSale = widget.productModel!.isonsale;
      _isStrip = widget.productModel!.isStrip;
    }
    _titleController = TextEditingController(text: widget.productModel?.title);
    _priceController =
        TextEditingController(text: widget.productModel?.price.toString());
    _descriptionController =
        TextEditingController(text: widget.productModel?.description);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);
    _discountPercentageController = TextEditingController(
        text: widget.productModel?.discountPercentage.toString());

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _discountPercentageController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _discountPercentageController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {});
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        // If a new image is picked, upload it to Firebase Storage
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child('${_titleController.text.trim()}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        // Update the product in Firestore
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'images': productImageUrl ?? productNetworkImage,
          'category': _categoryValue,
          'description': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'discountPercentage':
              double.parse(_discountPercentageController.text),
          'isOnSale': _isOnSale,
          'isStrip': _isStrip,
          'updatedAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
          msg: "Product has been updated",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );

        // Optionally, clear the form after a successful update
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has occurred: ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has occurred: $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Make sure to pick up an image",
        fct: () {},
      );
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child("productsImages")
            .child('${_titleController.text.trim()}.jpg');
        await ref.putFile(File(_pickedImage!.path));
        productImageUrl = await ref.getDownloadURL();

        final productID = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .set({
          'productId': productID,
          'title': _titleController.text,
          'price': double.parse(_priceController.text),
          'images': productImageUrl,
          'category': _categoryValue,
          'description': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'discountPercentage':
              double.parse(_discountPercentageController.text),
          'isOnSale': _isOnSale,
          'isStrip': _isStrip,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Product has been added",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // The `_editProduct` function will be similar to `_uploadProduct`,
  // with adjustments for updating the existing document in Firestore

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: clearForm,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Edit Product" : "Upload Product",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: TitlesTextWidget(
              label: isEditing ? "Edit Product" : "Upload a new product",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                          color: Colors.blue,
                          radius: const Radius.circular(12),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.blue,
                                ),
                                TextButton(
                                  onPressed: () {
                                    localImagePicker();
                                  },
                                  child: const Text("Pick Product image"),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                  if (_pickedImage != null && productNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: const Text("Pick another image"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Remove image",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint: Text(_categoryValue ?? "Select Category"),
                    value: _categoryValue,
                    items: AppConstants.categoriesDropDownList,
                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Product Title',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey('Price \$'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Price',
                                      prefix: SubtitleTextWidget(
                                        label: "\$ ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Price is missing",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    hintText: 'Qty',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Quantity is missed",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Discount Percentage'),
                            controller: _discountPercentageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^(\d+)?\.?\d{0,2}'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Discount Percentage',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Discount percentage is missing",
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Product description',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Description is missed",
                              );
                            },
                            onTap: () {},
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text("Is On Sale"),
                                  value: _isOnSale,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _isOnSale = newValue!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text("Is Strip"),
                                  value: _isStrip,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _isStrip = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
