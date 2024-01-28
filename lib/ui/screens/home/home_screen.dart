import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../view_models/home_view_model.dart';
import 'widgets/radio_tile.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: const Icon(Icons.radio),
        title: ValueListenableBuilder<String>(
          valueListenable: homeViewModel.searchQuery,
          builder: (context, value, child) {
            return TextField(
              onChanged: (text) {
                homeViewModel.searchQuery.value = text;
              },
              decoration: InputDecoration(
                iconColor: Theme.of(context).colorScheme.primary,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                hintText: 'Search',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                border: InputBorder.none,
              ),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            color: Theme.of(context).colorScheme.background,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'settings',
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'about',
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
            onSelected: (String value) async {
              if (value == 'settings') {
                await Navigator.pushNamed(context, 'settings');
              } else if (value == 'about') {
                await Navigator.pushNamed(context, 'about');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        // ignore: discarded_futures
        future: homeViewModel.fetchRadios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text('Something went wrong!'),
                  TextButton(
                    onPressed: () async {
                      await homeViewModel.fetchRadios();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.inversePrimary,
              onRefresh: () async => homeViewModel.fetchRadios(),
              child: ValueListenableBuilder<String>(
                valueListenable: homeViewModel.searchQuery,
                builder: (context, value, child) {
                  final radios = homeViewModel.radios
                      .where(
                        (radio) => radio.name
                            .toLowerCase()
                            .contains(value.toLowerCase()),
                      )
                      .toList();

                  return ListView.builder(
                    itemCount: radios.length,
                    itemBuilder: (context, index) {
                      final radio = radios[index];
                      return RadioTile(
                        name: radio.name,
                        url: radio.url,
                        favicon: radio.favicon,
                        tags: radio.tags,
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
