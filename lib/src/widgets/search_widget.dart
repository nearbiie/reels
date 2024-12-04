import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core.dart';

class SearchWidget extends StatelessWidget {
  final Function(String)? onChanged;
  const SearchWidget({
    Key? key,
    this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: TextFormField(
        style: TextStyle(color: Get.theme.primaryColorDark, fontWeight: FontWeight.w300),
        keyboardType: TextInputType.text,
        onChanged: (input) => onChanged!(input),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: "Search",
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/icons/search.svg",
                colorFilter: ColorFilter.mode(Get.theme.colorScheme.primary, BlendMode.srcIn),
                width: 22,
                height: 22,
                fit: BoxFit.fill,
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 35,
                width: 1,
                color: Get.theme.primaryColor.withOpacity(0.1),
              ),
            ],
          ).pOnly(left: 15, right: 0),
          fillColor: Get.theme.primaryColor,
          filled: true,
          errorStyle: const TextStyle(fontSize: 13),
          hintStyle: Get.theme.textTheme.bodyLarge!.copyWith(color: Get.theme.primaryColorDark.withOpacity(0.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 0.5, color: Get.theme.indicatorColor.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 0.5, color: Get.theme.indicatorColor.withOpacity(0.1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 0.5, color: Get.theme.indicatorColor.withOpacity(0.1))),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 0.5, color: Get.theme.indicatorColor.withOpacity(0.1))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 0.5, color: Get.theme.indicatorColor.withOpacity(0.1))),
        ),
      ),
    ).pSymmetric(h: 15);
  }
}
