import 'package:flutter/material.dart';

import '../../../core/widgets/sliver_page_scaffold.dart';
import 'widgets/library_view.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverPageScaffold(
      title: 'Từ điển',
      subtitle: 'Tra từ vựng, ngữ pháp và ví dụ HSK.',
      headerAssetPath: 'assets/images/gen_header_dictionary.svg',
      slivers: [SliverFillRemaining(child: LibraryView())],
    );
  }
}
